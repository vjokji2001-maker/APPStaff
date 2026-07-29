import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRDocumentsScreen extends StatefulWidget {
  const HRDocumentsScreen({super.key});
  @override
  State<HRDocumentsScreen> createState() => _HRDocumentsScreenState();
}

class _HRDocumentsScreenState extends State<HRDocumentsScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final List<String> _categories = ['All', 'ID Proof', 'License', 'Certificate', 'Education', 'Medical', 'Experience'];

  List<HRDocument> get _filteredDocs {
    var docs = HRMockData.documents;
    if (_selectedCategory != 'All') docs = docs.where((d) => d.category == _selectedCategory).toList();
    if (_searchQuery.isNotEmpty) docs = docs.where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    return docs;
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expiring = HRMockData.documents.where((d) => d.isExpiringSoon).toList();
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadSheet,
        backgroundColor: HRTheme.documents,
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: Text('Upload', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        HRGradientHeader(title: 'My Documents', subtitle: 'Manage your uploaded files'),
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: HRSearchBar(hint: 'Search documents...', controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v)),
        ),
        // Category filter
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
                    color: sel ? HRTheme.documents : (isDark ? HRTheme.bgCardDark : Colors.white),
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            children: [
              // Expiry warning banner
              if (expiring.isNotEmpty && _selectedCategory == 'All')
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HRTheme.warningLight, borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                    border: Border.all(color: HRTheme.warning.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.warning_amber_rounded, color: HRTheme.warning, size: 20),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${expiring.length} document(s) expiring soon. Please renew.',
                        style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.warning, fontWeight: FontWeight.w600))),
                  ]),
                ),
              if (_filteredDocs.isEmpty)
                const HREmptyState(icon: Icons.folder_open_outlined, title: 'No Documents Found', subtitle: 'Upload documents or change your filter')
              else
                ..._filteredDocs.map((d) => _buildDocCard(d, isDark)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildDocCard(HRDocument d, bool isDark) {
    final statusColor = d.status == 'Verified' ? HRTheme.success : d.status == 'Pending' ? HRTheme.pending : HRTheme.error;
    final statusBg = d.status == 'Verified' ? HRTheme.successLight : d.status == 'Pending' ? HRTheme.pendingLight : HRTheme.errorLight;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? HRTheme.bgCardDark : Colors.white,
        borderRadius: BorderRadius.circular(HRTheme.radiusMD),
        border: d.isExpiringSoon ? Border.all(color: HRTheme.warning.withOpacity(0.4)) : null,
        boxShadow: HRTheme.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: HRTheme.documents.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
              child: Icon(_docIcon(d.category), size: 20, color: HRTheme.documents),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(d.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: isDark ? Colors.white : HRTheme.textPrimary)),
              Text('${d.category} · ${d.fileSize}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ])),
            HRStatusBadge(label: d.status, color: statusColor, bgColor: statusBg),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _docMeta(Icons.upload_rounded, 'Uploaded', d.uploadedOn),
            const SizedBox(width: 16),
            _docMeta(Icons.event_outlined, 'Expiry', d.expiryDate),
            if (d.isExpiringSoon) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: HRTheme.warningLight, borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text('Expiring Soon', style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.warning, fontWeight: FontWeight.w600)),
              ),
            ],
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: HRTheme.documents.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.visibility_outlined, size: 14, color: HRTheme.documents),
                  const SizedBox(width: 4),
                  Text('View', style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.documents, fontWeight: FontWeight.w600)),
                ]),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: HRTheme.infoLight, borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.download_rounded, size: 14, color: HRTheme.info),
                  const SizedBox(width: 4),
                  Text('Download', style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.info, fontWeight: FontWeight.w600)),
                ]),
              ),
            )),
          ]),
        ]),
      ),
    );
  }

  Widget _docMeta(IconData icon, String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.textHint)),
      Row(children: [
        Icon(icon, size: 11, color: HRTheme.textSecondary),
        const SizedBox(width: 3),
        Text(value, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary, fontWeight: FontWeight.w600)),
      ]),
    ]);
  }

  IconData _docIcon(String category) {
    switch (category) {
      case 'ID Proof': return Icons.credit_card_rounded;
      case 'License': return Icons.verified_rounded;
      case 'Certificate': return Icons.card_membership_rounded;
      case 'Education': return Icons.school_rounded;
      case 'Medical': return Icons.medical_services_rounded;
      case 'Experience': return Icons.work_rounded;
      default: return Icons.description_rounded;
    }
  }

  void _showUploadSheet() {
    final nameCtrl = TextEditingController();
    String selectedCategory = _categories[1];
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXL))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Upload Document', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(hintText: 'Document Name', hintStyle: GoogleFonts.poppins(color: HRTheme.textHint),
                prefixIcon: const Icon(Icons.description_outlined, size: 18), border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM))),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: _categories.skip(1).map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setSS(() => selectedCategory = v!),
              decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM))),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HRTheme.documents.withOpacity(0.05), borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                  border: Border.all(color: HRTheme.documents.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.cloud_upload_outlined, color: HRTheme.documents, size: 28),
                  const SizedBox(width: 10),
                  Text('Tap to select file', style: GoogleFonts.poppins(color: HRTheme.documents, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            HRPrimaryButton(label: 'Upload Document', icon: Icons.upload_rounded, color: HRTheme.documents, onPressed: () => Navigator.pop(ctx)),
            const SizedBox(height: 8),
          ]),
        ),
      )),
    );
  }
}
