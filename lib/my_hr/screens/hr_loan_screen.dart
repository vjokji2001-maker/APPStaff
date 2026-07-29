import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRLoanScreen extends StatefulWidget {
  const HRLoanScreen({super.key});
  @override
  State<HRLoanScreen> createState() => _HRLoanScreenState();
}

class _HRLoanScreenState extends State<HRLoanScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Loan Details', 'EMI Schedule', 'Payment History'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(title: 'My Loan', subtitle: 'Loan & EMI details'),
        HRTabBar(tabs: _tabs, selectedIndex: _tabIndex, onTabChanged: (i) => setState(() => _tabIndex = i), activeColor: HRTheme.loan),
        Expanded(child: _buildTab()),
      ]),
    );
  }

  Widget _buildTab() {
    if (HRMockData.loans.isEmpty) {
      return const HREmptyState(icon: Icons.account_balance_outlined, title: 'No Active Loans', subtitle: 'You have no loans at the moment');
    }
    final loan = HRMockData.loans.first;
    switch (_tabIndex) {
      case 0: return _buildDetailsTab(loan);
      case 1: return _buildEMIScheduleTab(loan);
      case 2: return _buildPaymentHistoryTab(loan);
      default: return _buildDetailsTab(loan);
    }
  }

  Widget _buildDetailsTab(LoanDetail loan) {
    final repaidPct = loan.totalRepaid / loan.principalAmount;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // Loan summary card
        Container(
          width: double.infinity, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: HRTheme.orangeGradient, borderRadius: BorderRadius.circular(HRTheme.radiusLG), boxShadow: HRTheme.elevatedShadow),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text(loan.loanType, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              HRStatusBadge(label: loan.status, color: Colors.white, bgColor: Colors.white.withOpacity(0.2)),
            ]),
            const SizedBox(height: 12),
            Text('₹${_fmt(loan.principalAmount)}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            Text('Principal Amount · ${loan.interestRate}% p.a.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 14),
            Row(children: [
              _loanPill('EMI', '₹${_fmt(loan.emiAmount)}/mo'),
              const SizedBox(width: 10),
              _loanPill('Tenure', '${loan.tenureMonths} months'),
              const SizedBox(width: 10),
              _loanPill('Disbursed', loan.disbursedDate),
            ]),
            const SizedBox(height: 14),
            // Repayment progress
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Repaid', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
              Text('₹${_fmt(loan.totalRepaid)} / ₹${_fmt(loan.principalAmount)}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(HRTheme.radiusFull),
              child: LinearProgressIndicator(value: repaidPct, backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), minHeight: 6),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Loan Information', icon: Icons.info_outline_rounded),
          HRInfoRow(label: 'Loan Type', value: loan.loanType, icon: Icons.account_balance_outlined),
          HRInfoRow(label: 'Principal Amount', value: '₹${_fmt(loan.principalAmount)}', icon: Icons.payments_outlined),
          HRInfoRow(label: 'Interest Rate', value: '${loan.interestRate}% per annum', icon: Icons.percent_rounded),
          HRInfoRow(label: 'Tenure', value: '${loan.tenureMonths} months', icon: Icons.calendar_month_outlined),
          HRInfoRow(label: 'Monthly EMI', value: '₹${_fmt(loan.emiAmount)}', icon: Icons.repeat_rounded),
          HRInfoRow(label: 'Disbursed Date', value: loan.disbursedDate, icon: Icons.date_range_outlined),
          HRInfoRow(label: 'Outstanding Balance', value: '₹${_fmt(loan.outstandingBalance)}', icon: Icons.account_balance_wallet_outlined, iconColor: HRTheme.error),
          HRInfoRow(label: 'Total Repaid', value: '₹${_fmt(loan.totalRepaid)}', icon: Icons.check_circle_outline_rounded, iconColor: HRTheme.success, isLast: true),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _loanPill(String label, String val) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 9)),
      Text(val, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  ));

  Widget _buildEMIScheduleTab(LoanDetail loan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: loan.emiSchedule.length,
      itemBuilder: (_, i) {
        final emi = loan.emiSchedule[i];
        final statusColor = emi.status == 'Paid' ? HRTheme.success : emi.status == 'Overdue' ? HRTheme.error : HRTheme.pending;
        final statusBg = emi.status == 'Paid' ? HRTheme.successLight : emi.status == 'Overdue' ? HRTheme.errorLight : HRTheme.pendingLight;
        final isNext = i == 10; // upcoming
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isNext ? HRTheme.pendingLight : (isDark ? HRTheme.bgCardDark : Colors.white),
            borderRadius: BorderRadius.circular(HRTheme.radiusMD),
            border: isNext ? Border.all(color: HRTheme.pending.withOpacity(0.4)) : null,
            boxShadow: HRTheme.subtleShadow,
          ),
          child: ListTile(
            dense: true,
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
              child: Center(child: Text('#${emi.installmentNo}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor))),
            ),
            title: Text('₹${_fmt(emi.amount)} · Due: ${emi.dueDate}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white : HRTheme.textPrimary)),
            subtitle: emi.paidDate != null ? Text('Paid on ${emi.paidDate}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)) : null,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isNext) Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: HRTheme.pending.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text('Next', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: HRTheme.pending)),
              ),
              const SizedBox(width: 6),
              HRStatusBadge(label: emi.status, color: statusColor, bgColor: statusBg),
            ]),
          ),
        );
      },
    );
  }

  Widget _buildPaymentHistoryTab(LoanDetail loan) {
    final paid = loan.emiSchedule.where((e) => e.status == 'Paid').toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paid.length,
      itemBuilder: (_, i) {
        final emi = paid[i];
        return HRCard(
          margin: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: HRTheme.successLight, borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
              child: const Icon(Icons.check_circle_rounded, color: HRTheme.success, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('EMI #${emi.installmentNo} – ₹${_fmt(emi.amount)}',
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
              Text('Due: ${emi.dueDate}${emi.paidDate != null ? ' · Paid: ${emi.paidDate}' : ''}',
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ])),
            HRStatusBadge(label: 'Paid', color: HRTheme.success, bgColor: HRTheme.successLight),
          ]),
        );
      },
    );
  }

  String _fmt(double v) => v >= 100000 ? '${(v / 100000).toStringAsFixed(1)}L' : '${(v / 1000).toStringAsFixed(1)}k';
}
