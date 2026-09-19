import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/theme/hr_theme.dart';

/// Premium dashboard screen featuring glass‑morphic cards, dynamic gradients,
/// subtle micro‑animations and a responsive grid layout. Designed to showcase
/// enterprise‑grade KPI cards for the Hospital ERP.
class ProfessionalDashboard extends ConsumerWidget {
  const ProfessionalDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final crossAxisCount = size.width > 800 ? 4 : (size.width > 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: isDark
          ? HRTheme.backgroundDark
          : HRTheme.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Enterprise Dashboard',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _kpiData.length,
          itemBuilder: (context, index) {
            final data = _kpiData[index];
            return _GlassMorphicCard(
              title: data.title,
              value: data.value,
              icon: data.icon,
              gradientColors: isDark ? data.darkGradient : data.lightGradient,
            );
          },
        ),
      ),
    );
  }
}

/// Model for a single KPI card.
class _KpiInfo {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> lightGradient;
  final List<Color> darkGradient;
  const _KpiInfo({
    required this.title,
    required this.value,
    required this.icon,
    required this.lightGradient,
    required this.darkGradient,
  });
}

// Sample static data – replace with real API values later.
const List<_KpiInfo> _kpiData = [
  _KpiInfo(
    title: 'In‑House Patients',
    value: '120',
    icon: Icons.local_hospital,
    lightGradient: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
    darkGradient: [Color(0xFF1565C0), Color(0xFF0D47A1)],
  ),
  _KpiInfo(
    title: 'Occupied Beds',
    value: '180 / 200',
    icon: Icons.hotel,
    lightGradient: [Color(0xFFFFF59D), Color(0xFFFFEB3B)],
    darkGradient: [Color(0xFFF9A825), Color(0xFFF57F17)],
  ),
  _KpiInfo(
    title: 'Revenue Today',
    value: '\u20B9 1.2M',
    icon: Icons.attach_money,
    lightGradient: [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
    darkGradient: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  ),
  _KpiInfo(
    title: 'Pending Approvals',
    value: '5',
    icon: Icons.pending_actions,
    lightGradient: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
    darkGradient: [Color(0xFFE65100), Color(0xFFBF360C)],
  ),
];

/// Glass‑morphic card with subtle animation.
class _GlassMorphicCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradientColors;
  const _GlassMorphicCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: Colors.white70),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
