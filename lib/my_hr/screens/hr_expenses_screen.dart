import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRExpensesScreen extends StatefulWidget {
  const HRExpensesScreen({super.key});
  @override
  State<HRExpensesScreen> createState() => _HRExpensesScreenState();
}

class _HRExpensesScreenState extends State<HRExpensesScreen> {
  String _filter = 'All';
  final List<String> _filters = [
    'All',
    'Travel',
    'Medical',
    'Food',
    'Pending',
    'Approved',
    'Rejected',
  ];

  List<ExpenseClaim> get _filtered {
    final all = HRMockData.expenses;
    switch (_filter) {
      case 'All':
        return all;
      case 'Pending':
        return all.where((e) => e.status == 'Pending').toList();
      case 'Approved':
        return all.where((e) => e.status == 'Approved').toList();
      case 'Rejected':
        return all.where((e) => e.status == 'Rejected').toList();
      default:
        return all.where((e) => e.type == _filter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final all = HRMockData.expenses;
    final totalApproved = all
        .where((e) => e.status == 'Approved')
        .fold(0.0, (s, e) => s + e.amount);
    final totalPending = all
        .where((e) => e.status == 'Pending')
        .fold(0.0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showClaimSheet,
        backgroundColor: HRTheme.expenses,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Claim',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          HRGradientHeader(
            title: 'My Expenses',
            subtitle: 'Claim & track reimbursements',
          ),
          // Filter tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: _filters.map((f) {
                final sel = f == _filter;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sel
                          ? HRTheme.expenses
                          : (isDark ? HRTheme.bgCardDark : Colors.white),
                      borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                      boxShadow: HRTheme.subtleShadow,
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : HRTheme.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                // Summary stats
                Row(
                  children: [
                    _statCard(
                      'Approved',
                      '₹${_fmtAmt(totalApproved)}',
                      HRTheme.success,
                      HRTheme.successLight,
                      Icons.check_circle_rounded,
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Pending',
                      '₹${_fmtAmt(totalPending)}',
                      HRTheme.pending,
                      HRTheme.pendingLight,
                      Icons.schedule_rounded,
                    ),
                    const SizedBox(width: 10),
                    _statCard(
                      'Total Claims',
                      '${all.length}',
                      HRTheme.expenses,
                      HRTheme.expenses.withValues(alpha: 0.1),
                      Icons.receipt_long_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_filtered.isEmpty)
                  const HREmptyState(
                    icon: Icons.receipt_outlined,
                    title: 'No Expenses',
                    subtitle: 'No claims found for this filter',
                  )
                else
                  ..._filtered.map((e) => _buildExpenseCard(e, isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(
    String label,
    String val,
    Color color,
    Color bg,
    IconData icon,
  ) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(HRTheme.radiusMD),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            val,
            style: GoogleFonts.poppins(
              fontSize: 13,
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

  Widget _buildExpenseCard(ExpenseClaim e, bool isDark) {
    final statusColor = e.status == 'Approved'
        ? HRTheme.success
        : e.status == 'Pending'
        ? HRTheme.pending
        : HRTheme.error;
    final statusBg = e.status == 'Approved'
        ? HRTheme.successLight
        : e.status == 'Pending'
        ? HRTheme.pendingLight
        : HRTheme.errorLight;
    return HRCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _typeColor(e.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(HRTheme.radiusSM),
            ),
            child: Icon(_typeIcon(e.type), size: 20, color: _typeColor(e.type)),
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
                        e.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : HRTheme.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${_fmtAmt(e.amount)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: HRTheme.expenses,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    HRStatusBadge(
                      label: e.type,
                      color: _typeColor(e.type),
                      bgColor: _typeColor(e.type).withValues(alpha: 0.1),
                    ),
                    const SizedBox(width: 8),
                    HRStatusBadge(
                      label: e.status,
                      color: statusColor,
                      bgColor: statusBg,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Date: ${e.date} · Submitted: ${e.submittedOn}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: HRTheme.textHint,
                  ),
                ),
                if (e.approvedBy != null)
                  Text(
                    'By: ${e.approvedBy}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
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

  Color _typeColor(String type) {
    switch (type) {
      case 'Travel':
        return HRTheme.info;
      case 'Medical':
        return HRTheme.error;
      case 'Food':
        return Colors.orange;
      case 'Accommodation':
        return HRTheme.teal;
      default:
        return HRTheme.textSecondary;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Travel':
        return Icons.directions_car_rounded;
      case 'Medical':
        return Icons.local_hospital_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Accommodation':
        return Icons.hotel_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  String _fmtAmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);

  void _showClaimSheet() {
    final descCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    String selectedType = 'Travel';
    final types = ['Travel', 'Medical', 'Food', 'Accommodation', 'Other'];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(HRTheme.radiusXL),
        ),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Submit Expense Claim',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: types
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t,
                            style: GoogleFonts.poppins(fontSize: 13),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setSS(() => selectedType = v!),
                  decoration: InputDecoration(
                    labelText: 'Expense Type',
                    prefixIcon: const Icon(Icons.category_outlined, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Amount (₹)',
                    prefixIcon: const Icon(
                      Icons.currency_rupee_rounded,
                      size: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: HRTheme.expenses.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                      border: Border.all(
                        color: HRTheme.expenses.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          color: HRTheme.expenses,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Attach Receipt',
                          style: GoogleFonts.poppins(
                            color: HRTheme.expenses,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                HRPrimaryButton(
                  label: 'Submit Claim',
                  icon: Icons.send_rounded,
                  color: HRTheme.expenses,
                  onPressed: () => Navigator.pop(ctx),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
