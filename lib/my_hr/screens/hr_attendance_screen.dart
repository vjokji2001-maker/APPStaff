import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../theme/hr_theme.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

enum ReportFormat { pdf, excel }

extension ReportFormatX on ReportFormat {
  String get label => this == ReportFormat.pdf ? 'PDF' : 'Excel';
  String get extension => this == ReportFormat.pdf ? 'pdf' : 'csv';
}

class HRAttendanceScreen extends StatefulWidget {
  const HRAttendanceScreen({super.key});
  @override
  State<HRAttendanceScreen> createState() => _HRAttendanceScreenState();
}

class _HRAttendanceScreenState extends State<HRAttendanceScreen> {
  int _tab = 0;
  bool _isLoading = true;
  AttendanceSummary? _summary;
  List<AttendanceRecord> _records = [];
  List<double> _trendValues = [];
  List<String> _trendLabels = [];
  ReportFormat _reportFormat = ReportFormat.pdf;
  
  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    try {
      final now = DateTime.now();
      final monthYear = '${now.month.toString().padLeft(2, '0')}-${now.year}';
      final res = await HRApiService.getMyAttendance(monthYear: monthYear);
      final responseMap = Map<String, dynamic>.from(res);

      dynamic rawData = responseMap['data'] ?? responseMap['records'] ?? responseMap['attendance'] ?? res;
      if (rawData is Map) {
        rawData = rawData['data'] ?? rawData['records'] ?? rawData['attendance'] ?? rawData;
      }

      final records = <AttendanceRecord>[];
      if (rawData is List) {
        for (final item in rawData) {
          if (item is Map) {
            records.add(AttendanceRecord.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      final summaryData = responseMap['summary'] ??
          responseMap['attendanceSummary'] ??
          responseMap['attendanceSummaryDTO'] ??
          responseMap['summaryData'];
      final summary = summaryData is Map<String, dynamic>
          ? AttendanceSummary.fromJson(summaryData)
          : (summaryData is Map
              ? AttendanceSummary.fromJson(Map<String, dynamic>.from(summaryData))
              : AttendanceSummary.fromRecords(records));

      setState(() {
        _records = records;
        _summary = summary;
        _prepareAttendanceTrend(records);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
      setState(() {
        _summary = AttendanceSummary.empty();
        _records = [];
        _trendValues = [];
        _trendLabels = [];
        _isLoading = false;
      });
    }
  }

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
        Expanded(child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : IndexedStack(index: _tab, children: [
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
      decoration: BoxDecoration(color: Colors.white.withAlpha(38),
          borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
      child: const Icon(Icons.search, color: Colors.white, size: 20),
    ),
  );

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _todayDateLabel(DateTime date) {
    return '${_weekDay(date.weekday)}, ${date.day} ${_month(date.month)} ${date.year}';
  }

  Widget _infoBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(HRTheme.radiusFull),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: HRTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon, Color color) {
    return HRCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha((0.12 * 255).round()),
              borderRadius: BorderRadius.circular(HRTheme.radiusSM),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: HRTheme.textPrimary)),
        ],
      ),
    );
  }

Widget _buildTodayTab() {
  final today = _currentRecord;
  final summary = _summary ?? AttendanceSummary.empty();

  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2F4EAF), Color(0xFF2A84E5)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: HRTheme.primaryDark.withAlpha((0.18 * 255).round()),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_greeting(),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 8),
                    Text(_todayDateLabel(DateTime.now()),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 12),
                    Row(children: [
                      HRStatusBadge(
                        label: today?.status ?? 'Pending',
                        color: _statusColorForStatus(today?.status ?? 'pending'),
                        bgColor: _statusColorForStatus(today?.status ?? 'pending').withAlpha((0.16 * 255).round()),
                        icon: Icons.circle,
                        fontSize: 11,
                      ),
                      const SizedBox(width: 10),
                      Text('Attendance Status',
                          style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ]),
                  ],
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(Icons.event_available_rounded,
                    color: Colors.white, size: 44),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Row(children: [
          Expanded(
            child: HRCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punch In',
                      style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
                  const SizedBox(height: 10),
                  Text(today?.punchIn ?? DateFormat('hh:mm a').format(DateTime.now()),
                      style: GoogleFonts.poppins(
                          fontSize: 28, fontWeight: FontWeight.w800, color: HRTheme.success)),
                  const SizedBox(height: 8),
                  Text(today != null && today.punchIn != '–' ? 'Punched In' : 'Not Punched In',
                      style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: HRCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Punch Out',
                      style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
                  const SizedBox(height: 10),
                  Text(today?.punchOut ?? DateFormat('hh:mm a').format(DateTime.now()),
                      style: GoogleFonts.poppins(
                          fontSize: 28, fontWeight: FontWeight.w800, color: HRTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text(today != null && today.punchOut != '–' ? 'Punched Out' : 'Not Punched Out',
                      style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ]),

        const SizedBox(height: 18),

        HRCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  HRCircularProgress(
                    value: summary.attendancePercentage / 100,
                    label: 'Attendance Rate',
                    centerText: '${summary.attendancePercentage.toStringAsFixed(0)}%',
                    color: HRTheme.attendance,
                    size: 90,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attendance Overview',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(_attendanceInsight,
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: HRTheme.textSecondary, height: 1.5)),
                        const SizedBox(height: 16),
                        _infoBadge('Present', '${summary.present}', HRTheme.success),
                        const SizedBox(height: 10),
                        _infoBadge('Absent', '${summary.absent}', HRTheme.error),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              HRProgressBar(value: summary.attendancePercentage / 100, color: HRTheme.attendance, label: 'Monthly attendance progress'),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Row(children: [
          Expanded(child: _infoCard('Shift', today?.shiftCode ?? '-', Icons.schedule, HRTheme.primaryDark)),
          const SizedBox(width: 12),
          Expanded(child: _infoCard('Work Hours', today?.workHours ?? '-', Icons.timer, HRTheme.attendance)),
          const SizedBox(width: 12),
          Expanded(child: _infoCard('Day Type', today?.dayType ?? '-', Icons.calendar_month, HRTheme.cyan)),
        ]),

        const SizedBox(height: 18),

        HRCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Quick Summary', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _summaryMetricCard('${summary.present}', 'Present', HRTheme.success)),
                const SizedBox(width: 10),
                Expanded(child: _summaryMetricCard('${summary.absent}', 'Absent', HRTheme.error)),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _summaryMetricCard('${summary.late}', 'Late', HRTheme.warning)),
                const SizedBox(width: 10),
                Expanded(child: _summaryMetricCard('${summary.halfDay}', 'Half Day', HRTheme.teal)),
              ]),
            ],
          ),
        ),

        const SizedBox(height: 20),

        HRPrimaryButton(
          label: 'Apply Attendance Correction',
          icon: Icons.edit_calendar,
          color: HRTheme.attendance,
          onPressed: _showCorrectionSheet,
        ),
      ],
    ),
  );
}

  String _weekDay(int d) => ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][d - 1];
  String _month(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m - 1];

  Widget _buildHistoryTab() {
    if (_records.isEmpty) {
      return const HREmptyState(icon: Icons.calendar_today_rounded, title: 'No Records', subtitle: 'No attendance records found');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: ListView.separated(
        itemCount: _records.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (_, i) {
          final r = _records[i];
          return _AttendanceCard(record: r);
        },
      ),
    );
  }

  Widget _buildSummaryTab() {
    final s = _summary ?? AttendanceSummary.empty();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HRCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(title: 'Monthly Summary', icon: Icons.summarize_rounded),
                const SizedBox(height: 4),
                Text(_displayMonthYear,
                    style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HRCircularProgress(
                      value: s.attendancePercentage / 100,
                      label: 'Attendance Rate',
                      centerText: '${s.attendancePercentage.toStringAsFixed(0)}%',
                      color: HRTheme.attendance,
                      size: 92,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your attendance summary for the selected month.',
                              style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary, height: 1.6)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(child: _summaryBadge('Present', '${s.present}', HRTheme.success)),
                              const SizedBox(width: 10),
                              Expanded(child: _summaryBadge('Absent', '${s.absent}', HRTheme.error)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _summaryBadge('Working Days', '${s.totalWorkingDays}', HRTheme.primaryLight),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          HRCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(title: 'Summary Metrics', icon: Icons.grid_view_rounded),
                const SizedBox(height: 14),
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _summaryMetricCard('${s.totalWorkingDays}', 'Working Days', Colors.blueGrey)),
                        const SizedBox(width: 10),
                        Expanded(child: _summaryMetricCard('${s.present}', 'Present', HRTheme.success)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _summaryMetricCard('${s.absent}', 'Absent', HRTheme.error)),
                        const SizedBox(width: 10),
                        Expanded(child: _summaryMetricCard('${s.late}', 'Late Marks', HRTheme.warning)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _summaryMetricCard('${s.halfDay}', 'Half Day', HRTheme.teal)),
                        const SizedBox(width: 10),
                        Expanded(child: _summaryMetricCard('${s.leavesTaken}', 'On Leave', HRTheme.leave)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _summaryMetricCard('${s.holidays}', 'Holidays', HRTheme.cyan)),
                        const SizedBox(width: 10),
                        Expanded(child: _summaryMetricCard('${s.earlyExit}', 'Early Exit', HRTheme.pending)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          HRCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(title: 'Attendance Trend', icon: Icons.bar_chart_rounded),
                const SizedBox(height: 12),
                HRBarChart(
                  values: _trendValues.isNotEmpty ? _trendValues : List.generate(_trendLabels.isNotEmpty ? _trendLabels.length : 7, (_) => 0.0),
                  labels: _trendLabels.isNotEmpty ? _trendLabels : const ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
                  barColor: HRTheme.attendance,
                  maxValue: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          HRCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(title: 'Attendance Insights', icon: Icons.insights_rounded),
                const SizedBox(height: 10),
                Text(_attendanceInsight,
                    style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadReportCard(String title, String subtitle, IconData icon, Color color) {
    return GestureDetector(
      onTap: () => _downloadReport(title, format: _reportFormat),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(HRTheme.radiusXL),
          boxShadow: HRTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 18),
            Text(title,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary, height: 1.4)),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.download_rounded, color: color, size: 16),
                const SizedBox(width: 6),
                Text(_reportFormat.label,
                    style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HRTheme.radiusFull),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: HRTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(HRTheme.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary, height: 1.4)),
        ],
      ),
    );
  }

  Widget _reportFormatOption(ReportFormat format, IconData icon, String label) {
    final selected = _reportFormat == format;
    return GestureDetector(
      onTap: () => setState(() => _reportFormat = format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? HRTheme.attendance : HRTheme.bgLight,
          border: Border.all(color: selected ? HRTheme.attendance : HRTheme.divider),
          borderRadius: BorderRadius.circular(HRTheme.radiusMD),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : HRTheme.textPrimary),
            const SizedBox(width: 8),
            Text(label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : HRTheme.textPrimary,
                )),
          ],
        ),
      ),
    );
  }

  String get _displayMonthYear {
    final now = DateTime.now();
    return '${_month(now.month)} ${now.year}';
  }

  String get _attendanceInsight {
    final s = _summary ?? AttendanceSummary.empty();
    if (s.totalWorkingDays == 0) {
      return 'No attendance data available for this month yet.';
    }
    if (s.attendancePercentage >= 95) {
      return 'Excellent attendance this month. Keep the streak going!';
    }
    if (s.attendancePercentage >= 80) {
      return 'Good attendance. A few improvements can make this perfect.';
    }
    return 'You have room to improve your attendance this month.';
  }

  Color _statusColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present': return HRTheme.success;
      case 'late': return HRTheme.warning;
      case 'absent': return HRTheme.error;
      case 'leave': return HRTheme.info;
      case 'holiday': return HRTheme.teal;
      default: return HRTheme.textSecondary;
    }
  }

  DateTime? _parseRecordDate(String rawDate) {
    if (rawDate.isEmpty) return null;
    final parts = rawDate.split(RegExp(r'[\/\-]'));
    if (parts.length == 3) {
      // Accept both dd/MM/yyyy and yyyy-MM-dd
      if (parts[0].length == 4) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      } else {
        final d = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final y = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) return DateTime(y, m, d);
      }
    }
    return null;
  }

  AttendanceRecord? get _currentRecord {
    if (_records.isEmpty) return null;
    final today = DateTime.now();
    return _records.firstWhere(
      (record) {
        final date = _parseRecordDate(record.date);
        return date != null && date.year == today.year && date.month == today.month && date.day == today.day;
      },
      orElse: () => _records.first,
    );
  }

  void _prepareAttendanceTrend(List<AttendanceRecord> records) {
    if (records.isEmpty) {
      _trendValues = [];
      _trendLabels = [];
      return;
    }

    final sorted = [...records];
    sorted.sort((a, b) {
      final da = _parseRecordDate(a.date);
      final db = _parseRecordDate(b.date);
      if (da == null || db == null) return a.date.compareTo(b.date);
      return da.compareTo(db);
    });
    final trendRecords = sorted.take(7).toList();
    _trendLabels = trendRecords.map((record) {
      final date = _parseRecordDate(record.date);
      if (date != null) return _weekDay(date.weekday);
      return record.date;
    }).toList();
    _trendValues = trendRecords.map((record) => _parseWorkHours(record.workHours)).toList();
  }

  double _parseWorkHours(String value) {
    if (value.isEmpty || value == '–') return 0.0;
    final hourMatch = RegExp(r'(?:(\d+)h)').firstMatch(value);
    final minMatch = RegExp(r'(?:(\d+)m)').firstMatch(value);
    if (hourMatch != null || minMatch != null) {
      final hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
      final mins = minMatch != null ? int.parse(minMatch.group(1)!) : 0;
      return hours + mins / 60.0;
    }
    if (value.contains(':')) {
      final parts = value.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
      return h + m / 60.0;
    }
    return double.tryParse(value) ?? 0.0;
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HRCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(title: 'Attendance Reports', icon: Icons.file_download_rounded),
                const SizedBox(height: 8),
                Text('Download the attendance reports you need for audit, payroll, and correction.',
                    style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary, height: 1.5)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _downloadReportCard('Monthly Attendance', 'View complete monthly attendance data', Icons.calendar_month_rounded, HRTheme.attendance),
                    _downloadReportCard('Late Mark Report', 'See late entry details for the month', Icons.warning_amber_rounded, HRTheme.warning),
                    _downloadReportCard('Overtime Report', 'Review extra hours and approvals', Icons.timer_rounded, HRTheme.cyan),
                    _downloadReportCard('Yearly Summary', 'Export annual attendance overview', Icons.summarize_rounded, HRTheme.primaryDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          HRCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(title: 'Report Settings', icon: Icons.settings_rounded),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _infoCard('Selected Month', _displayMonthYear, Icons.calendar_today, HRTheme.primaryDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _infoCard('Selected Format', _reportFormat.label, _reportFormat == ReportFormat.pdf ? Icons.picture_as_pdf_rounded : Icons.grid_view_rounded, HRTheme.attendance)),
                ]),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _reportFormatOption(ReportFormat.pdf, Icons.picture_as_pdf_rounded, 'PDF'),
                    _reportFormatOption(ReportFormat.excel, Icons.grid_view_rounded, 'Excel'),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Choose the format above, then tap a report card to download it.',
                    style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleReportFormat() {
    setState(() {
      _reportFormat = _reportFormat == ReportFormat.pdf ? ReportFormat.excel : ReportFormat.pdf;
    });
  }

  Future<void> _downloadReport(String title, {required ReportFormat format}) async {
    try {
      final fileName = '${title.replaceAll(' ', '_')}_${_displayMonthYear.replaceAll(' ', '_')}.${format.extension}';
      final path = await FilePicker.platform.saveFile(
        dialogTitle: 'Save $fileName',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: [format.extension],
      );

      if (path == null) return;

      final bytes = format == ReportFormat.pdf
          ? await _generatePdfReport(title)
          : _generateCsvReport(title);

      final file = File(path);
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$fileName saved successfully', style: GoogleFonts.poppins()),
        backgroundColor: HRTheme.success,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to save report. Please try again.', style: GoogleFonts.poppins()),
        backgroundColor: HRTheme.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<Uint8List> _generatePdfReport(String title) async {
    final pdf = pw.Document();
    final selectedRecords = _recordsForReport(title);
    final summary = _summary ?? AttendanceSummary.empty();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return [
          pw.Text(title,
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Month: $_displayMonthYear', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
          pw.SizedBox(height: 16),
          if (title.contains('Yearly Summary'))
            pw.Column(children: [
              _pdfSummaryRow('Total Working Days', '${summary.totalWorkingDays}'),
              _pdfSummaryRow('Present', '${summary.present}'),
              _pdfSummaryRow('Absent', '${summary.absent}'),
              _pdfSummaryRow('Late', '${summary.late}'),
              _pdfSummaryRow('Half Day', '${summary.halfDay}'),
              _pdfSummaryRow('Holidays', '${summary.holidays}'),
              _pdfSummaryRow('On Leave', '${summary.leavesTaken}'),
              _pdfSummaryRow('Early Exit', '${summary.earlyExit}'),
              _pdfSummaryRow('Attendance %', '${summary.attendancePercentage.toStringAsFixed(1)}%'),
            ])
          else if (selectedRecords.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 20),
              child: pw.Text('No attendance records are available for this report.',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            )
          else
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: PdfColors.blue500),
              headers: const ['Date', 'Status', 'Punch In', 'Punch Out', 'Work Hours', 'Shift', 'Day Type', 'Extra Hours'],
              data: selectedRecords.map((record) => [
                record.date,
                record.status,
                record.punchIn,
                record.punchOut,
                record.workHours,
                record.shiftCode,
                record.dayType,
                record.extraHours,
              ]).toList(),
              cellAlignment: pw.Alignment.centerLeft,
            ),
        ];
      },
    ));

    return pdf.save();
  }

  pw.Widget _pdfSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  Uint8List _generateCsvReport(String title) {
    final selectedRecords = _recordsForReport(title);
    final buffer = StringBuffer();

    if (title.contains('Yearly Summary')) {
      final summary = _summary ?? AttendanceSummary.empty();
      buffer.writeln('Metric,Value');
      buffer.writeln('Total Working Days,${summary.totalWorkingDays}');
      buffer.writeln('Present,${summary.present}');
      buffer.writeln('Absent,${summary.absent}');
      buffer.writeln('Late,${summary.late}');
      buffer.writeln('Half Day,${summary.halfDay}');
      buffer.writeln('Holidays,${summary.holidays}');
      buffer.writeln('On Leave,${summary.leavesTaken}');
      buffer.writeln('Early Exit,${summary.earlyExit}');
      buffer.writeln('Attendance %,${summary.attendancePercentage.toStringAsFixed(1)}');
    } else {
      buffer.writeln('Date,Status,Punch In,Punch Out,Work Hours,Shift,Day Type,Extra Hours');
      if (selectedRecords.isEmpty) {
        buffer.writeln('No records available for this report.');
      } else {
        for (final record in selectedRecords) {
          buffer.writeln(
            '${_csvEscape(record.date)},${_csvEscape(record.status)},${_csvEscape(record.punchIn)},${_csvEscape(record.punchOut)},${_csvEscape(record.workHours)},${_csvEscape(record.shiftCode)},${_csvEscape(record.dayType)},${_csvEscape(record.extraHours)}',
          );
        }
      }
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  String _csvEscape(String value) => '"${value.replaceAll('"', '""')}"';

  List<AttendanceRecord> _recordsForReport(String title) {
    if (title.contains('Late')) {
      return _records.where((record) => record.isLate || record.status.toLowerCase().contains('late')).toList();
    }
    if (title.contains('Overtime')) {
      return _records.where((record) => record.extraHours.isNotEmpty && record.extraHours != '00:00:00').toList();
    }
    return _records;
  }

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

  String get _safeStatus => record.status.isNotEmpty ? record.status : 'Pending';

  Color get _statusColor {
    switch (_safeStatus.toLowerCase()) {
      case 'present': return HRTheme.success;
      case 'late': return HRTheme.warning;
      case 'absent': return HRTheme.error;
      case 'leave': return HRTheme.info;
      case 'holiday': return HRTheme.teal;
      case 'pending': return HRTheme.textSecondary;
      default: return HRTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HRCard(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.calendar_today_rounded, color: _statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.date,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('Shift: ${record.shiftCode}',
                        style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
                    const SizedBox(height: 10),
                    Text(record.status.isNotEmpty ? record.status : 'Pending',
                        style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
                  ],
                ),
              ),
              HRStatusBadge(
                label: _safeStatus,
                color: _statusColor,
                bgColor: _statusColor.withAlpha(25),
                icon: Icons.circle,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _detailChip('Punch In', record.punchIn, Icons.login, HRTheme.success),
              _detailChip('Punch Out', record.punchOut, Icons.logout, HRTheme.error),
              _detailChip('Work Hours', record.workHours, Icons.timer, HRTheme.attendance),
              _detailChip('Extra', record.extraHours, Icons.add_task_rounded, HRTheme.cyan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailChip(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(HRTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textSecondary)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: HRTheme.textPrimary)),
            ],
          ),
        ],
      ),
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
