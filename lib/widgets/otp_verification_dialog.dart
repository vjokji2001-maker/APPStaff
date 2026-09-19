import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/api/api_service.dart';
import 'package:staff_mate/pages/login_page.dart';
import 'package:staff_mate/services/email_verfication_service.dart';
import 'package:staff_mate/services/mobile_verification_service.dart';
import 'package:staff_mate/services/session_manger.dart';

// ─── OTPVerificationDialog ──────────────────────────────────────────────────
//
// Presents two tabs:
//   • Email  — uses EmailVerificationService  (sendEmailOTP  / verifyOTP)
//   • Mobile — uses MobileVerificationService (sendMobileOTP / verifyMobileOTP)
//
// Skip and Cancel buttons remain unchanged from the original design.
// ────────────────────────────────────────────────────────────────────────────

class OTPVerificationDialog extends StatefulWidget {
  final String userId;
  final String clinicId;
  final String token;
  final VoidCallback onVerificationSuccess;
  final VoidCallback onVerificationFailed;

  const OTPVerificationDialog({
    super.key,
    required this.userId,
    required this.clinicId,
    required this.token,
    required this.onVerificationSuccess,
    required this.onVerificationFailed,
  });

  @override
  State<OTPVerificationDialog> createState() => _OTPVerificationDialogState();
}

// Tab index constant
const int _kEmailTab = 0;

class _OTPVerificationDialogState extends State<OTPVerificationDialog>
    with SingleTickerProviderStateMixin {
  // ── Services ────────────────────────────────────────────────────────────────
  final EmailVerificationService _emailService = EmailVerificationService();
  final MobileVerificationService _mobileService = MobileVerificationService();

  // ── Tab controller ──────────────────────────────────────────────────────────
  late final TabController _tabController;

  // ── Input controllers ────────────────────────────────────────────────────────
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  // ── UI state ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _showOTPInput = false;
  bool _isResendEnabled = true;
  int _resendTimer = 300;
  Timer? _resendCountdown;

  String _alertMessage = '';
  Color _alertColor = Colors.green;
  bool _showAlert = false;
  Timer? _alertTimer;

  // ── Data ─────────────────────────────────────────────────────────────────────
  String _currentEmail = '';
  String _currentMobile = '';

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      // Reset OTP input state when user switches tabs
      setState(() {
        _showOTPInput = false;
        _showAlert = false;
        _otpController.clear();
        _isResendEnabled = true;
      });
      _resendCountdown?.cancel();
      _alertTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _otpController.dispose();
    _pinFocusNode.dispose();
    _resendCountdown?.cancel();
    _alertTimer?.cancel();
    super.dispose();
  }

  // ── Alert helper ─────────────────────────────────────────────────────────────

  void _alert(String message, {bool success = true}) {
    _alertTimer?.cancel();
    setState(() {
      _alertMessage = message;
      _alertColor = success ? Colors.green : Colors.red;
      _showAlert = true;
    });
    _alertTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showAlert = false);
    });
  }

  // ── Resend timer ─────────────────────────────────────────────────────────────

  void _startResendTimer() {
    setState(() {
      _isResendEnabled = false;
      _resendTimer = 300;
    });
    _resendCountdown?.cancel();
    _resendCountdown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        setState(() => _isResendEnabled = true);
        t.cancel();
      }
    });
  }

  // ── Skip / Cancel ─────────────────────────────────────────────────────────────

  Future<void> _skipVerification() async {
    try {
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : _currentEmail;
      if (email.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('otp_email', email);
      }
    } catch (e) {
      debugPrint('Skip OTP fallback error: $e');
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    await Future.delayed(const Duration(milliseconds: 100));
    widget.onVerificationSuccess();
  }

  void _cancel() {
    Navigator.of(context).pop();
    widget.onVerificationFailed();
  }

  // ── Email OTP flow ────────────────────────────────────────────────────────────

  Future<void> _sendEmailOTP() async {
    setState(() => _showAlert = false);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _alert('Please enter your email address', success: false);
      return;
    }
    if (!_emailService.isValidEmail(email)) {
      _alert('Please enter a valid email address', success: false);
      return;
    }

    setState(() {
      _isLoading = true;
      _currentEmail = email;
    });

    try {
      final result = await _emailService.sendEmailOTP(
        email: email,
        userId: widget.userId,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('otp_email', email);
        await _emailService.saveVerificationData(
          email: email,
          userId: widget.userId,
        );
        setState(() => _showOTPInput = true);
        _startResendTimer();
        _alert('✓ OTP sent to $email');
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) FocusScope.of(context).requestFocus(_pinFocusNode);
        });
      } else {
        _alert(result['message'] ?? '✗ Failed to send OTP', success: false);
      }
    } catch (e) {
      _alert('✗ Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmailOTP() async {
    setState(() => _showAlert = false);
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _alert('Please enter the OTP', success: false);
      return;
    }
    if (!_emailService.isValidOTP(otp)) {
      _alert('Please enter a valid 6-digit OTP', success: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _emailService.verifyOTP(
        userOtp: otp,
        userId: widget.userId,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        _alert('✓ OTP verified successfully!');
        await _emailService.markEmailAsVerified(_currentEmail);
        await _emailService.clearVerificationData();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onVerificationSuccess();
          }
        });
      } else {
        _alert(result['message'] ?? '✗ Invalid OTP', success: false);
      }
    } catch (e) {
      _alert('✗ Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendEmailOTP() async {
    if (!_isResendEnabled) return;
    setState(() {
      _isLoading = true;
      _showAlert = false;
    });
    try {
      final result = await _emailService.sendEmailOTP(
        email: _currentEmail,
        userId: widget.userId,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        _otpController.clear();
        _startResendTimer();
        _alert('✓ OTP resent successfully');
      } else {
        _alert(result['message'] ?? '✗ Failed to resend OTP', success: false);
      }
    } catch (e) {
      _alert('✗ Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Mobile OTP flow ───────────────────────────────────────────────────────────

  Future<void> _sendMobileOTP() async {
    setState(() => _showAlert = false);
    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty) {
      _alert('Please enter your mobile number', success: false);
      return;
    }
    if (!_mobileService.isValidMobile(mobile)) {
      _alert('Please enter a valid 10-digit mobile number', success: false);
      return;
    }

    setState(() {
      _isLoading = true;
      _currentMobile = _mobileService.normalizeMobile(mobile);
    });

    try {
      final result = await _mobileService.sendMobileOTP(
        mobileNumber: _currentMobile,
        userId: widget.userId,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        setState(() => _showOTPInput = true);
        _startResendTimer();
        _alert('✓ OTP sent to $_currentMobile');
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) FocusScope.of(context).requestFocus(_pinFocusNode);
        });
      } else {
        _alert(result['message'] ?? '✗ Failed to send OTP', success: false);
      }
    } catch (e) {
      _alert('✗ Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyMobileOTP() async {
    setState(() => _showAlert = false);
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _alert('Please enter the OTP', success: false);
      return;
    }
    if (!_mobileService.isValidOTP(otp)) {
      _alert('Please enter a valid 6-digit OTP', success: false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _mobileService.verifyMobileOTP(
        userOtp: otp,
        userId: widget.userId,
      );
      if (!mounted) return;

      if (result['success'] == true) {
        _alert('✓ Mobile OTP verified successfully!');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onVerificationSuccess();
          }
        });
      } else {
        _alert(result['message'] ?? '✗ Invalid OTP', success: false);
      }
    } catch (e) {
      _alert('✗ Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendMobileOTP() async {
    if (!_isResendEnabled) return;
    setState(() {
      _isLoading = true;
      _showAlert = false;
    });
    try {
      final result = await _mobileService.sendMobileOTP(
        mobileNumber: _currentMobile,
        userId: widget.userId,
      );
      if (!mounted) return;
      if (result['success'] == true) {
        _otpController.clear();
        _startResendTimer();
        _alert('✓ OTP resent successfully');
      } else {
        _alert(result['message'] ?? '✗ Failed to resend OTP', success: false);
      }
    } catch (e) {
      _alert('✗ Error: $e', success: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SessionManager.updateUserActivity();
        ApiService.updateUserActivity();
      },
      onPanUpdate: (_) {
        SessionManager.updateUserActivity();
        ApiService.updateUserActivity();
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Alert banner ──────────────────────────────────────────────
                _buildAlertBanner(),

                // ── Header icon ───────────────────────────────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _showOTPInput
                        ? Icons.mark_email_read_rounded
                        : Icons.verified_user_rounded,
                    color: AppColors.primaryDarkBlue,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  _showOTPInput ? 'Verify OTP' : 'Verify Identity',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _showOTPInput
                      ? 'Enter the 6-digit code we sent you'
                      : 'Choose how you want to receive your OTP',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textBodyColor,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tab bar (hidden while OTP input is shown) ─────────────────
                if (!_showOTPInput) ...[
                  _buildTabBar(),
                  const SizedBox(height: 16),
                  SizedBox(
                    // intrinsic height for tab body
                    height: 120,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildEmailInputTab(), _buildMobileInputTab()],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSendButton(),
                ] else ...[
                  // ── OTP pin input ─────────────────────────────────────────
                  _buildOTPInput(),
                  const SizedBox(height: 12),
                  _buildResendRow(),
                  const SizedBox(height: 16),
                  _buildVerifyButton(),
                ],

                const SizedBox(height: 8),

                // ── Skip & Cancel ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _skipVerification,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryDarkBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _isLoading ? null : _cancel,
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────────

  Widget _buildAlertBanner() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: _showAlert ? null : 0,
      margin: EdgeInsets.only(bottom: _showAlert ? 14 : 0),
      child: _showAlert
          ? Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _alertColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _alertColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _alertColor == Colors.green
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      color: _alertColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _alertMessage,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: _alertColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _showAlert = false);
                        _alertTimer?.cancel();
                      },
                      child: Icon(Icons.close, size: 16, color: _alertColor),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primaryDarkBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textBodyColor,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(icon: Icon(Icons.email_outlined, size: 18), text: 'Email'),
          Tab(
            icon: Icon(Icons.phone_android_rounded, size: 18),
            text: 'Mobile',
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInputTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your email to receive OTP',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textBodyColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.poppins(fontSize: 14),
            onTap: () {
              SessionManager.updateUserActivity();
              ApiService.updateUserActivity();
            },
            decoration: InputDecoration(
              hintText: 'Email Address',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.primaryDarkBlue,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileInputTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter your mobile number to receive OTP',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textBodyColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            style: GoogleFonts.poppins(fontSize: 14),
            onTap: () {
              SessionManager.updateUserActivity();
              ApiService.updateUserActivity();
            },
            decoration: InputDecoration(
              hintText: 'Mobile Number (10 digits)',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                Icons.phone_android_rounded,
                color: AppColors.primaryDarkBlue,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    final isEmail = _tabController.index == _kEmailTab;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (isEmail ? _sendEmailOTP : _sendMobileOTP),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEmail ? Icons.send_rounded : Icons.sms_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Send OTP',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOTPInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Pinput(
        controller: _otpController,
        focusNode: _pinFocusNode,
        length: 6,
        defaultPinTheme: PinTheme(
          width: 44,
          height: 50,
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkBlue,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
        focusedPinTheme: PinTheme(
          width: 44,
          height: 50,
          textStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkBlue,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryDarkBlue, width: 2),
          ),
        ),
        onTap: () {
          SessionManager.updateUserActivity();
          ApiService.updateUserActivity();
        },
        onCompleted: (_) {
          final isEmail = _tabController.index == _kEmailTab;
          isEmail ? _verifyEmailOTP() : _verifyMobileOTP();
        },
      ),
    );
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: GoogleFonts.poppins(
            color: AppColors.textBodyColor,
            fontSize: 12,
          ),
        ),
        GestureDetector(
          onTap: _isResendEnabled
              ? (_tabController.index == _kEmailTab
                    ? _resendEmailOTP
                    : _resendMobileOTP)
              : null,
          child: Text(
            _isResendEnabled ? 'Resend' : 'Resend in $_resendTimer s',
            style: GoogleFonts.poppins(
              color: _isResendEnabled ? AppColors.primaryDarkBlue : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              decoration: _isResendEnabled
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    final isEmail = _tabController.index == _kEmailTab;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : (isEmail ? _verifyEmailOTP : _verifyMobileOTP),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Verify & Continue',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
