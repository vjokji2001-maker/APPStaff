import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
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

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          _isCheckedIn ? 'Punched In at $_punchTime' : 'Punched Out at $_punchTime',
          style: GoogleFonts.poppins()),
      backgroundColor: _isCheckedIn ? HRTheme.success : HRTheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emp = HRMockData.employee;
    final unread = HRMockData.notifications.where((n) => !n.isRead).length;
    final pendingApprovals = HRMockData.approvals.where((a) => a.status == 'Pending').length;

    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          controller: _scrollCtrl,
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(emp, unread)),
            SliverToBoxAdapter(child: _buildPunchCard()),
            SliverToBoxAdapter(child: _buildStatRow()),
            SliverToBoxAdapter(child: _buildModuleGrid(pendingApprovals, unread)),
            SliverToBoxAdapter(child: _buildAttendanceChart()),
            SliverToBoxAdapter(child: _buildLeaveSection()),
            SliverToBoxAdapter(child: _buildUpcomingHolidays()),
            SliverToBoxAdapter(child: _buildSalarySummary()),
            SliverToBoxAdapter(child: _buildAnnouncements()),
            SliverToBoxAdapter(child: _buildBirthdays()),
            SliverToBoxAdapter(child: _buildTrainingReminders()),
            SliverToBoxAdapter(child: _buildDocExpirySection()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(emp, int unread) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16, right: 16, bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: HRTheme.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(HRTheme.radiusXXL),
          bottomRight: Radius.circular(HRTheme.radiusXXL),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _navigate(const HRNotificationsScreen()),
            child: Stack(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
              ),
              if (unread > 0)
                Positioned(
                  top: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$unread',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _navigate(const HRSettingsScreen()),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              ),
              child: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          GestureDetector(
            onTap: () => _navigate(const HRProfileScreen()),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.25),
              child: Text(emp.avatarInitials,
                  style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Good ${_greeting()}, 👋',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            Text(emp.name,
                style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${emp.designation} · ${emp.department}',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
          ])),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(HRTheme.radiusSM),
          ),
          child: Row(children: [
            const Icon(Icons.badge_outlined, color: Colors.white70, size: 16),
            const SizedBox(width: 6),
            Text(emp.employeeCode,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text('Main Campus',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
          ]),
        ),
      ]),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildPunchCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Today\'s Attendance',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : HRTheme.textPrimary)),
            const SizedBox(height: 2),
            Text('${_dayName(now.weekday)}, ${now.day} ${_monthName(now.month)} ${now.year}',
                style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            const SizedBox(height: 8),
            Row(children: [
              _punchChip(Icons.login, 'In', '08:02 AM', HRTheme.success),
              const SizedBox(width: 12),
              _punchChip(Icons.logout, 'Out', _isCheckedIn ? '--:--' : _punchTime.isEmpty ? '--:--' : _punchTime, HRTheme.error),
            ]),
          ])),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handlePunch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70, height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isCheckedIn
                      ? [HRTheme.error, HRTheme.errorLight.withOpacity(0.5)]
                      : [HRTheme.success, HRTheme.teal],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(
                  color: (_isCheckedIn ? HRTheme.error : HRTheme.success).withOpacity(0.4),
                  blurRadius: 12, offset: const Offset(0, 4),
                )],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(_isCheckedIn ? Icons.logout : Icons.login, color: Colors.white, size: 24),
                Text(_isCheckedIn ? 'Out' : 'In',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _punchChip(IconData icon, String label, String time, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(HRTheme.radiusSM),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 5),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 9, color: color)),
          Text(time, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ]),
      ]),
    );
  }

  String _dayName(int d) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d - 1];
  String _monthName(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  Widget _buildStatRow() {
    final summary = HRMockData.attendanceSummary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(children: [
        Expanded(child: HRStatCard(
          title: 'Present', value: '${summary.present}',
          icon: Icons.check_circle_outline, gradient: HRTheme.successGradient,
          subtitle: 'This month', onTap: () => _navigate(const HRAttendanceScreen()),
        )),
        const SizedBox(width: 10),
        Expanded(child: HRStatCard(
          title: 'Leave Balance', value: '${HRMockData.leaveBalances.first.available}',
          icon: Icons.beach_access_outlined, gradient: HRTheme.tealGradient,
          subtitle: 'Annual', onTap: () => _navigate(const HRLeaveScreen()),
        )),
        const SizedBox(width: 10),
        Expanded(child: HRStatCard(
          title: 'Net Salary', value: '₹44k',
          icon: Icons.account_balance_wallet_outlined, gradient: HRTheme.purpleGradient,
          subtitle: 'July 2026', onTap: () => _navigate(const HRPayrollScreen()),
        )),
      ]),
    );
  }

  Widget _buildModuleGrid(int pendingApprovals, int unread) {
    final modules = [
      // _Module('My Profile', Icons.person_rounded, HRTheme.profile, () => _navigate(const HRProfileScreen()), 0),
      _Module('Attendance', Icons.fingerprint_rounded, HRTheme.attendance, () => _navigate(const HRAttendanceScreen()), 0),
      _Module('My Leave', Icons.calendar_today_rounded, HRTheme.leave, () => _navigate(const HRLeaveScreen()), 1),
      _Module('Payroll', Icons.payments_rounded, HRTheme.payroll, () => _navigate(const HRPayrollScreen()), 0),
      _Module('My Shift', Icons.schedule_rounded, HRTheme.shift, () => _navigate(const HRShiftScreen()), 0),
      // _Module('Documents', Icons.folder_rounded, HRTheme.documents, () => _navigate(const HRDocumentsScreen()), 1),
      // _Module('Performance', Icons.trending_up_rounded, HRTheme.performance, () => _navigate(const HRPerformanceScreen()), 0),
      // _Module('Training', Icons.school_rounded, HRTheme.training, () => _navigate(const HRTrainingScreen()), 2),
      // _Module('Assets', Icons.devices_rounded, HRTheme.assets, () => _navigate(const HRAssetsScreen()), 0),
      // _Module('My Loan', Icons.account_balance_rounded, HRTheme.loan, () => _navigate(const HRLoanScreen()), 0),
      // _Module('Expenses', Icons.receipt_long_rounded, HRTheme.expenses, () => _navigate(const HRExpensesScreen()), 2),
      // _Module('Requests', Icons.send_rounded, HRTheme.requests, () => _navigate(const HRRequestsScreen()), 3),
      // _Module('Approvals', Icons.approval_rounded, HRTheme.approvals, () => _navigate(const HRApprovalsScreen()), pendingApprovals),
      // _Module('Notifications', Icons.notifications_rounded, HRTheme.notifications, () => _navigate(const HRNotificationsScreen()), unread),
      // _Module('Calendar', Icons.event_rounded, HRTheme.calendar, () => _navigate(const HRCalendarScreen()), 0),
      // _Module('Policies', Icons.policy_rounded, HRTheme.policies, () => _navigate(const HRPoliciesScreen()), 0),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'HR Modules', icon: Icons.grid_view_rounded),
        GridView.count(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4, mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 0.78,
          children: modules.map((m) => HRModuleTile(
            label: m.label, icon: m.icon, color: m.color,
            onTap: m.onTap, badgeCount: m.badge > 0 ? m.badge : null,
          )).toList(),
        ),
      ]),
    );
  }

  Widget _buildAttendanceChart() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summary = HRMockData.attendanceSummary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRSectionHeader(
          title: 'Weekly Attendance', icon: Icons.bar_chart_rounded,
          actionLabel: 'Full Report', onAction: () => _navigate(const HRAttendanceScreen()),
        ),
        HRBarChart(
          values: HRMockData.weeklyHours,
          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          barColor: HRTheme.attendance, maxValue: 10,
        ),
        const SizedBox(height: 16),
        Divider(color: isDark ? HRTheme.dividerDark : HRTheme.divider),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _attStat('${summary.present}', 'Present', HRTheme.success),
          _attStat('${summary.absent}', 'Absent', HRTheme.error),
          _attStat('${summary.late}', 'Late', HRTheme.warning),
          _attStat('${summary.leavesTaken}', 'On Leave', HRTheme.teal),
        ]),
      ])),
    );
  }

  Widget _attStat(String val, String lbl, Color color) => Column(children: [
    Text(val, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
    Text(lbl, style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textSecondary)),
  ]);

  Widget _buildLeaveSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRSectionHeader(
          title: 'Leave Summary', icon: Icons.beach_access_rounded,
          actionLabel: 'Apply', onAction: () => _navigate(const HRLeaveScreen()),
        ),
        ...HRMockData.leaveBalances.map((lb) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(lb.leaveType,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
                      color: HRTheme.textPrimary)),
              Text('${lb.available} / ${lb.total}',
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ]),
            const SizedBox(height: 4),
            HRProgressBar(
              value: lb.total > 0 ? lb.available / lb.total : 0,
              color: Color(int.parse(lb.colorHex.replaceFirst('#', '0xFF'))),
            ),
          ]),
        )),
      ])),
    );
  }

  Widget _buildUpcomingHolidays() {
    final upcoming = HRMockData.holidays.take(3).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRSectionHeader(title: 'Upcoming Holidays', icon: Icons.event_note_rounded,
            actionLabel: 'All', onAction: () => _navigate(const HRCalendarScreen())),
        ...upcoming.map((h) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: HRTheme.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(h.date.split(' ')[0], style: GoogleFonts.poppins(fontSize: 14,
                    fontWeight: FontWeight.w800, color: HRTheme.primaryDark)),
                Text(h.date.split(' ')[1].substring(0, 3),
                    style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.textSecondary)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${h.day} · ${h.type}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ])),
            if (h.isOptional)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: HRTheme.warningLight,
                  borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                ),
                child: Text('Optional', style: GoogleFonts.poppins(fontSize: 9,
                    fontWeight: FontWeight.w600, color: HRTheme.warning)),
              ),
          ]),
        )),
      ])),
    );
  }

  Widget _buildSalarySummary() {
    final slip = HRMockData.salarySlips.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(
        onTap: () => _navigate(const HRPayrollScreen()),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HRSectionHeader(title: 'Salary Summary', icon: Icons.payments_rounded,
              actionLabel: 'Payslip', onAction: () => _navigate(const HRPayrollScreen())),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: HRTheme.purpleGradient,
              borderRadius: BorderRadius.circular(HRTheme.radiusMD),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Net Salary – ${slip.month} ${slip.year}',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                Text('₹${slip.netSalary.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Row(children: [
                  _salaryChip('Gross ₹${(slip.grossEarnings / 1000).toStringAsFixed(0)}k', Colors.white.withOpacity(0.2)),
                  const SizedBox(width: 8),
                  _salaryChip('-₹${(slip.totalDeductions / 1000).toStringAsFixed(1)}k', Colors.red.withOpacity(0.3)),
                ]),
              ])),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15), shape: BoxShape.circle,
                ),
                child: const Icon(Icons.download_rounded, color: Colors.white, size: 22),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _salaryChip(String text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
    child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Widget _buildAnnouncements() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'HR Announcements', icon: Icons.campaign_rounded),
        ...HRMockData.announcements.map((a) => HRAnnounceCard(
          title: a.title, content: a.content, date: a.date, priority: a.priority,
        )),
      ]),
    );
  }

  Widget _buildBirthdays() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'Birthdays & Anniversaries', icon: Icons.celebration_rounded),
        ...HRMockData.birthdays.map((b) => ListTile(
          contentPadding: EdgeInsets.zero, dense: true,
          leading: CircleAvatar(
            backgroundColor: b.isToday ? HRTheme.primaryDark : Colors.amber.shade200,
            radius: 18,
            child: Text(b.initials, style: GoogleFonts.poppins(fontSize: 12,
                fontWeight: FontWeight.w700,
                color: b.isToday ? Colors.white : Colors.brown.shade700)),
          ),
          title: Text(b.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : HRTheme.textPrimary)),
          subtitle: Text(b.designation, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          trailing: b.isToday
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100, borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                  ),
                  child: Text('🎂 Today', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600)))
              : Text(b.date, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
        )),
        const Divider(),
        ...HRMockData.anniversaries.map((a) => ListTile(
          contentPadding: EdgeInsets.zero, dense: true,
          leading: CircleAvatar(
            backgroundColor: a.isToday ? HRTheme.teal : Colors.blue.shade100,
            radius: 18,
            child: Text(a.initials, style: GoogleFonts.poppins(fontSize: 12,
                fontWeight: FontWeight.w700, color: Colors.white)),
          ),
          title: Text(a.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : HRTheme.textPrimary)),
          subtitle: Text('${a.years} Year Work Anniversary', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          trailing: a.isToday
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: HRTheme.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                  ),
                  child: Text('⭐ Today', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: HRTheme.teal)))
              : Text(a.date, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
        )),
      ])),
    );
  }

  Widget _buildTrainingReminders() {
    final upcoming = HRMockData.trainings.where((t) => t.status == 'Upcoming').toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRSectionHeader(title: 'Training Reminders', icon: Icons.school_rounded,
            actionLabel: 'View All', onAction: () => _navigate(const HRTrainingScreen())),
        if (upcoming.isEmpty)
          const HREmptyState(icon: Icons.school_outlined, title: 'No Upcoming Training',
              subtitle: 'You are all caught up!')
        else
          ...upcoming.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HRTheme.training.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: Icon(Icons.school_rounded, color: HRTheme.training, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                Text('${t.startDate} · ${t.duration} · ${t.mode}',
                    style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: HRTheme.pendingLight, borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                ),
                child: Text('Soon', style: GoogleFonts.poppins(fontSize: 9,
                    fontWeight: FontWeight.w600, color: HRTheme.pending)),
              ),
            ]),
          )),
      ])),
    );
  }

  Widget _buildDocExpirySection() {
    final expiring = HRMockData.documents.where((d) => d.isExpiringSoon).toList();
    if (expiring.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HRTheme.warningLight,
          borderRadius: BorderRadius.circular(HRTheme.radiusMD),
          border: Border.all(color: HRTheme.warning.withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.warning_amber_rounded, color: HRTheme.warning, size: 18),
            const SizedBox(width: 8),
            Text('Document Expiry Alert', style: GoogleFonts.poppins(fontSize: 13,
                fontWeight: FontWeight.w700, color: HRTheme.warning)),
          ]),
          const SizedBox(height: 8),
          ...expiring.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: [
              const Icon(Icons.description_outlined, size: 14, color: HRTheme.warning),
              const SizedBox(width: 6),
              Expanded(child: Text(d.name,
                  style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textPrimary))),
              Text('Exp: ${d.expiryDate}',
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.warning, fontWeight: FontWeight.w600)),
            ]),
          )),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _navigate(const HRDocumentsScreen()),
            child: Text('Manage Documents →',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: HRTheme.warning)),
          ),
        ]),
      ),
    );
  }
}

class _Module {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final int badge;
  const _Module(this.label, this.icon, this.color, this.onTap, this.badge);
}
