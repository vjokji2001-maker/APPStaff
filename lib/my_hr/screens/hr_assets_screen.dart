import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRAssetsScreen extends StatefulWidget {
  const HRAssetsScreen({super.key});
  @override
  State<HRAssetsScreen> createState() => _HRAssetsScreenState();
}

class _HRAssetsScreenState extends State<HRAssetsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assets = HRMockData.assets;
    // Build type summary
    final types = <String, int>{};
    for (final a in assets) types[a.type] = (types[a.type] ?? 0) + 1;

    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(title: 'My Assets', subtitle: 'Assigned equipment & items'),
        Expanded(child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary counts
            HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const HRSectionHeader(title: 'Asset Summary', icon: Icons.inventory_2_outlined),
              Wrap(spacing: 10, runSpacing: 10, children: types.entries.map((e) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: HRTheme.assets.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_assetIcon(e.key), size: 16, color: HRTheme.assets),
                  const SizedBox(width: 6),
                  Text('${e.value}x ${e.key}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: HRTheme.assets)),
                ]),
              )).toList()),
            ])),
            const SizedBox(height: 16),
            const HRSectionHeader(title: 'Assigned Assets', icon: Icons.devices_rounded),
            ...assets.map((a) => _buildAssetCard(a, isDark)),
          ],
        )),
      ]),
    );
  }

  Widget _buildAssetCard(HRAsset a, bool isDark) {
    final condColor = a.condition == 'Excellent' ? HRTheme.success : a.condition == 'Good' ? HRTheme.teal : HRTheme.warning;
    return GestureDetector(
      onTap: () => _showAssetDetails(a),
      child: HRCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: HRTheme.assets.withOpacity(0.12), borderRadius: BorderRadius.circular(HRTheme.radiusMD)),
            child: Icon(_assetIcon(a.type), size: 24, color: HRTheme.assets),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : HRTheme.textPrimary)),
            Text('${a.assetCode} · Assigned: ${a.assignedDate}',
                style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            if (a.brand != null) Text('${a.brand ?? ''} ${a.model ?? ''}',
                style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textHint)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            HRStatusBadge(label: a.status, color: HRTheme.success, bgColor: HRTheme.successLight),
            const SizedBox(height: 4),
            HRStatusBadge(label: a.condition, color: condColor, bgColor: condColor.withOpacity(0.1)),
          ]),
        ]),
      ),
    );
  }

  void _showAssetDetails(HRAsset a) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXL))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(gradient: HRTheme.moduleGradient(HRTheme.assets), borderRadius: BorderRadius.circular(HRTheme.radiusMD)),
              child: Icon(_assetIcon(a.type), color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : HRTheme.textPrimary)),
              Text(a.type, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          HRInfoRow(label: 'Asset Code', value: a.assetCode, icon: Icons.qr_code_outlined),
          HRInfoRow(label: 'Status', value: a.status, icon: Icons.radio_button_checked_rounded),
          HRInfoRow(label: 'Condition', value: a.condition, icon: Icons.health_and_safety_outlined),
          HRInfoRow(label: 'Assigned Date', value: a.assignedDate, icon: Icons.calendar_today_outlined),
          if (a.serialNumber != null) HRInfoRow(label: 'Serial Number', value: a.serialNumber!, icon: Icons.numbers_outlined),
          if (a.brand != null) HRInfoRow(label: 'Brand / Model', value: '${a.brand} ${a.model ?? ''}', icon: Icons.info_outline_rounded),
          HRInfoRow(label: 'Return Date', value: a.returnDate ?? 'Not returned', icon: Icons.assignment_return_outlined, isLast: true),
          const SizedBox(height: 16),
          // History timeline
          Text('Asset History', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          HRTimelineItem(title: 'Assigned to Employee', subtitle: 'Issued from HR stores', time: a.assignedDate, color: HRTheme.success, icon: Icons.check_circle_rounded, isLast: false),
          HRTimelineItem(title: 'Condition Checked', subtitle: '${a.condition} condition verified', time: a.assignedDate, color: HRTheme.info, icon: Icons.verified_rounded, isLast: true),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  IconData _assetIcon(String type) {
    switch (type) {
      case 'Laptop': return Icons.laptop_mac_rounded;
      case 'Mobile': return Icons.smartphone_rounded;
      case 'ID Card': return Icons.badge_rounded;
      case 'Uniform': return Icons.checkroom_rounded;
      case 'Medical Equipment': return Icons.medical_services_rounded;
      default: return Icons.devices_other_rounded;
    }
  }
}
