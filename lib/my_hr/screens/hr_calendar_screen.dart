import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';
import '../utils/holiday_date_label.dart';

class HRCalendarScreen extends StatefulWidget {
  const HRCalendarScreen({super.key});
  @override
  State<HRCalendarScreen> createState() => _HRCalendarScreenState();
}

class _HRCalendarScreenState extends State<HRCalendarScreen> {
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
      if (!mounted) return;
      setState(() {
        _holidays = dataList.map((e) => HRHoliday.fromJson(e)).toList();
        _isLoadingHolidays = false;
      });
    } catch (e) {
      debugPrint('Error fetching holidays: $e');
      if (!mounted) return;
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
          HRGradientHeader(title: 'Holidays', subtitle: 'View all holidays'),
          Expanded(child: _buildHolidaysList()),
        ],
      ),
    );
  }

  Widget _buildHolidaysList() {
    if (_isLoadingHolidays) {
      return const Center(child: CircularProgressIndicator());
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final holidays = _holidays;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                          HolidayDateLabel.fromDate(h.date).day,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          HolidayDateLabel.fromDate(h.date).month,
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
}
