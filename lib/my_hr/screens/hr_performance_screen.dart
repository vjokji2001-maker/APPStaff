import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRPerformanceScreen extends StatefulWidget {
  const HRPerformanceScreen({super.key});
  @override
  State<HRPerformanceScreen> createState() => _HRPerformanceScreenState();
}

class _HRPerformanceScreenState extends State<HRPerformanceScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Goals', 'Reviews', 'Awards', 'Overview'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(
        children: [
          HRGradientHeader(
            title: 'Performance',
            subtitle: 'Goals, reviews & awards',
          ),
          HRTabBar(
            tabs: _tabs,
            selectedIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
            activeColor: HRTheme.performance,
          ),
          Expanded(child: _buildTab()),
        ],
      ),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 0:
        return _buildGoalsTab();
      case 1:
        return _buildReviewsTab();
      case 2:
        return _buildAwardsTab();
      case 3:
        return _buildOverviewTab();
      default:
        return _buildGoalsTab();
    }
  }

  Widget _buildGoalsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goals = HRMockData.goals;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary row
        Row(
          children: [
            _goalStat('Total', '${goals.length}', HRTheme.performance),
            const SizedBox(width: 10),
            _goalStat(
              'Achieved',
              '${goals.where((g) => g.status == 'Achieved').length}',
              HRTheme.success,
            ),
            const SizedBox(width: 10),
            _goalStat(
              'In Progress',
              '${goals.where((g) => g.status == 'In Progress').length}',
              HRTheme.warning,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...goals.map((g) => _buildGoalCard(g, isDark)),
      ],
    );
  }

  Widget _goalStat(String label, String val, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(HRTheme.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 22,
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

  Widget _buildGoalCard(PerformanceGoal g, bool isDark) {
    final statusColor = g.status == 'Achieved'
        ? HRTheme.success
        : HRTheme.warning;
    return HRCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HRCircularProgress(
            value: g.progressPercent,
            label: g.category,
            centerText: '${(g.progressPercent * 100).round()}%',
            color: statusColor,
            size: 64,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        g.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : HRTheme.textPrimary,
                        ),
                      ),
                    ),
                    HRStatusBadge(
                      label: g.status,
                      color: statusColor,
                      bgColor: g.status == 'Achieved'
                          ? HRTheme.successLight
                          : HRTheme.warningLight,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  g.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: HRTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 12,
                      color: HRTheme.textHint,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Target: ${g.targetValue.toInt()} · Achieved: ${g.achievedValue.toInt()}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: HRTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Deadline: ${g.deadline}',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: HRTheme.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviews = HRMockData.reviews;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: reviews
          .map(
            (r) => HRCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r.period,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : HRTheme.textPrimary,
                        ),
                      ),
                      HRStatusBadge(
                        label: r.status,
                        color: HRTheme.success,
                        bgColor: HRTheme.successLight,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Star rating
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < r.ratingScore.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 18,
                          color: Colors.amber.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${r.ratingScore}/5.0',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: HRTheme.performance.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            HRTheme.radiusFull,
                          ),
                        ),
                        child: Text(
                          r.rating,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: HRTheme.performance,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: HRTheme.infoLight,
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: HRTheme.info,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            r.feedback,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: HRTheme.textPrimary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outlined,
                        size: 13,
                        color: HRTheme.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${r.reviewedBy} · ${r.reviewDate}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: HRTheme.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAwardsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final awards = HRMockData.awards;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: awards
          .map(
            (a) => HRCard(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: HRTheme.orangeGradient,
                      borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                a.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : HRTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  HRTheme.radiusFull,
                                ),
                              ),
                              child: Text(
                                a.category,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.description,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: HRTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outlined,
                              size: 12,
                              color: HRTheme.textHint,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${a.givenBy} · ${a.date}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: HRTheme.textHint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildOverviewTab() {
    final competencies = [
      ('Clinical Skills', 0.92, HRTheme.success),
      ('Communication', 0.85, HRTheme.info),
      ('Teamwork', 0.90, HRTheme.teal),
      ('Patient Care', 0.95, HRTheme.performance),
      ('Documentation', 0.78, HRTheme.warning),
      ('Leadership', 0.70, HRTheme.primaryLight),
    ];
    final reviews = HRMockData.reviews;
    final avgRating =
        reviews.fold(0.0, (s, r) => s + r.ratingScore) / reviews.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Overall score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: HRTheme.purpleGradient,
              borderRadius: BorderRadius.circular(HRTheme.radiusLG),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Rating',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < avgRating.round()
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 16,
                          color: Colors.amber.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                HRCircularProgress(
                  value: avgRating / 5,
                  label: 'Score',
                  centerText: '${(avgRating / 5 * 100).round()}%',
                  color: Colors.white,
                  size: 80,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          HRCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(
                  title: 'Competency Scores',
                  icon: Icons.radar_rounded,
                ),
                ...competencies.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              c.$1,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(c.$2 * 100).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: c.$3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        HRProgressBar(value: c.$2, color: c.$3, height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          HRCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(
                  title: 'Goal Completion',
                  icon: Icons.check_circle_outline_rounded,
                ),
                HRProgressBar(
                  value:
                      HRMockData.goals
                          .where((g) => g.status == 'Achieved')
                          .length /
                      HRMockData.goals.length,
                  color: HRTheme.success,
                  height: 12,
                  label:
                      '${HRMockData.goals.where((g) => g.status == "Achieved").length} of ${HRMockData.goals.length} goals achieved',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
