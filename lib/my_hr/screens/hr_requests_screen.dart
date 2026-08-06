import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRRequestsScreen extends StatefulWidget {
  const HRRequestsScreen({super.key});
  @override
  State<HRRequestsScreen> createState() => _HRRequestsScreenState();
}

class _HRRequestsScreenState extends State<HRRequestsScreen> {
  String _filter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Approved', 'Rejected'];
  
  bool _isLoading = true;
  List<HRRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      final dynamic res = await HRApiService.getSwipeRequests();
      final data = (res is Map && res['data'] != null) ? res['data'] as List : res as List<dynamic>;
      setState(() {
        _requests = data.map((e) => HRRequest.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching requests: $e');
      setState(() {
        _requests = [];
        _isLoading = false;
      });
    }
  }

  List<HRRequest> get _filtered {
    final all = _requests;
    if (_filter == 'All') return all;
    return all.where((r) => r.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewRequestSheet,
        backgroundColor: HRTheme.requests,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('New Request', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        HRGradientHeader(title: 'My Requests', subtitle: 'HR service requests'),
        HRTabBar(
          tabs: _filters, selectedIndex: _filters.indexOf(_filter),
          onTabChanged: (i) => setState(() => _filter = _filters[i]),
          activeColor: HRTheme.requests,
        ),
        Expanded(child: _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : _buildList(isDark)),
      ]),
    );
  }

  Widget _buildList(bool isDark) {
    final requests = _filtered;
    if (requests.isEmpty) {
      return const HREmptyState(icon: Icons.send_outlined, title: 'No Requests', subtitle: 'No requests found. Tap + to submit a new request.');
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: requests.length,
      itemBuilder: (_, i) => _buildRequestCard(requests[i], isDark),
    );
  }

  Widget _buildRequestCard(HRRequest r, bool isDark) {
    final statusColor = r.status == 'Approved' ? HRTheme.success : r.status == 'Pending' ? HRTheme.pending : HRTheme.error;
    final statusBg = r.status == 'Approved' ? HRTheme.successLight : r.status == 'Pending' ? HRTheme.pendingLight : HRTheme.errorLight;
    return HRCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: HRTheme.requests.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
            child: Icon(_requestIcon(r.type), size: 18, color: HRTheme.requests),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.subject, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HRTheme.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(r.type, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          ])),
          HRStatusBadge(label: r.status, color: statusColor, bgColor: statusBg),
        ]),
        const SizedBox(height: 8),
        Text(r.description, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary),
            maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        Row(children: [
          Icon(Icons.calendar_today_outlined, size: 12, color: HRTheme.textHint),
          const SizedBox(width: 4),
          Text('Submitted: ${r.submittedOn}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
          if (r.resolvedOn != null) ...[
            const SizedBox(width: 12),
            Icon(Icons.check_rounded, size: 12, color: HRTheme.success),
            const SizedBox(width: 4),
            Text('Resolved: ${r.resolvedOn}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
          ],
        ]),
        if (r.remarks != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.06), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.comment_outlined, size: 13, color: statusColor),
              const SizedBox(width: 6),
              Expanded(child: Text(r.remarks!, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textPrimary))),
            ]),
          ),
        ],
      ]),
    );
  }

  IconData _requestIcon(String type) {
    switch (type) {
      case 'Attendance Correction': return Icons.fingerprint_rounded;
      case 'Asset Request': return Icons.devices_rounded;
      case 'Shift Change': return Icons.schedule_rounded;
      case 'Expense Claim': return Icons.receipt_long_rounded;
      case 'Transfer Request': return Icons.transfer_within_a_station_rounded;
      default: return Icons.send_rounded;
    }
  }

  void _showNewRequestSheet() {
    final subjectCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'Attendance Correction';
    final types = ['Attendance Correction', 'Asset Request', 'Shift Change', 'Expense Claim', 'Transfer Request', 'Other'];
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
            Text('New HR Request', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
              onChanged: (v) => setSS(() => selectedType = v!),
              decoration: InputDecoration(labelText: 'Request Type', prefixIcon: const Icon(Icons.category_outlined, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM))),
            ),
            const SizedBox(height: 10),
            TextField(controller: subjectCtrl,
              decoration: InputDecoration(hintText: 'Subject', prefixIcon: const Icon(Icons.subject_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
            const SizedBox(height: 10),
            TextField(controller: descCtrl, maxLines: 3,
              decoration: InputDecoration(hintText: 'Description', prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
            const SizedBox(height: 16),
            HRPrimaryButton(label: 'Submit Request', icon: Icons.send_rounded, color: HRTheme.requests, onPressed: () => Navigator.pop(ctx)),
            const SizedBox(height: 8),
          ]),
        ),
      )),
    );
  }
}
