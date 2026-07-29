import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRAttendanceScreen extends StatefulWidget {
  const HRAttendanceScreen({super.key});
  @override
  State<HRAttendanceScreen> createState() => _HRAttendanceScreenState();
}

class _HRAttendanceScreenState extends State<HRAttendanceScreen> {
  int _tab = 0;
  bool _checkedIn = false;
  String _punchTime = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(
          title: 'My Attendance',
          subtitle: 'Track your attendance & reports',
          actions: [_searchAction()],
        ),
        HRTabBar(
          tabs: const ['Today', 'History', 'Summary', 'Report'],
          selectedIndex: _tab,
          onTabChanged: (i) => setState(() => _tab = i),
          activeColor: HRTheme.attendance,
        ),
        Expanded(child: IndexedStack(index: _tab, children: [
          _buildTodayTab(),
          _buildHistoryTab(),
          _buildSummaryTab(),
          _buildReportTab(),
        ])),
      ]),
    );
  }

  Widget _searchAction() => Padding(
    padding: const EdgeInsets.only(right: 4),
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
      child: const Icon(Icons.search, color: Colors.white, size: 20),
    ),
  );

  void _punch() {
    final now = TimeOfDay.now();
    final t = '${now.hourOfPeriod.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')} ${now.period.name.toUpperCase()}';
    setState(() { _checkedIn = !_checkedIn; _punchTime = t; });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_checkedIn ? 'Punched In at $t' : 'Punched Out at $t', style: GoogleFonts.poppins()),
      backgroundColor: _checkedIn ? HRTheme.success : HRTheme.error, behavior: SnackBarBehavior.floating,
    ));
  }

  Widget _buildTodayTab() {
    final now = DateTime.now();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Punch Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _checkedIn ? HRTheme.successGradient : HRTheme.primaryGradient,
            borderRadius: BorderRadius.circular(HRTheme.radiusXL),
            boxShadow: HRTheme.elevatedShadow,
          ),
          child: Column(children: [
            Text(_checkedIn ? 'You are Checked In' : 'Not Checked In',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('${_weekDay(now.weekday)}, ${now.day} ${_month(now.month)} ${now.year}',
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _punch,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_checkedIn ? Icons.logout : Icons.login, color: Colors.white, size: 30),
                  Text(_checkedIn ? 'Punch Out' : 'Punch In',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _punchInfo('Punch In', '08:02 AM', Icons.login),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _punchInfo('Punch Out', _checkedIn ? '–' : _punchTime.isEmpty ? '–' : _punchTime, Icons.logout),
              Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
              _punchInfo('Work Hours', '6h 22m', Icons.timer_outlined),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        HRCard(child: Column(children: [
          HRInfoRow(label: 'Status', value: 'Present', icon: Icons.check_circle_rounded),
          HRInfoRow(label: 'Shift', value: 'Morning (8:00 AM – 4:00 PM)', icon: Icons.schedule_rounded),
          HRInfoRow(label: 'Ward / Location', value: 'Cardiology – Ward 3', icon: Icons.location_on_rounded),
          HRInfoRow(label: 'Late Mark', value: 'No', icon: Icons.warning_outlined, isLast: true),
        ])),
        const SizedBox(height: 12),
        HRPrimaryButton(
          label: 'Apply Attendance Correction',
          icon: Icons.edit_calendar_rounded,
          color: HRTheme.attendance,
          onPressed: () => _showCorrectionSheet(),
        ),
      ]),
    );
  }

  Widget _punchInfo(String label, String val, IconData icon) => Column(children: [
    Icon(icon, color: Colors.white70, size: 18),
    const SizedBox(height: 4),
    Text(val, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 10)),
  ]);

  String _weekDay(int d) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d - 1];
  String _month(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: HRMockData.attendanceRecords.length,
      itemBuilder: (_, i) {
        final r = HRMockData.attendanceRecords[i];
        return _AttendanceCard(record: r);
      },
    );
  }

  Widget _buildSummaryTab() {
    final s = HRMockData.attendanceSummary;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Monthly Summary – July 2026', icon: Icons.summarize_rounded),
          HRCircularProgress(
            value: s.attendancePercentage / 100, label: 'Attendance Rate',
            centerText: '${s.attendancePercentage.toStringAsFixed(0)}%',
            color: HRTheme.attendance, size: 100,
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2, mainAxisSpacing: 10, crossAxisSpacing: 10,
            children: [
              _summaryTile('${s.totalWorkingDays}', 'Working Days', Colors.blueGrey),
              _summaryTile('${s.present}', 'Present', HRTheme.success),
              _summaryTile('${s.absent}', 'Absent', HRTheme.error),
              _summaryTile('${s.late}', 'Late Marks', HRTheme.warning),
              _summaryTile('${s.earlyExit}', 'Early Exit', HRTheme.pending),
              _summaryTile('${s.halfDay}', 'Half Day', Colors.indigo),
              _summaryTile('${s.holidays}', 'Holidays', HRTheme.teal),
              _summaryTile('${s.leavesTaken}', 'On Leave', HRTheme.leave),
            ],
          ),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Monthly Trend', icon: Icons.bar_chart_rounded),
          HRBarChart(
            values: HRMockData.monthlyPresence.map((v) => v.toDouble()).toList(),
            labels: const ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'],
            barColor: HRTheme.attendance, maxValue: 26,
          ),
        ])),
      ]),
    );
  }

  Widget _summaryTile(String val, String lbl, Color color) => Container(
    decoration: BoxDecoration(
      color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(HRTheme.radiusSM),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(val, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      Text(lbl, textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.textSecondary)),
    ]),
  );

  Widget _buildReportTab() => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'Download Reports', icon: Icons.file_download_rounded),
        ...[
          ('Monthly Attendance Report – July 2026', Icons.calendar_month_rounded),
          ('Late Mark Report – July 2026', Icons.warning_amber_rounded),
          ('Overtime Report – Q2 2026', Icons.timer_rounded),
          ('Yearly Attendance Report – 2026', Icons.summarize_rounded),
        ].map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: HRCard(
            color: HRTheme.bgLight,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Downloading ${r.$1}', style: GoogleFonts.poppins()),
                  backgroundColor: HRTheme.success, behavior: SnackBarBehavior.floating)),
            child: Row(children: [
              Icon(r.$2, color: HRTheme.attendance, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(r.$1, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500))),
              const Icon(Icons.download_rounded, color: HRTheme.textHint, size: 18),
            ]),
          ),
        )),
      ])),
    ]),
  );

  void _showCorrectionSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => _CorrectionBottomSheet(),
    );
  }
}

// ── Attendance record card ────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  const _AttendanceCard({required this.record});

  Color get _statusColor {
    switch (record.status) {
      case 'Present': return HRTheme.success;
      case 'Late': return HRTheme.warning;
      case 'Absent': return HRTheme.error;
      case 'Leave': return HRTheme.info;
      case 'Holiday': return HRTheme.teal;
      default: return HRTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HRCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM),
          ),
          child: Icon(Icons.calendar_today_rounded, color: _statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record.date, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          if (record.punchIn != '–')
            Row(children: [
              Icon(Icons.login, size: 12, color: HRTheme.success),
              const SizedBox(width: 4),
              Text(record.punchIn, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
              const SizedBox(width: 10),
              Icon(Icons.logout, size: 12, color: HRTheme.error),
              const SizedBox(width: 4),
              Text(record.punchOut, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ])
          else
            Text(record.status, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          HRStatusBadge(label: record.status, color: _statusColor, bgColor: _statusColor.withOpacity(0.1)),
          if (record.workHours != '–') ...[
            const SizedBox(height: 4),
            Text(record.workHours, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          ],
        ]),
      ]),
    );
  }
}

class _CorrectionBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20, left: 16, right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? HRTheme.bgCardDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXXL)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(HRTheme.radiusFull)))),
        const SizedBox(height: 16),
        Text('Attendance Correction Request', style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w700, color: HRTheme.textPrimary)),
        const SizedBox(height: 16),
        TextFormField(decoration: InputDecoration(labelText: 'Date',
            prefixIcon: const Icon(Icons.calendar_today_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
        const SizedBox(height: 12),
        TextFormField(decoration: InputDecoration(labelText: 'Correct Punch In Time',
            prefixIcon: const Icon(Icons.login),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
        const SizedBox(height: 12),
        TextFormField(decoration: InputDecoration(labelText: 'Correct Punch Out Time',
            prefixIcon: const Icon(Icons.logout),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
        const SizedBox(height: 12),
        TextFormField(maxLines: 3, decoration: InputDecoration(labelText: 'Reason',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
        const SizedBox(height: 16),
        HRPrimaryButton(label: 'Submit Request', icon: Icons.send_rounded,
            color: HRTheme.attendance,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Correction request submitted!', style: GoogleFonts.poppins()),
                backgroundColor: HRTheme.success, behavior: SnackBarBehavior.floating));
            }),
      ]),
    );
  }
}
