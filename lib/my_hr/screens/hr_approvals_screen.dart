import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRApprovalsScreen extends StatefulWidget {
  const HRApprovalsScreen({super.key});
  @override
  State<HRApprovalsScreen> createState() => _HRApprovalsScreenState();
}

class _HRApprovalsScreenState extends State<HRApprovalsScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Pending', 'Approved', 'Rejected'];
  // Simulate local state for approvals
  late List<ApprovalItem> _approvals;

  @override
  void initState() {
    super.initState();
    _approvals = List.from(HRMockData.approvals);
  }

  List<ApprovalItem> get _filtered {
    switch (_tabIndex) {
      case 0: return _approvals.where((a) => a.status == 'Pending').toList();
      case 1: return _approvals.where((a) => a.status == 'Approved').toList();
      case 2: return _approvals.where((a) => a.status == 'Rejected').toList();
      default: return _approvals;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(
          title: 'Approvals',
          subtitle: 'Team requests awaiting your action',
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
              child: Row(children: [
                const Icon(Icons.pending_actions_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text('${_approvals.where((a) => a.status == "Pending").length}',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          ],
        ),
        HRTabBar(tabs: _tabs, selectedIndex: _tabIndex, onTabChanged: (i) => setState(() => _tabIndex = i), activeColor: HRTheme.approvals),
        Expanded(child: _buildList(isDark)),
      ]),
    );
  }

  Widget _buildList(bool isDark) {
    final items = _filtered;
    if (items.isEmpty) {
      return HREmptyState(
        icon: _tabIndex == 0 ? Icons.pending_actions_outlined : _tabIndex == 1 ? Icons.check_circle_outline : Icons.cancel_outlined,
        title: 'No ${_tabs[_tabIndex]} Approvals',
        subtitle: _tabIndex == 0 ? 'All requests have been actioned' : 'No approvals in this category',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => _buildApprovalCard(items[i], isDark),
    );
  }

  Widget _buildApprovalCard(ApprovalItem a, bool isDark) {
    final isPending = a.status == 'Pending';
    final isApproved = a.status == 'Approved';
    final statusColor = isApproved ? HRTheme.success : a.status == 'Pending' ? HRTheme.pending : HRTheme.error;
    final statusBg = isApproved ? HRTheme.successLight : a.status == 'Pending' ? HRTheme.pendingLight : HRTheme.errorLight;

    return HRCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18, backgroundColor: HRTheme.approvals.withOpacity(0.12),
            child: Text(a.requestedBy.split(' ').map((n) => n[0]).take(2).join(),
                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: HRTheme.approvals)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.requestedBy, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : HRTheme.textPrimary)),
            Text('${a.type} · ${a.requestedOn}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          ])),
          HRStatusBadge(label: a.status, color: statusColor, bgColor: statusBg),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: isDark ? HRTheme.dividerDark : HRTheme.bgLight, borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
          child: Text(a.description, style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white70 : HRTheme.textPrimary)),
        ),
        if (a.remarks != null) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.comment_outlined, size: 13, color: statusColor),
            const SizedBox(width: 6),
            Expanded(child: Text(a.remarks!, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary))),
          ]),
        ],
        if (a.actionDate != null) ...[
          const SizedBox(height: 4),
          Text('Actioned on ${a.actionDate}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
        ],
        if (isPending) ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => _takeAction(a, 'Rejected'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: HRTheme.errorLight, borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    border: Border.all(color: HRTheme.error.withOpacity(0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.close_rounded, size: 16, color: HRTheme.error),
                  const SizedBox(width: 6),
                  Text('Reject', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: HRTheme.error)),
                ]),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => _takeAction(a, 'Approved'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: HRTheme.successLight, borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    border: Border.all(color: HRTheme.success.withOpacity(0.3))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_rounded, size: 16, color: HRTheme.success),
                  const SizedBox(width: 6),
                  Text('Approve', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: HRTheme.success)),
                ]),
              ),
            )),
          ]),
        ],
      ]),
    );
  }

  void _takeAction(ApprovalItem item, String action) {
    setState(() {
      final idx = _approvals.indexWhere((a) => a.id == item.id);
      if (idx != -1) {
        _approvals[idx] = ApprovalItem(
          id: item.id, type: item.type, requestedBy: item.requestedBy,
          requestedOn: item.requestedOn, description: item.description,
          status: action, actionDate: 'Today',
          remarks: action == 'Approved' ? 'Approved by you.' : 'Rejected by you.',
        );
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${item.type} ${action.toLowerCase()} successfully', style: GoogleFonts.poppins()),
      backgroundColor: action == 'Approved' ? HRTheme.success : HRTheme.error,
      behavior: SnackBarBehavior.floating,
    ));
  }
}
