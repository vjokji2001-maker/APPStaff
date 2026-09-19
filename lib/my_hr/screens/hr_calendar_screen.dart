import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRCalendarScreen extends StatefulWidget {
  const HRCalendarScreen({super.key});
  @override
  State<HRCalendarScreen> createState() => _HRCalendarScreenState();
}

class _HRCalendarScreenState extends State<HRCalendarScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = [
    'Holidays',
    'Leave Calendar',
    'Shift Calendar',
    'Birthdays',
  ];

  bool _isLoadingHolidays = true;
  List<HRHoliday> _holidays = [];

  @override
  void initState() {
    super.initState();
    _fetchHolidays();
  }

  Future<void> _fetchHolidays() async {
    try {
      final dynamic res = await HRApiService.getHolidays();
      final dataList = (res is Map && res['data'] != null)
          ? res['data'] as List
          : res as List<dynamic>;
      setState(() {
        _holidays = dataList.map((e) => HRHoliday.fromJson(e)).toList();
        _isLoadingHolidays = false;
      });
    } catch (e) {
      print('Error fetching holidays: $e');
      setState(() {
        _holidays = [];
        _isLoadingHolidays = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(
        children: [
          HRGradientHeader(
            title: 'Calendar',
            subtitle: 'Holidays, leaves & shifts',
          ),
          HRTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
            activeColor: HRTheme.calendar,
          ),
          Expanded(child: _buildTab()),
        ],
      ),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 0:
        return _buildHolidaysTab();
      case 1:
        return _buildLeaveCalendarTab();
      case 2:
        return _buildShiftCalendarTab();
      case 3:
        return _buildBirthdaysTab();
      default:
        return _buildHolidaysTab();
    }
  }

  Widget _buildMiniCalendar({
    required String monthYear,
    required int startOffset,
    required int daysInMonth,
    required Set<int> highlightDays,
    required Color highlightColor,
    required String Function(int) tooltip,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayHeaders = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return HRCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            monthYear,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : HRTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: dayHeaders
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: HRTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startOffset) return const SizedBox();
              final day = i - startOffset + 1;
              final isHighlighted = highlightDays.contains(day);
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isHighlighted ? highlightColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isHighlighted
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isHighlighted
                          ? Colors.white
                          : (isDark ? Colors.white70 : HRTheme.textPrimary),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHolidaysTab() {
    if (_isLoadingHolidays) {
      return const Center(child: CircularProgressIndicator());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final holidays = _holidays;
    // Holiday dates in Aug (offset 5 for Sat start)
    final augHolidays = <int>{15, 25};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiniCalendar(
            monthYear: 'August 2026',
            startOffset: 5,
            daysInMonth: 31,
            highlightDays: augHolidays,
            highlightColor: HRTheme.calendar,
            tooltip: (d) => '',
          ),
          const SizedBox(height: 16),
          const HRSectionHeader(
            title: 'All Holidays',
            icon: Icons.event_rounded,
          ),
          ...holidays.map(
            (h) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? HRTheme.bgCardDark : Colors.white,
                borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                boxShadow: HRTheme.cardShadow,
                border: h.isOptional
                    ? Border.all(color: HRTheme.warning.withValues(alpha: 0.3))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: HRTheme.moduleGradient(HRTheme.calendar),
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          h.date.split(' ')[0],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          h.date.split(' ')[1].substring(0, 3),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          h.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : HRTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${h.day} · ${h.type}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: HRTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (h.isOptional)
                    HRStatusBadge(
                      label: 'Optional',
                      color: HRTheme.warning,
                      bgColor: HRTheme.warningLight,
                    )
                  else
                    HRStatusBadge(
                      label: h.type,
                      color: HRTheme.calendar,
                      bgColor: HRTheme.calendar.withValues(alpha: 0.1),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLeaveCalendarTab() {
    // Mark leave days in July: 16
    final leaveDays = <int>{16};
    final leaveApps = HRMockData.leaveApplications;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiniCalendar(
            monthYear: 'July 2026',
            startOffset: 2,
            daysInMonth: 31,
            highlightDays: leaveDays,
            highlightColor: HRTheme.leave,
            tooltip: (d) => '',
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              _legendDot(HRTheme.leave, 'Leave Taken'),
              const SizedBox(width: 16),
              _legendDot(HRTheme.pending, 'Pending'),
              const SizedBox(width: 16),
              _legendDot(HRTheme.calendar, 'Holiday'),
            ],
          ),
          const SizedBox(height: 16),
          const HRSectionHeader(
            title: 'Leave Applications',
            icon: Icons.beach_access_rounded,
          ),
          ...leaveApps.map((l) {
            final statusColor = l.status == 'Approved'
                ? HRTheme.success
                : l.status == 'Pending'
                ? HRTheme.pending
                : HRTheme.error;
            final statusBg = l.status == 'Approved'
                ? HRTheme.successLight
                : l.status == 'Pending'
                ? HRTheme.pendingLight
                : HRTheme.errorLight;
            return HRCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                    child: Icon(
                      Icons.beach_access_rounded,
                      size: 18,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.leaveType,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${l.fromDate}${l.days > 1 ? ' – ${l.toDate}' : ''} · ${l.days} day(s)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: HRTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  HRStatusBadge(
                    label: l.status,
                    color: statusColor,
                    bgColor: statusBg,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildShiftCalendarTab() {
    final schedule = HRMockData.shiftSchedule;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Highlight shift days in July
    final shiftDays = <int>{21, 22, 23, 24};
    final offDays = <int>{26, 27};
    final afternoonDays = <int>{25};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMiniCalendar(
            monthYear: 'July 2026',
            startOffset: 2,
            daysInMonth: 31,
            highlightDays: shiftDays,
            highlightColor: HRTheme.shift,
            tooltip: (d) => '',
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _legendDot(HRTheme.shift, 'Morning'),
              const SizedBox(width: 16),
              _legendDot(HRTheme.warning, 'Afternoon'),
              const SizedBox(width: 16),
              _legendDot(HRTheme.textSecondary, 'Day Off'),
            ],
          ),
          const SizedBox(height: 16),
          const HRSectionHeader(
            title: 'Shift Schedule',
            icon: Icons.schedule_rounded,
          ),
          ...schedule.map((s) {
            final isOff = s.shiftName == 'Off';
            final color = s.shiftName == 'Morning'
                ? HRTheme.shift
                : s.shiftName == 'Afternoon'
                ? HRTheme.warning
                : HRTheme.textSecondary;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: s.isToday
                    ? HRTheme.shift.withValues(alpha: 0.08)
                    : (isDark ? HRTheme.bgCardDark : Colors.white),
                borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                border: s.isToday
                    ? Border.all(color: HRTheme.shift.withValues(alpha: 0.4))
                    : null,
                boxShadow: HRTheme.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.day,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                        Text(
                          s.date.split(' ')[0],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isOff ? 'Day Off' : '${s.shiftName} Shift',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : HRTheme.textPrimary,
                          ),
                        ),
                        if (!isOff)
                          Text(
                            '${s.startTime} – ${s.endTime} · ${s.ward}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: HRTheme.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (s.isToday)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: HRTheme.shift.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                      ),
                      child: Text(
                        'Today',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: HRTheme.shift,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBirthdaysTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final birthdays = HRMockData.birthdays;
    final anniversaries = HRMockData.anniversaries;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HRSectionHeader(
            title: 'Birthdays This Month',
            icon: Icons.cake_rounded,
          ),
          ...birthdays.map(
            (b) => HRCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: b.isToday
                        ? HRTheme.primaryDark
                        : Colors.amber.shade100,
                    child: Text(
                      b.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: b.isToday ? Colors.white : Colors.brown.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : HRTheme.textPrimary,
                          ),
                        ),
                        Text(
                          b.designation,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: HRTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  b.isToday
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusFull,
                            ),
                          ),
                          child: Text(
                            '🎂 Today',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        )
                      : Text(
                          b.date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: HRTheme.textHint,
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const HRSectionHeader(
            title: 'Work Anniversaries',
            icon: Icons.celebration_rounded,
          ),
          ...anniversaries.map(
            (a) => HRCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: a.isToday
                        ? HRTheme.teal
                        : HRTheme.teal.withValues(alpha: 0.15),
                    child: Text(
                      a.initials,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : HRTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${a.years} Year${a.years > 1 ? 's' : ''} at City Hospital · ${a.designation}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: HRTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  a.isToday
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: HRTheme.teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusFull,
                            ),
                          ),
                          child: Text(
                            '⭐ Today',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: HRTheme.teal,
                            ),
                          ),
                        )
                      : Text(
                          a.date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: HRTheme.textHint,
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textSecondary),
      ),
    ],
  );
}
