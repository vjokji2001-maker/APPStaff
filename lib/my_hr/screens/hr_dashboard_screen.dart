import 'package:flutter/material.dart';
import 'package:staff_mate/presentation/face_attendance/face_attendance_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../data/hr_api_service.dart';
import '../../services/user_information_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';
import 'hr_attendance_screen.dart';
import 'hr_leave_screen.dart';
import 'hr_payroll_screen.dart';
import 'hr_shift_screen.dart';
import 'hr_profile_screen.dart';
import 'hr_documents_screen.dart';
import 'hr_performance_screen.dart';
import 'hr_training_screen.dart';
import 'hr_assets_screen.dart';
import 'hr_loan_screen.dart';
import 'hr_expenses_screen.dart';
import 'hr_notifications_screen.dart';
import 'hr_requests_screen.dart';
import 'hr_calendar_screen.dart';
import 'hr_approvals_screen.dart';
import 'hr_policies_screen.dart';
import 'hr_settings_screen.dart';

class HRDashboardScreen extends StatefulWidget {
  const HRDashboardScreen({super.key});

  @override
  State<HRDashboardScreen> createState() => _HRDashboardScreenState();
}

class _HRDashboardScreenState extends State<HRDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  final _scrollCtrl = ScrollController();

  bool _isCheckedIn = false;
  String _punchTime = '';

  HREmployee? _emp;
  AttendanceSummary? _summary;
  List<LeaveBalance> _leaveBalances = [];
  List<SalarySlip> _salarySlips = [];
  List<HRHoliday> _holidays = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _animCtrl.forward();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _fetchProfile(),
      _fetchAttendance(),
      _fetchLeaveBalances(),
      _fetchPayroll(),
      _fetchHolidays(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
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
      
      if (userData != null) {
        String first = userData['firstName']?.toString() ?? '';
        String last = userData['lastName']?.toString() ?? '';
        String init = userData['initial']?.toString() ?? '';
        
        // Try pre-built fullName first, else build from parts
        String fullName = userData['fullName']?.toString() ?? '';
        if (fullName.isEmpty) {
          fullName = '$init $first $last'.trim();
        }
        if (fullName.isEmpty) fullName = userData['userId']?.toString() ?? 'Employee';
        
        String clinicName = userData['clinicName']?.toString() ?? '';
        String job = userData['jobtitle']?.toString() ?? '';
        String role = job.isNotEmpty ? job : 'Medical Staff';
        String dept = userData['department']?.toString() ?? '';
        if (dept.isEmpty) dept = clinicName.length > 20 ? clinicName.substring(0, 20) : (clinicName.isNotEmpty ? clinicName : 'General');
        
        String avatarStr = first.isNotEmpty ? first[0].toUpperCase() : (fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U');
        
        debugPrint('HR Dashboard - Name: $fullName | Role: $role | Dept: $dept');
        
        if (mounted) {
          setState(() {
            _emp = HREmployee(
              id: userData!['userId']?.toString() ?? '1',
              name: fullName,
              designation: role,
              department: dept,
              employeeCode: userData!['userId']?.toString() ?? 'EMP001',
              email: userData!['email']?.toString() ?? '',
              phone: userData!['mobileNo']?.toString() ?? '',
              dob: '',
              gender: '',
              bloodGroup: '',
              maritalStatus: '',
              joiningDate: '',
              employmentType: 'Full-time',
              workLocation: userData!['location']?.toString() ?? 'Main Hospital',
              reportingManager: '',
              shift: 'General',
              grade: '',
              pfNumber: '',
              uanNumber: '',
              esiNumber: '',
              panNumber: '',
              aadhaarLast4: '',
              address: userData!['address']?.toString() ?? '',
              emergencyContact: '',
              emergencyRelation: '',
              emergencyPhone: '',
              avatarInitials: avatarStr,
            );
          });
        }
        return;
      }
      
      final data = await HRApiService.getProfile();
      final empData = data['data'] ?? data;
      if (mounted) setState(() => _emp = HREmployee.fromJson(empData));
    } catch (e) {
      if (mounted) setState(() => _emp = HREmployee.empty());
    }
  }

  Future<void> _fetchAttendance() async {
    try {
      final now = DateTime.now();
      final monthYear = '${now.month.toString().padLeft(2, '0')}-${now.year}';
      final res = await HRApiService.getMyAttendance(monthYear: monthYear);
      final data = res['data'] ?? res;
      if (mounted) {
        setState(() => _summary = AttendanceSummary.fromJson(data['summary'] ?? data));
      }
    } catch (e) {
      if (mounted) setState(() => _summary = AttendanceSummary.empty());
    }
  }

  Future<void> _fetchLeaveBalances() async {
    try {
      final dynamic res = await HRApiService.getLeaveBalances();
      final dataList = (res is Map && res['data'] != null)
          ? res['data'] as List
          : res as List<dynamic>;
      if (mounted) {
        setState(() => _leaveBalances = dataList.map((e) => LeaveBalance.fromJson(e)).toList());
      }
    } catch (_) {}
  }

  Future<void> _fetchPayroll() async {
    try {
      final res = await HRApiService.getPayrollSummary();
      final dataList = (res is Map && res['data'] != null)
          ? res['data'] as List
          : (res is List ? res : []);
      if (mounted) {
        setState(() => _salarySlips = dataList.map((e) => SalarySlip.fromJson(e)).toList());
      }
    } catch (_) {}
  }

  Future<void> _fetchHolidays() async {
    try {
      final dynamic res = await HRApiService.getHolidays();
      final dataList = (res is Map && res['data'] != null)
          ? res['data'] as List
          : res as List<dynamic>;
      if (mounted) {
        setState(() => _holidays = dataList.map((e) => HRHoliday.fromJson(e)).toList());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _handlePunch() {
    final now = TimeOfDay.now();
    final formatted =
        '${now.hourOfPeriod.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ${now.period.name.toUpperCase()}';
    setState(() {
      _isCheckedIn = !_isCheckedIn;
      _punchTime = formatted;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isCheckedIn ? 'Punched In at $_punchTime' : 'Punched Out at $_punchTime',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: _isCheckedIn ? HRTheme.success : HRTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  String _dayName(int d) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];
  String _monthName(int m) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];


@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final emp = _emp ?? HREmployee.empty();
  final summary = _summary ?? AttendanceSummary.empty();
  final unread = HRMockData.notifications.where((n) => !n.isRead).length;
  final pendingApprovals = HRMockData.approvals.where((a) => a.status == 'Pending').length;

  return Scaffold(
    backgroundColor: isDark ? HRTheme.bgDark : const Color(0xFFF7F8FA),
    body: FadeTransition(
      opacity: _fadeAnim,
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader(emp, unread, isDark)),

          // Punch Card
          if (!_isLoading) SliverToBoxAdapter(child: _buildPunchCard(isDark)),

          // Key Metrics
          if (!_isLoading) SliverToBoxAdapter(child: _buildKeyMetrics(summary)),

          // Quick Actions
          if (!_isLoading)
            SliverToBoxAdapter(child: _buildQuickActions(pendingApprovals, unread)),

          // Attendance Snapshot
          if (!_isLoading)
            SliverToBoxAdapter(child: _buildAttendanceSnapshot(summary)),

          // Leave
          if (!_isLoading) SliverToBoxAdapter(child: _buildLeaveSection()),

          // Salary
          if (!_isLoading) SliverToBoxAdapter(child: _buildSalarySummary()),

          // Holidays
          if (!_isLoading) SliverToBoxAdapter(child: _buildUpcomingHolidays()),

          // Announcements
          if (!_isLoading) SliverToBoxAdapter(child: _buildAnnouncements()),

          // Birthdays
          if (!_isLoading) SliverToBoxAdapter(child: _buildBirthdays(isDark)),

          // Training
          if (!_isLoading) SliverToBoxAdapter(child: _buildTrainingReminders()),

          // Document Expiry
          if (!_isLoading) SliverToBoxAdapter(child: _buildDocExpirySection()),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    ),
  );
}

  // ─────────────────────────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(HREmployee emp, int unread, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: HRTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              _headerIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => Navigator.maybePop(context),
              ),
              const Spacer(),
              _headerIconButton(
                icon: Icons.notifications_outlined,
                onTap: () => _navigate(const HRNotificationsScreen()),
                badge: unread > 0 ? unread : null,
              ),
              const SizedBox(width: 10),
              _headerIconButton(
                icon: Icons.settings_outlined,
                onTap: () => _navigate(const HRSettingsScreen()),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Profile row
          Row(
            children: [
              GestureDetector(
                onTap: () => _navigate(const HRProfileScreen()),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.22),
                  child: Text(
                    emp.avatarInitials,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_greeting()} 👋',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      emp.name,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${emp.designation} · ${emp.department}',
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Employee code chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Text(
                  emp.employeeCode,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.location_on_outlined, color: Colors.white70, size: 15),
                const SizedBox(width: 4),
                Text(
                  'Main Campus',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge != null && badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // PUNCH CARD
  // ─────────────────────────────────────────────────────────────────
  Widget _buildPunchCard(bool isDark) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? HRTheme.bgDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Attendance',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : HRTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_dayName(now.weekday)}, ${now.day} ${_monthName(now.month)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: HRTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _punchChip(Icons.login_rounded, 'In', '08:02 AM', HRTheme.success),
                      const SizedBox(width: 10),
                      _punchChip(
                        Icons.logout_rounded,
                        'Out',
                        _isCheckedIn ? '--:--' : (_punchTime.isEmpty ? '--:--' : _punchTime),
                        HRTheme.error,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _handlePunch,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isCheckedIn
                        ? [HRTheme.error, const Color(0xFFFF6B6B)]
                        : [HRTheme.success, HRTheme.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isCheckedIn ? HRTheme.error : HRTheme.success).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isCheckedIn ? Icons.logout_rounded : Icons.login_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isCheckedIn ? 'OUT' : 'IN',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _punchChip(IconData icon, String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: color)),
              Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // KEY METRICS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildKeyMetrics(AttendanceSummary summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _metricCard(
              label: 'Present',
              value: '${summary.present}',
              icon: Icons.check_circle_rounded,
              color: HRTheme.success,
              onTap: () => _navigate(const HRAttendanceScreen()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _metricCard(
              label: 'Absent',
              value: '${summary.absent}',
              icon: Icons.cancel_rounded,
              color: HRTheme.error,
              onTap: () => _navigate(const HRAttendanceScreen()),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _metricCard(
              label: 'Leave',
              value: _leaveBalances.isNotEmpty
                  ? '${_leaveBalances.first.available}'
                  : '0',
              icon: Icons.beach_access_rounded,
              color: HRTheme.leave,
              onTap: () => _navigate(const HRLeaveScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: HRTheme.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: HRTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildQuickActions(int pendingApprovals, int unread) {
    final actions = [
      _QuickAction('Face Attendance', Icons.face, HRTheme.attendance,
          () => _navigate(const FaceAttendancePage())),
      _QuickAction('Attendance', Icons.fingerprint_rounded, HRTheme.attendance,
          () => _navigate(const HRAttendanceScreen())),
      _QuickAction('Leave', Icons.calendar_today_rounded, HRTheme.leave,
          () => _navigate(const HRLeaveScreen())),
      // _QuickAction('Payroll', Icons.payments_rounded, HRTheme.payroll,
      //     () => _navigate(const HRPayrollScreen())),
      _QuickAction('Shift', Icons.schedule_rounded, HRTheme.shift,
          // () => _navigate(const HRShiftScreen())),
      // _QuickAction('Requests', Icons.send_rounded, HRTheme.requests,
      //     () => _navigate(const HRRequestsScreen()), badge: pendingApprovals),
      // _QuickAction('Approvals', Icons.approval_rounded, HRTheme.approvals,r
      //     () => _navigate(const HRApprovalsScreen()), badge: pendingApprovals),
      // _QuickAction('Documents', Icons.folder_rounded, HRTheme.documents,
      //     () => _navigate(const HRDocumentsScreen())),
      // _QuickAction('More', Icons.grid_view_rounded, HRTheme.primaryDark,
          () {}), // you can open a bottom sheet here
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HRTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 14,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: actions.map((a) {
              return GestureDetector(
                onTap: a.onTap,
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: a.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(a.icon, color: a.color, size: 24),
                        ),
                        if (a.badge != null && a.badge! > 0)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${a.badge}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      a.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: HRTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ATTENDANCE SNAPSHOT
  // ─────────────────────────────────────────────────────────────────
  Widget _buildAttendanceSnapshot(AttendanceSummary summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: HRCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HRSectionHeader(
              title: 'Attendance Snapshot',
              icon: Icons.insights_rounded,
              actionLabel: 'Details',
              onAction: () => _navigate(const HRAttendanceScreen()),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _snapshotTile(
                    'Working Days',
                    '${summary.totalWorkingDays}',
                    HRTheme.primaryDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _snapshotTile(
                    'Attendance %',
                    '${summary.attendancePercentage.toStringAsFixed(1)}%',
                    HRTheme.attendance,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _snapshotTile('Late', '${summary.late}', HRTheme.warning),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _snapshotTile('Half Day', '${summary.halfDay}', HRTheme.teal),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _snapshotTile(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: HRTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // LEAVE
  // ─────────────────────────────────────────────────────────────────
  Widget _buildLeaveSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HRSectionHeader(
              title: 'Leave Balance',
              icon: Icons.beach_access_rounded,
              actionLabel: 'Apply',
              onAction: () => _navigate(const HRLeaveScreen()),
            ),
            if (_leaveBalances.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No leave data available')),
              )
            else
              ..._leaveBalances.map((lb) {
                final color = () {
                  try {
                    return Color(int.parse(lb.colorHex.replaceFirst('#', '0xFF')));
                  } catch (_) {
                    return HRTheme.leave;
                  }
                }();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lb.leaveType,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${lb.available} / ${lb.total}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: HRTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      HRProgressBar(
                        value: lb.total > 0 ? lb.available / lb.total : 0,
                        color: color,
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // SALARY
  // ─────────────────────────────────────────────────────────────────
  Widget _buildSalarySummary() {
    if (_salarySlips.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: HRCard(
          onTap: () => _navigate(const HRPayrollScreen()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HRSectionHeader(
                title: 'Salary Summary',
                icon: Icons.payments_rounded,
                actionLabel: 'Payslip',
                onAction: () => _navigate(const HRPayrollScreen()),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('No payroll data available')),
              ),
            ],
          ),
        ),
      );
    }

    final slip = _salarySlips.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(
        onTap: () => _navigate(const HRPayrollScreen()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HRSectionHeader(
              title: 'Salary Summary',
              icon: Icons.payments_rounded,
              actionLabel: 'Payslip',
              onAction: () => _navigate(const HRPayrollScreen()),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: HRTheme.purpleGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Net Salary · ${slip.month} ${slip.year}',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${slip.netSalary.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _salaryChip(
                              'Gross ₹${(slip.grossEarnings / 1000).toStringAsFixed(0)}k',
                              Colors.white.withOpacity(0.2),
                            ),
                            const SizedBox(width: 8),
                            _salaryChip(
                              '-₹${(slip.totalDeductions / 1000).toStringAsFixed(1)}k',
                              Colors.red.withOpacity(0.35),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.download_rounded, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _salaryChip(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // HOLIDAYS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildUpcomingHolidays() {
    final upcoming = _holidays.take(3).toList();
    if (upcoming.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HRSectionHeader(
              title: 'Upcoming Holidays',
              icon: Icons.event_note_rounded,
              actionLabel: 'All',
              onAction: () => _navigate(const HRCalendarScreen()),
            ),
            ...upcoming.map((h) {
              final parts = h.date.split(' ');
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: HRTheme.primaryDark.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            parts.isNotEmpty ? parts[0] : '--',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: HRTheme.primaryDark,
                            ),
                          ),
                          if (parts.length > 1)
                            Text(
                              parts[1].substring(0, 3),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: HRTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${h.day} · ${h.type}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: HRTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (h.isOptional)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: HRTheme.warningLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Optional',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: HRTheme.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // ANNOUNCEMENTS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildAnnouncements() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HRSectionHeader(
            title: 'Announcements',
            icon: Icons.campaign_rounded,
          ),
          const SizedBox(height: 8),
          ...HRMockData.announcements.map(
            (a) => HRAnnounceCard(
              title: a.title,
              content: a.content,
              date: a.date,
              priority: a.priority,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // BIRTHDAYS
  // ─────────────────────────────────────────────────────────────────
  Widget _buildBirthdays(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: HRCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HRSectionHeader(
              title: 'Birthdays & Anniversaries',
              icon: Icons.celebration_rounded,
            ),
            ...HRMockData.birthdays.map((b) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: b.isToday ? HRTheme.primaryDark : Colors.amber.shade200,
                  radius: 18,
                  child: Text(
                    b.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: b.isToday ? Colors.white : Colors.brown.shade700,
                    ),
                  ),
                ),
                title: Text(
                  b.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : HRTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  b.designation,
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary),
                ),
                trailing: b.isToday
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '🎂 Today',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        b.date,
                        style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint),
                      ),
              );
            }),
            const Divider(height: 20),
            ...HRMockData.anniversaries.map((a) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: CircleAvatar(
                  backgroundColor: a.isToday ? HRTheme.teal : Colors.blue.shade100,
                  radius: 18,
                  child: Text(
                    a.initials,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                title: Text(
                  a.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : HRTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  '${a.years} Year Work Anniversary',
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary),
                ),
                trailing: a.isToday
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: HRTheme.teal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⭐ Today',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: HRTheme.teal,
                          ),
                        ),
                      )
                    : Text(
                        a.date,
                        style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint),
                      ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // TRAINING
  // ─────────────────────────────────────────────────────────────────
  Widget _buildTrainingReminders() {
    final upcoming = HRMockData.trainings.where((t) => t.status == 'Upcoming').toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HRSectionHeader(
              title: 'Training Reminders',
              icon: Icons.school_rounded,
              actionLabel: 'View All',
              onAction: () => _navigate(const HRTrainingScreen()),
            ),
            if (upcoming.isEmpty)
              const HREmptyState(
                icon: Icons.school_outlined,
                title: 'No Upcoming Training',
                subtitle: 'You are all caught up!',
              )
            else
              ...upcoming.map((t) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: HRTheme.training.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.school_rounded, color: HRTheme.training, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.title,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${t.startDate} · ${t.duration} · ${t.mode}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: HRTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: HRTheme.pendingLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Soon',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: HRTheme.pending,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // DOCUMENT EXPIRY
  // ─────────────────────────────────────────────────────────────────
  Widget _buildDocExpirySection() {
    final expiring = HRMockData.documents.where((d) => d.isExpiringSoon).toList();
    if (expiring.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HRTheme.warningLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: HRTheme.warning.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: HRTheme.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Document Expiry Alert',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: HRTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...expiring.map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.description_outlined, size: 15, color: HRTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        d.name,
                        style: GoogleFonts.poppins(fontSize: 13),
                      ),
                    ),
                    Text(
                      'Exp: ${d.expiryDate}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: HRTheme.warning,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _navigate(const HRDocumentsScreen()),
              child: Text(
                'Manage Documents →',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: HRTheme.warning,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ───────────────────────────────────────────────────────
class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  const _QuickAction(this.label, this.icon, this.color, this.onTap, {this.badge});
}