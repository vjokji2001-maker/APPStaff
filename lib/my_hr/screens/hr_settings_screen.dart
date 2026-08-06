import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../widgets/hr_widgets.dart';
import '../../services/user_information_service.dart';
import '../../services/session_manger.dart';
import '../../pages/welcome_page.dart';

class HRSettingsScreen extends StatefulWidget {
  const HRSettingsScreen({super.key});
  @override
  State<HRSettingsScreen> createState() => _HRSettingsScreenState();
}

class _HRSettingsScreenState extends State<HRSettingsScreen> {
  // Notification toggles
  bool _notifSalary = true;
  bool _notifLeave = true;
  bool _notifAnnounce = true;
  bool _notifReminder = true;
  bool _notifAlert = true;
  bool _notifCircular = false;

  // Appearance
  final _themeNotifier = ValueNotifier<bool>(false); // false = light
  bool _isDarkMode = false;

  // Security
  bool _biometricEnabled = false;

  // Language
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu', 'Kannada'];

  // Profile edit controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  // Profile dynamic data
  String _empName = HRMockData.employee.name;
  String _empRole = HRMockData.employee.designation;
  String _empCode = HRMockData.employee.employeeCode;
  String _empInitials = HRMockData.employee.avatarInitials;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _empName);
    _phoneCtrl = TextEditingController(text: HRMockData.employee.phone);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final completeData = await UserInformationService.getCompleteUserData();
      Map<String, dynamic>? userData;
      
      if (completeData != null && completeData.containsKey('data')) {
        userData = completeData['data'];
      } else {
        final userInfo = await UserInformationService.getSavedUserInformation();
        if (userInfo.isNotEmpty && userInfo['userId']?.isNotEmpty == true) {
          userData = userInfo;
        }
      }
      
      if (userData != null && mounted) {
        String first = userData['firstName']?.toString() ?? '';
        String last = userData['lastName']?.toString() ?? '';
        String init = userData['initial']?.toString() ?? '';
        
        // Try pre-built fullName first, else build from parts
        String fullName = userData['fullName']?.toString() ?? '';
        if (fullName.isEmpty) {
          fullName = '$init $first $last'.trim();
        }
        if (fullName.isEmpty) fullName = userData['userId']?.toString() ?? 'Employee';
        
        String job = userData['jobtitle']?.toString() ?? '';
        String role = job.isNotEmpty ? job : 'Medical Staff';
        String code = userData['userId']?.toString() ?? 'EMP001';
        String phone = userData['mobileNo']?.toString() ?? '';
        String avatarStr = first.isNotEmpty ? first[0].toUpperCase() : (fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U');
        debugPrint('HR Settings - Name: $fullName | Role: $role');
        
        setState(() {
          _empName = fullName;
          _empRole = role;
          _empCode = code;
          _empInitials = avatarStr;
          
          if (_nameCtrl.text == HRMockData.employee.name) {
             _nameCtrl.text = _empName;
          }
          if (_phoneCtrl.text == HRMockData.employee.phone) {
             _phoneCtrl.text = phone;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading profile in settings: $e');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(title: 'Settings', subtitle: 'Preferences & security'),
        Expanded(child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _sectionHeader('Profile Settings', Icons.person_outlined),
            _buildProfileSection(isDark),
            _sectionHeader('Notification Settings', Icons.notifications_outlined),
            _buildNotificationSection(isDark),
            _sectionHeader('Appearance', Icons.palette_outlined),
            _buildAppearanceSection(isDark),
            _sectionHeader('Language', Icons.language_outlined),
            _buildLanguageSection(isDark),
            _sectionHeader('Security', Icons.security_outlined),
            _buildSecuritySection(isDark),
            _sectionHeader('App Info', Icons.info_outline_rounded),
            _buildAppInfoSection(isDark),
            const SizedBox(height: 32),
          ],
        )),
      ]),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Row(children: [
        Icon(icon, size: 16, color: HRTheme.primaryDark),
        const SizedBox(width: 6),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700,
            color: HRTheme.primaryDark, letterSpacing: 0.5)),
      ]),
    );
  }

  Widget _buildProfileSection(bool isDark) {
    return HRCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 28, backgroundColor: HRTheme.primaryDark.withOpacity(0.12),
            child: Text(_empInitials,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: HRTheme.primaryDark)),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_empName, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HRTheme.textPrimary)),
            Text(_empRole, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
            Text(_empCode, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
          ])),
        ]),
        const SizedBox(height: 14),
        _editField('Display Name', _nameCtrl, Icons.person_outlined),
        const SizedBox(height: 10),
        _editField('Phone Number', _phoneCtrl, Icons.phone_outlined, keyboardType: TextInputType.phone),
        const SizedBox(height: 14),
        HRPrimaryButton(label: 'Save Changes', icon: Icons.save_rounded, onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile updated', style: GoogleFonts.poppins()),
            backgroundColor: HRTheme.success, behavior: SnackBarBehavior.floating,
          ));
        }),
      ]),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, IconData icon, {TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
      const SizedBox(height: 4),
      TextField(
        controller: ctrl, keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 13),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: HRTheme.textSecondary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM), borderSide: BorderSide(color: Colors.grey.shade300)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    ]);
  }

  Widget _buildNotificationSection(bool isDark) {
    return HRCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        _notifTile('Salary & Payroll', 'Get notified when salary is credited', _notifSalary, (v) => setState(() => _notifSalary = v), Icons.payments_outlined, HRTheme.payroll),
        _notifTile('Leave Updates', 'Approval status for leave requests', _notifLeave, (v) => setState(() => _notifLeave = v), Icons.beach_access_outlined, HRTheme.leave),
        _notifTile('Announcements', 'Hospital-wide announcements', _notifAnnounce, (v) => setState(() => _notifAnnounce = v), Icons.campaign_outlined, HRTheme.teal),
        _notifTile('Reminders', 'Training, document, shift reminders', _notifReminder, (v) => setState(() => _notifReminder = v), Icons.alarm_outlined, HRTheme.warning),
        _notifTile('Alerts', 'Critical HR alerts and notifications', _notifAlert, (v) => setState(() => _notifAlert = v), Icons.error_outline_rounded, HRTheme.error),
        _notifTile('Circulars', 'Policy circulars and documents', _notifCircular, (v) => setState(() => _notifCircular = v), Icons.article_outlined, HRTheme.info, isLast: true),
      ]),
    );
  }

  Widget _notifTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged, IconData icon, Color color, {bool isLast = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(children: [
      ListTile(
        contentPadding: EdgeInsets.zero, dense: true,
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
          child: Icon(icon, size: 16, color: color),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : HRTheme.textPrimary)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
        trailing: Switch.adaptive(value: value, onChanged: onChanged, activeColor: HRTheme.primaryDark),
      ),
      if (!isLast) Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider, height: 1),
    ]);
  }

  Widget _buildAppearanceSection(bool isDark) {
    return HRCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero, dense: true,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: HRTheme.primaryDark.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
            child: Icon(_isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, size: 16, color: HRTheme.primaryDark),
          ),
          title: Text('Dark Mode', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : HRTheme.textPrimary)),
          subtitle: Text(_isDarkMode ? 'Dark theme active' : 'Light theme active', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          trailing: Switch.adaptive(
            value: _isDarkMode,
            onChanged: (v) => setState(() { _isDarkMode = v; _themeNotifier.value = v; }),
            activeColor: HRTheme.primaryDark,
          ),
        ),
      ]),
    );
  }

  Widget _buildLanguageSection(bool isDark) {
    return HRCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedLanguage,
        items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
        onChanged: (v) => setState(() => _selectedLanguage = v!),
        decoration: InputDecoration(
          labelText: 'App Language',
          labelStyle: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary),
          prefixIcon: const Icon(Icons.language_rounded, size: 18, color: HRTheme.primaryDark),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildSecuritySection(bool isDark) {
    return HRCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        ListTile(
          contentPadding: EdgeInsets.zero, dense: true,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: HRTheme.primaryDark.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
            child: const Icon(Icons.lock_outline_rounded, size: 16, color: HRTheme.primaryDark),
          ),
          title: Text('Change Password', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : HRTheme.textPrimary)),
          subtitle: Text('Update your login password', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          trailing: Icon(Icons.chevron_right_rounded, color: HRTheme.textHint),
          onTap: _showChangePasswordSheet,
        ),
        Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider, height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero, dense: true,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: HRTheme.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
            child: const Icon(Icons.fingerprint_rounded, size: 16, color: HRTheme.teal),
          ),
          title: Text('Biometric Login', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : HRTheme.textPrimary)),
          subtitle: Text('Use fingerprint or Face ID to login', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          trailing: Switch.adaptive(value: _biometricEnabled, onChanged: (v) => setState(() => _biometricEnabled = v), activeColor: HRTheme.teal),
        ),
      ]),
    );
  }

  Widget _buildAppInfoSection(bool isDark) {
    return HRCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [
        _infoTile('App Version', '2025.1.0', Icons.info_outline_rounded, isDark),
        Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider, height: 1),
        _infoTile('Hospital', 'City Hospital – Main Campus', Icons.local_hospital_outlined, isDark),
        Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider, height: 1),
        _infoTile('HR Support', 'hr.support@cityhospital.com', Icons.email_outlined, isDark),
        Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider, height: 1),
        ListTile(
          contentPadding: EdgeInsets.zero, dense: true,
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: HRTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
            child: const Icon(Icons.logout_rounded, size: 16, color: HRTheme.error),
          ),
          title: Text('Sign Out', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: HRTheme.error)),
          subtitle: Text('Log out from this device', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          trailing: Icon(Icons.chevron_right_rounded, color: HRTheme.textHint),
          onTap: _handleLogout,
        ),
      ]),
    );
  }

  Widget _infoTile(String label, String value, IconData icon, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero, dense: true,
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: HRTheme.primaryDark.withOpacity(0.07), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
        child: Icon(icon, size: 16, color: HRTheme.primaryDark),
      ),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
      subtitle: Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : HRTheme.textPrimary)),
    );
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HRTheme.radiusLG)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: HRTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              ),
              child: const Icon(Icons.logout_rounded, color: HRTheme.error, size: 20),
            ),
            const SizedBox(width: 10),
            Text('Sign Out', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out? You will need to log in again to access the app.',
          style: GoogleFonts.poppins(fontSize: 13, color: HRTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.poppins(color: HRTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: HRTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign Out', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SessionManager.fullLogout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomePage()),
          (route) => false,
        );
      }
    }
  }

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool _hideNew = true, _hideCurrent = true;
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXL))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Change Password', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(controller: currentCtrl, obscureText: _hideCurrent,
              decoration: InputDecoration(hintText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
                suffixIcon: IconButton(icon: Icon(_hideCurrent ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    onPressed: () => setSS(() => _hideCurrent = !_hideCurrent)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
            const SizedBox(height: 10),
            TextField(controller: newCtrl, obscureText: _hideNew,
              decoration: InputDecoration(hintText: 'New Password',
                prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                suffixIcon: IconButton(icon: Icon(_hideNew ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                    onPressed: () => setSS(() => _hideNew = !_hideNew)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
            const SizedBox(height: 10),
            TextField(controller: confirmCtrl, obscureText: true,
              decoration: InputDecoration(hintText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock_rounded, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
            const SizedBox(height: 16),
            HRPrimaryButton(label: 'Update Password', icon: Icons.save_rounded, onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Password updated successfully', style: GoogleFonts.poppins()),
                backgroundColor: HRTheme.success, behavior: SnackBarBehavior.floating,
              ));
            }),
            const SizedBox(height: 8),
          ]),
        ),
      )),
    );
  }
}
