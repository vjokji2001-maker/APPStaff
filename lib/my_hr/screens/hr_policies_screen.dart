import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRPoliciesScreen extends StatefulWidget {
  const HRPoliciesScreen({super.key});
  @override
  State<HRPoliciesScreen> createState() => _HRPoliciesScreenState();
}

class _HRPoliciesScreenState extends State<HRPoliciesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final List<String> _categories = ['All', 'Attendance', 'Leave', 'Payroll', 'HR', 'SOP', 'IT', 'Clinical'];

  List<HRPolicy> get _filtered {
    var policies = HRMockData.policies;
    if (_selectedCategory != 'All') policies = policies.where((p) => p.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) policies = policies.where((p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return policies;
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(title: 'HR Policies', subtitle: 'Company policies & SOPs'),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: HRSearchBar(hint: 'Search policies...', controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v)),
        ),
        // Category chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: _categories.map((c) {
              final sel = c == _selectedCategory;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? HRTheme.policies : (isDark ? HRTheme.bgCardDark : Colors.white),
                    borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                    boxShadow: HRTheme.subtleShadow,
                  ),
                  child: Text(c, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : HRTheme.textSecondary)),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(child: _filtered.isEmpty
            ? const HREmptyState(icon: Icons.policy_outlined, title: 'No Policies Found', subtitle: 'Try a different search or category')
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _buildPolicyCard(_filtered[i], isDark),
              )),
      ]),
    );
  }

  Widget _buildPolicyCard(HRPolicy p, bool isDark) {
    final catColor = _categoryColor(p.category);
    return HRCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: catColor.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
            child: Icon(_categoryIcon(p.category), size: 20, color: catColor),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HRTheme.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              HRStatusBadge(label: p.category, color: catColor, bgColor: catColor.withOpacity(0.1)),
              const SizedBox(width: 8),
              HRStatusBadge(label: p.version, color: HRTheme.textSecondary, bgColor: HRTheme.divider),
            ]),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(p.description, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        Row(children: [
          _metaItem(Icons.calendar_today_outlined, 'Effective: ${p.effectiveDate}'),
          const SizedBox(width: 16),
          _metaItem(Icons.description_outlined, '${p.pages} pages'),
          const SizedBox(width: 16),
          _metaItem(Icons.update_rounded, 'Updated: ${p.lastUpdated}'),
        ]),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: HRTheme.policies.withOpacity(0.06), borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              border: Border.all(color: HRTheme.policies.withOpacity(0.2)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.picture_as_pdf_rounded, size: 16, color: HRTheme.policies),
              const SizedBox(width: 6),
              Text('Download PDF', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: HRTheme.policies)),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _metaItem(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 11, color: HRTheme.textHint),
    const SizedBox(width: 3),
    Flexible(child: Text(text, style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textSecondary), overflow: TextOverflow.ellipsis)),
  ]);

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Attendance': return HRTheme.attendance;
      case 'Leave': return HRTheme.leave;
      case 'Payroll': return HRTheme.payroll;
      case 'HR': return HRTheme.primaryDark;
      case 'SOP': return HRTheme.teal;
      case 'IT': return HRTheme.info;
      case 'Clinical': return HRTheme.error;
      default: return HRTheme.policies;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Attendance': return Icons.fingerprint_rounded;
      case 'Leave': return Icons.beach_access_rounded;
      case 'Payroll': return Icons.payments_rounded;
      case 'HR': return Icons.people_rounded;
      case 'SOP': return Icons.assignment_rounded;
      case 'IT': return Icons.computer_rounded;
      case 'Clinical': return Icons.medical_services_rounded;
      default: return Icons.policy_rounded;
    }
  }
}
