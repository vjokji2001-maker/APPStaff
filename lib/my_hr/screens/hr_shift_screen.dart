import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRShiftScreen extends StatefulWidget {
  const HRShiftScreen({super.key});
  @override
  State<HRShiftScreen> createState() => _HRShiftScreenState();
}

class _HRShiftScreenState extends State<HRShiftScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Weekly', 'Monthly Roster', 'Swap Requests'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      floatingActionButton: _tabIndex == 2
          ? FloatingActionButton.extended(
              onPressed: _showSwapRequestSheet,
              backgroundColor: HRTheme.shift,
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
              label: Text('Request Swap', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: Column(children: [
        HRGradientHeader(
          title: 'My Shift',
          subtitle: 'Schedule & swap requests',
        ),
        HRTabBar(
          tabs: _tabs,
          selectedIndex: _tabIndex,
          onTabChanged: (i) => setState(() => _tabIndex = i),
          activeColor: HRTheme.shift,
        ),
        Expanded(child: _buildTab()),
      ]),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 0: return _buildWeeklyTab();
      case 1: return _buildMonthlyRosterTab();
      case 2: return _buildSwapRequestsTab();
      default: return _buildWeeklyTab();
    }
  }

  Widget _buildWeeklyTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedule = HRMockData.shiftSchedule;
    final today = schedule.firstWhere((s) => s.isToday, orElse: () => schedule.first);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Today's shift highlight
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: HRTheme.tealGradient,
            borderRadius: BorderRadius.circular(HRTheme.radiusLG),
            boxShadow: HRTheme.elevatedShadow,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text("Today's Shift", style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text(today.type, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(today.shiftName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.access_time_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('${today.startTime} – ${today.endTime}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.local_hospital_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(today.ward, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        const HRSectionHeader(title: 'This Week', icon: Icons.view_week_outlined),
        ...schedule.map((s) => _buildShiftCard(s, isDark)),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildShiftCard(ShiftSchedule s, bool isDark) {
    final isOff = s.shiftName == 'Off';
    final typeColor = _shiftColor(s.shiftName);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: s.isToday
            ? HRTheme.shift.withOpacity(0.08)
            : (isDark ? HRTheme.bgCardDark : Colors.white),
        borderRadius: BorderRadius.circular(HRTheme.radiusMD),
        border: s.isToday ? Border.all(color: HRTheme.shift.withOpacity(0.4), width: 1.5) : null,
        boxShadow: HRTheme.cardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: s.isToday ? HRTheme.shift.withOpacity(0.15) : typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(HRTheme.radiusSM),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(s.day, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: s.isToday ? HRTheme.shift : typeColor)),
            Text(s.date.split(' ')[0], style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w800, color: s.isToday ? HRTheme.shift : typeColor)),
          ]),
        ),
        title: Text(isOff ? 'Day Off' : s.shiftName,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                color: isOff ? HRTheme.textHint : (isDark ? Colors.white : HRTheme.textPrimary))),
        subtitle: isOff ? Text('Weekly Off', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint))
            : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${s.startTime} – ${s.endTime}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
                Text(s.ward, style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textHint)),
              ]),
        trailing: s.isToday
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: HRTheme.shift.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text('Today', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: HRTheme.shift)),
              )
            : (!isOff ? HRStatusBadge(label: s.type, color: typeColor, bgColor: typeColor.withOpacity(0.1)) : null),
      ),
    );
  }

  Color _shiftColor(String name) {
    switch (name) {
      case 'Morning': return HRTheme.info;
      case 'Afternoon': return HRTheme.warning;
      case 'Night': return HRTheme.primaryDark;
      default: return HRTheme.textSecondary;
    }
  }

  Widget _buildMonthlyRosterTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Mini calendar for July 2026
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // July 2026 starts on Wed (index 2)
    const startOffset = 2;
    const daysInMonth = 31;
    final schedule = HRMockData.shiftSchedule;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        HRCard(child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('July 2026', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : HRTheme.textPrimary)),
            Row(children: [
              Icon(Icons.chevron_left_rounded, color: HRTheme.textSecondary),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: HRTheme.textSecondary),
            ]),
          ]),
          const SizedBox(height: 12),
          Row(children: days.map((d) => Expanded(child: Center(child: Text(d.substring(0, 1),
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: HRTheme.textSecondary))))).toList()),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final shift = schedule.where((s) {
                final d = int.tryParse(s.date.split(' ')[0]);
                return d == day;
              }).firstOrNull;
              final isToday = shift?.isToday ?? false;
              final isOff = shift?.shiftName == 'Off';
              final color = shift == null ? Colors.transparent : _shiftColor(shift.shiftName);
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday ? HRTheme.shift : (shift != null ? color.withOpacity(0.15) : Colors.transparent),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text('$day', style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isToday ? Colors.white : (isOff ? HRTheme.textHint : (isDark ? Colors.white70 : HRTheme.textPrimary)),
                ))),
              );
            },
          ),
          const SizedBox(height: 12),
          // Legend
          Wrap(spacing: 12, runSpacing: 6, children: [
            _legendItem('Morning', HRTheme.info),
            _legendItem('Afternoon', HRTheme.warning),
            _legendItem('Night', HRTheme.primaryDark),
            _legendItem('Today', HRTheme.shift),
          ]),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Shift Summary', icon: Icons.bar_chart_rounded),
          _summaryRow('Morning Shifts', '${schedule.where((s) => s.shiftName == 'Morning').length}', HRTheme.info),
          _summaryRow('Afternoon Shifts', '${schedule.where((s) => s.shiftName == 'Afternoon').length}', HRTheme.warning),
          _summaryRow('Days Off', '${schedule.where((s) => s.shiftName == 'Off').length}', HRTheme.textSecondary),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textSecondary)),
    ]);
  }

  Widget _summaryRow(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: HRTheme.textPrimary)),
        Text(val, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _buildSwapRequestsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final swaps = HRMockData.swapRequests;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        if (swaps.isEmpty)
          const HREmptyState(icon: Icons.swap_horiz_rounded, title: 'No Swap Requests', subtitle: 'Tap + to request a shift swap')
        else
          ...swaps.map((s) => HRCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Swap with ${s.requestTo}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : HRTheme.textPrimary)),
                HRStatusBadge(
                  label: s.status,
                  color: s.status == 'Approved' ? HRTheme.success : s.status == 'Pending' ? HRTheme.pending : HRTheme.error,
                  bgColor: s.status == 'Approved' ? HRTheme.successLight : s.status == 'Pending' ? HRTheme.pendingLight : HRTheme.errorLight,
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _dateChip('My Date', s.myDate, HRTheme.info),
                const SizedBox(width: 8),
                const Icon(Icons.swap_horiz_rounded, size: 18, color: HRTheme.textSecondary),
                const SizedBox(width: 8),
                _dateChip('Their Date', s.theirDate, HRTheme.warning),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: HRTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(child: Text(s.reason, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary))),
              ]),
              const SizedBox(height: 4),
              Text('Requested on ${s.requestedOn}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
            ]),
          )),
      ],
    );
  }

  Widget _dateChip(String label, String date, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 9, color: color)),
      Text(date, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]),
  );

  void _showSwapRequestSheet() {
    final toCtrl = TextEditingController();
    final myDateCtrl = TextEditingController();
    final theirDateCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXL))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('New Shift Swap Request', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _formField('Request To (Colleague)', toCtrl, Icons.person_outlined),
            const SizedBox(height: 10),
            _formField('My Shift Date', myDateCtrl, Icons.calendar_today_outlined),
            const SizedBox(height: 10),
            _formField('Their Shift Date', theirDateCtrl, Icons.event_outlined),
            const SizedBox(height: 10),
            _formField('Reason', reasonCtrl, Icons.notes_rounded, maxLines: 2),
            const SizedBox(height: 16),
            HRPrimaryButton(label: 'Submit Request', icon: Icons.send_rounded, color: HRTheme.shift, onPressed: () => Navigator.pop(ctx)),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _formField(String hint, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl, maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.poppins(fontSize: 13, color: HRTheme.textHint),
        prefixIcon: Icon(icon, size: 18, color: HRTheme.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
