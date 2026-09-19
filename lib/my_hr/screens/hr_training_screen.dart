import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRTrainingScreen extends StatefulWidget {
  const HRTrainingScreen({super.key});
  @override
  State<HRTrainingScreen> createState() => _HRTrainingScreenState();
}

class _HRTrainingScreenState extends State<HRTrainingScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['All Courses', 'Upcoming', 'Completed'];

  List<TrainingCourse> _coursesForTab() {
    final all = HRMockData.trainings;
    switch (_tabIndex) {
      case 1:
        return all.where((t) => t.status == 'Upcoming').toList();
      case 2:
        return all.where((t) => t.status == 'Completed').toList();
      default:
        return all;
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
            title: 'Training',
            subtitle: 'Courses & certifications',
          ),
          HRTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
            activeColor: HRTheme.training,
          ),
          Expanded(child: _buildCourseList()),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    final courses = _coursesForTab();
    if (courses.isEmpty) {
      return const HREmptyState(
        icon: Icons.school_outlined,
        title: 'No Courses',
        subtitle: 'No courses in this category',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_tabIndex == 0) _buildSummaryRow(),
        ...courses.map((t) => _buildCourseCard(t)),
      ],
    );
  }

  Widget _buildSummaryRow() {
    final all = HRMockData.trainings;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          _statChip('Total', '${all.length}', HRTheme.training),
          const SizedBox(width: 8),
          _statChip(
            'Ongoing',
            '${all.where((t) => t.status == "Ongoing").length}',
            HRTheme.warning,
          ),
          const SizedBox(width: 8),
          _statChip(
            'Completed',
            '${all.where((t) => t.status == "Completed").length}',
            HRTheme.success,
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(HRTheme.radiusMD),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: HRTheme.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCourseCard(TrainingCourse t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = t.status == 'Completed'
        ? HRTheme.success
        : t.status == 'Upcoming'
        ? HRTheme.pending
        : HRTheme.info;
    final statusBg = t.status == 'Completed'
        ? HRTheme.successLight
        : t.status == 'Upcoming'
        ? HRTheme.pendingLight
        : HRTheme.infoLight;
    final modeColor = t.mode == 'Online'
        ? HRTheme.teal
        : t.mode == 'Classroom'
        ? HRTheme.primaryLight
        : HRTheme.warning;
    return HRCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HRTheme.training.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: Icon(
                  _modeIcon(t.mode),
                  size: 20,
                  color: HRTheme.training,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : HRTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      t.category,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: HRTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  HRStatusBadge(
                    label: t.status,
                    color: statusColor,
                    bgColor: statusBg,
                  ),
                  const SizedBox(height: 4),
                  HRStatusBadge(
                    label: t.mode,
                    color: modeColor,
                    bgColor: modeColor.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (t.status == 'Ongoing') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: HRTheme.textSecondary,
                  ),
                ),
                Text(
                  '${(t.progress * 100).round()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HRTheme.training,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            HRProgressBar(
              value: t.progress,
              color: HRTheme.training,
              height: 6,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              _infoChip(Icons.person_outlined, t.instructor),
              const SizedBox(width: 12),
              _infoChip(Icons.calendar_today_outlined, t.startDate),
              const SizedBox(width: 12),
              _infoChip(Icons.access_time_outlined, t.duration),
            ],
          ),
          if (t.status == 'Completed' && t.hasCertificate) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: HRTheme.successLight,
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                  border: Border.all(
                    color: HRTheme.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      size: 16,
                      color: HRTheme.success,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Download Certificate',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: HRTheme.success,
                      ),
                    ),
                    if (t.certificateDate != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '· ${t.certificateDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: HRTheme.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: HRTheme.textHint),
      const SizedBox(width: 3),
      Flexible(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: HRTheme.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  IconData _modeIcon(String mode) {
    switch (mode) {
      case 'Online':
        return Icons.laptop_mac_rounded;
      case 'Classroom':
        return Icons.school_rounded;
      default:
        return Icons.devices_rounded;
    }
  }
}
