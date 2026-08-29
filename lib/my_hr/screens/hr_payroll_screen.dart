import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRPayrollScreen extends StatefulWidget {
  const HRPayrollScreen({super.key});
  @override
  State<HRPayrollScreen> createState() => _HRPayrollScreenState();
}

class _HRPayrollScreenState extends State<HRPayrollScreen> {
  int _tabIndex = 0;
  int _selectedSlipIndex = 0;
  final List<String> _tabs = ['Salary Slip', 'Summary', 'Bonus & Incentives', 'Download'];

  bool _isLoading = true;
  List<SalarySlip> _slips = [];

  @override
  void initState() {
    super.initState();
    _fetchPayroll();
  }

  Future<void> _fetchPayroll() async {
    try {
      final empId = await HRApiService.getLoggedEmpId();
      final res = await HRApiService.getPayrollSummary(
        empId: empId.isNotEmpty ? empId : null,
      );
      final dataList = (res is Map && res['data'] != null) ? res['data'] as List : (res is List ? res : []);
      setState(() {
        _slips = dataList.map((e) => SalarySlip.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching payroll: $e');
      setState(() {
        _slips = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      body: Column(children: [
        HRGradientHeader(
          title: 'Payroll',
          subtitle: 'Salary slips & earnings',
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              ),
              child: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
            ),
          ],
        ),
        HRTabBar(
          tabs: _tabs,
          selectedIndex: _tabIndex,
          onTabChanged: (i) => setState(() => _tabIndex = i),
          activeColor: HRTheme.payroll,
        ),
        Expanded(child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _slips.isEmpty 
            ? const HREmptyState(icon: Icons.payments_outlined, title: 'No Payroll Data', subtitle: 'Salary slips will appear here')
            : _buildTab()),
      ]),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 0: return _buildSalarySlipTab();
      case 1: return _buildSummaryTab();
      case 2: return _buildBonusTab();
      case 3: return _buildDownloadTab();
      default: return _buildSalarySlipTab();
    }
  }

  Widget _buildSalarySlipTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final slips = _slips;
    if (slips.isEmpty) return const SizedBox();
    final slip = slips[_selectedSlipIndex.clamp(0, slips.length - 1)];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Month selector
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: slips.length,
            itemBuilder: (_, i) {
              final sel = i == _selectedSlipIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedSlipIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: sel ? HRTheme.purpleGradient : null,
                    color: sel ? null : (isDark ? HRTheme.bgCardDark : Colors.white),
                    borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                    boxShadow: HRTheme.subtleShadow,
                  ),
                  child: Text('${slips[i].month} ${slips[i].year}',
                      style: GoogleFonts.poppins(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : HRTheme.textSecondary,
                      )),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Salary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: HRTheme.purpleGradient,
            borderRadius: BorderRadius.circular(HRTheme.radiusLG),
            boxShadow: HRTheme.elevatedShadow,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${slip.month} ${slip.year} · ${slip.payPeriod}',
                style: GoogleFonts.poppins(color: Colors.white60, fontSize: 11)),
            const SizedBox(height: 6),
            Text('₹${_fmt(slip.netSalary)}',
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            Text('Net Salary', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 14),
            Row(children: [
              _salaryPill('Gross', '₹${_fmt(slip.grossEarnings)}', Colors.white.withOpacity(0.2)),
              const SizedBox(width: 10),
              _salaryPill('Deductions', '-₹${_fmt(slip.totalDeductions)}', Colors.red.withOpacity(0.3)),
              const SizedBox(width: 10),
              _salaryPill(slip.status, slip.status == 'Paid' ? '✓' : '⏳',
                  slip.status == 'Paid' ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3)),
            ]),
            const SizedBox(height: 10),
            Text('Credit Date: ${slip.creditDate} · ${slip.presentDays}/${slip.workingDays} days',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
          ]),
        ),
        const SizedBox(height: 20),
        // Earnings
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Earnings', icon: Icons.add_circle_outline_rounded),
          _earningRow('Basic Salary', slip.basicSalary, Icons.account_balance_wallet_outlined, HRTheme.success),
          _earningRow('HRA', slip.hra, Icons.home_outlined, HRTheme.teal),
          _earningRow('Conveyance Allowance', slip.conveyanceAllowance, Icons.directions_car_outlined, HRTheme.info),
          _earningRow('Medical Allowance', slip.medicalAllowance, Icons.local_hospital_outlined, HRTheme.error),
          _earningRow('Special Allowance', slip.specialAllowance, Icons.star_outline_rounded, HRTheme.warning),
          if (slip.nightAllowance > 0)
            _earningRow('Night Allowance', slip.nightAllowance, Icons.nightlight_round, HRTheme.primaryLight),
          if (slip.bonus > 0)
            _earningRow('Bonus', slip.bonus, Icons.card_giftcard_rounded, Colors.amber.shade700),
          const Divider(),
          _earningRow('Gross Earnings', slip.grossEarnings, Icons.functions_rounded, HRTheme.success, isBold: true),
        ])),
        const SizedBox(height: 14),
        // Deductions
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Deductions', icon: Icons.remove_circle_outline_rounded),
          _earningRow('Provident Fund (PF)', slip.pfDeduction, Icons.savings_outlined, HRTheme.error, isDeduction: true),
          _earningRow('ESIC', slip.esicDeduction, Icons.health_and_safety_outlined, HRTheme.error, isDeduction: true),
          _earningRow('Professional Tax', slip.professionalTax, Icons.receipt_outlined, HRTheme.error, isDeduction: true),
          _earningRow('TDS', slip.tds, Icons.account_balance_outlined, HRTheme.error, isDeduction: true),
          if (slip.loanDeduction > 0)
            _earningRow('Loan EMI', slip.loanDeduction, Icons.money_off_outlined, HRTheme.error, isDeduction: true),
          const Divider(),
          _earningRow('Total Deductions', slip.totalDeductions, Icons.functions_rounded, HRTheme.error, isBold: true, isDeduction: true),
        ])),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HRTheme.successLight,
            borderRadius: BorderRadius.circular(HRTheme.radiusMD),
            border: Border.all(color: HRTheme.success.withOpacity(0.3)),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Net Salary', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: HRTheme.success)),
            Text('₹${_fmt(slip.netSalary)}', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: HRTheme.success)),
          ]),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _buildSummaryTab() {
    final slips = _slips;
    if (slips.isEmpty) return const HREmptyState(icon: Icons.bar_chart_rounded, title: 'No Data', subtitle: 'Salary summary will appear here');
    final values = slips.reversed.map((s) => s.netSalary / 1000).toList();
    final labels = slips.reversed.map((s) => s.month.substring(0, 3)).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Net Salary Trend', icon: Icons.trending_up_rounded),
          HRBarChart(values: values, labels: labels, barColor: HRTheme.payroll, maxValue: 60),
          const SizedBox(height: 8),
          Center(child: Text('Amounts in ₹ thousands',
              style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textHint))),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'YTD Summary', icon: Icons.summarize_outlined),
          _ytdRow('Total Gross Earnings', slips.fold(0.0, (s, e) => s + e.grossEarnings)),
          _ytdRow('Total Deductions', slips.fold(0.0, (s, e) => s + e.totalDeductions)),
          _ytdRow('Total Net Salary', slips.fold(0.0, (s, e) => s + e.netSalary), isHighlight: true),
          const Divider(height: 20),
          _ytdRow('PF Contribution', slips.fold(0.0, (s, e) => s + e.pfDeduction)),
          _ytdRow('TDS Deducted', slips.fold(0.0, (s, e) => s + e.tds)),
        ])),
        const SizedBox(height: 14),
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Monthly Breakdown', icon: Icons.table_chart_outlined),
          ...slips.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: HRTheme.payroll.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(s.month.substring(0, 3), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700, color: HRTheme.payroll)),
                  Text(s.year.substring(2), style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.textSecondary)),
                ]),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('₹${_fmt(s.netSalary)} net', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
                Text('Gross ₹${_fmt(s.grossEarnings)} · -₹${_fmt(s.totalDeductions)}',
                    style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
              ])),
              HRStatusBadge(
                label: s.status,
                color: s.status == 'Paid' ? HRTheme.success : HRTheme.pending,
                bgColor: s.status == 'Paid' ? HRTheme.successLight : HRTheme.pendingLight,
              ),
            ]),
          )),
        ])),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _ytdRow(String label, double value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          color: isHighlight ? HRTheme.payroll : HRTheme.textPrimary,
        )),
        Text('₹${_fmt(value)}', style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: isHighlight ? HRTheme.payroll : HRTheme.textPrimary,
        )),
      ]),
    );
  }

  Widget _buildBonusTab() {
    final slips = _slips;
    final bonusSlips = slips.where((s) => s.bonus > 0 || s.nightAllowance > 0 || s.doctorIncentive > 0).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: HRTheme.orangeGradient,
            borderRadius: BorderRadius.circular(HRTheme.radiusLG),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Incentives YTD', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              Text('₹${_fmt(slips.fold(0.0, (s, e) => s + e.bonus + e.nightAllowance + e.doctorIncentive))}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        if (bonusSlips.isEmpty)
          const HREmptyState(icon: Icons.card_giftcard_outlined, title: 'No Bonus Records', subtitle: 'Bonus and incentive payments will appear here')
        else
          ...bonusSlips.map((s) => HRCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s.month} ${s.year}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: HRTheme.payroll)),
              const SizedBox(height: 10),
              if (s.bonus > 0) _bonusRow('Performance Bonus', s.bonus, Icons.star_rounded, Colors.amber.shade700),
              if (s.nightAllowance > 0) _bonusRow('Night Shift Allowance', s.nightAllowance, Icons.nightlight_round, HRTheme.primaryLight),
              if (s.doctorIncentive > 0) _bonusRow('Doctor Incentive', s.doctorIncentive, Icons.medical_services_outlined, HRTheme.teal),
            ]),
          )),
        const SizedBox(height: 24),
      ]),
    );
  }

  Widget _bonusRow(String label, double amount, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500))),
        Text('₹${_fmt(amount)}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }

  Widget _buildDownloadTab() {
    final slips = _slips;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slips.length,
      itemBuilder: (_, i) {
        final s = slips[i];
        return HRCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(gradient: HRTheme.purpleGradient, borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(s.month.substring(0, 3), style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(s.year.substring(2), style: GoogleFonts.poppins(fontSize: 9, color: Colors.white70)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Salary Slip – ${s.month} ${s.year}', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700)),
              Text('Net: ₹${_fmt(s.netSalary)} · ${s.creditDate}',
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ])),
            const SizedBox(width: 8),
            HRStatusBadge(label: s.status, color: HRTheme.success, bgColor: HRTheme.successLight),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: HRTheme.payroll.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                child: Icon(Icons.download_rounded, size: 18, color: HRTheme.payroll),
              ),
            ),
          ]),
        );
      },
    );
  }

  Widget _earningRow(String label, double amount, IconData icon, Color color, {bool isBold = false, bool isDeduction = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusXS)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: GoogleFonts.poppins(
          fontSize: 12, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          color: HRTheme.textPrimary,
        ))),
        Text('${isDeduction ? '-' : '+'}₹${_fmt(amount)}', style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          color: isDeduction ? HRTheme.error : HRTheme.success,
        )),
      ]),
    );
  }

  Widget _salaryPill(String label, String val, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
    child: Column(children: [
      Text(val, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9)),
    ]),
  );

  String _fmt(double v) {
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toStringAsFixed(0);
  }
}
