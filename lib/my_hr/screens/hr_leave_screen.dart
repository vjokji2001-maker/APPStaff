import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_mock_data.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRLeaveScreen extends StatefulWidget {
  const HRLeaveScreen({super.key});
  @override
  State<HRLeaveScreen> createState() => _HRLeaveScreenState();
}

class _HRLeaveScreenState extends State<HRLeaveScreen> {
  int _tab = 0;
  List<LeaveBalance> _balances = [];
  List<LeaveApplication> _applications = [];
  bool _isLoadingBalances = true;
  bool _isLoadingApplications = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _fetchBalances();
    _fetchApplications();
  }

  Future<void> _fetchBalances() async {
    try {
      final dynamic res = await HRApiService.getLeaveBalances();
      final dataList = (res is Map && res['data'] != null) ? res['data'] as List : res as List<dynamic>;
      setState(() {
        _balances = dataList.map((e) => LeaveBalance.fromJson(e)).toList();
        _isLoadingBalances = false;
      });
    } catch (e) {
      print('Error fetching leave balances: $e');
      setState(() {
        _balances = [];
        _isLoadingBalances = false;
      });
    }
  }

  Future<void> _fetchApplications() async {
    try {
      final dynamic res = await HRApiService.getLeaveRequests();
      final dataList = (res is Map && res['data'] != null) ? res['data'] as List : res as List<dynamic>;
      setState(() {
        _applications = dataList.map((e) => LeaveApplication.fromJson(e)).toList();
        _isLoadingApplications = false;
      });
    } catch (e) {
      print('Error fetching leave applications: $e');
      setState(() {
        _applications = [];
        _isLoadingApplications = false;
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
          title: 'My Leave',
          subtitle: 'Manage your leave requests',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: _showApplyLeave,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.add, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text('Apply', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ],
        ),
        HRTabBar(
          tabs: const ['Balance', 'History', 'Calendar'],
          selectedIndex: _tab,
          onTabChanged: (i) => setState(() => _tab = i),
          activeColor: HRTheme.leave,
        ),
        Expanded(child: IndexedStack(index: _tab, children: [
          _buildBalanceTab(),
          _buildHistoryTab(),
          _buildCalendarTab(),
        ])),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeave,
        backgroundColor: HRTheme.leave,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Apply Leave', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildBalanceTab() {
    if (_isLoadingBalances) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const HRSectionHeader(title: 'Leave Balance Overview', icon: Icons.beach_access_rounded),
          if (_balances.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('No leave balances available')),
            ),
          ..._balances.map((lb) {
            Color color;
            try {
              color = Color(int.parse(lb.colorHex.replaceFirst('#', '0xFF')));
            } catch (e) {
              color = HRTheme.leave;
            }
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 12, height: 12,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(lb.leaveType,
                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600))),
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${lb.available}', style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w800, color: color)),
                  TextSpan(text: ' / ${lb.total}', style: GoogleFonts.poppins(
                      fontSize: 12, color: HRTheme.textSecondary)),
                ])),
              ]),
              const SizedBox(height: 6),
              HRProgressBar(value: lb.total > 0 ? lb.available / lb.total : 0, color: color),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Used: ${lb.used}  Pending: ${lb.pending}',
                    style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textSecondary)),
                Text('Available: ${lb.available}',
                    style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ]),
            ]),
          );
        }),
      ])),
    ]),
  );
  }

  Widget _buildHistoryTab() {
    if (_isLoadingApplications) {
      return const Center(child: CircularProgressIndicator());
    }
    String _filter = 'All';
    return StatefulBuilder(builder: (_, ss) {
      final filtered = _filter == 'All' ? _applications
          : _applications.where((a) => a.status == _filter).toList();
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: ['All','Pending','Approved','Rejected'].map((f) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => ss(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _filter == f ? HRTheme.leave : Colors.transparent,
                    borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                    border: Border.all(color: _filter == f ? HRTheme.leave : Colors.grey.shade300),
                  ),
                  child: Text(f, style: GoogleFonts.poppins(fontSize: 12,
                      fontWeight: _filter == f ? FontWeight.w700 : FontWeight.w500,
                      color: _filter == f ? Colors.white : HRTheme.textSecondary)),
                ),
              ),
            ),
          ).toList()),
        ),
        Expanded(child: filtered.isEmpty
          ? const HREmptyState(icon: Icons.event_busy, title: 'No Applications', subtitle: 'No leave applications found')
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _LeaveCard(app: filtered[i]),
            )),
      ]);
    });
  }

  Widget _buildCalendarTab() {
    final now = DateTime.now();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        HRCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          HRSectionHeader(title: '${["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][now.month - 1]} ${now.year} Calendar',
              icon: Icons.calendar_month_rounded),
          _buildMiniCalendar(now),
        ])),
        const SizedBox(height: 14),
        const HRSectionHeader(title: 'Upcoming Holidays', icon: Icons.event_note_rounded),
        // Temporarily keep mock holidays or handle API integration later
        ...HRMockData.holidays.map((h) => HRCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(children: [
            Container(width: 44, height: 44,
              decoration: BoxDecoration(color: HRTheme.leave.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(h.date.split(' ')[0], style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w800, color: HRTheme.leave)),
                Text(h.date.split(' ')[1].substring(0, 3),
                    style: GoogleFonts.poppins(fontSize: 9, color: HRTheme.textSecondary)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${h.day} · ${h.type}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
            ])),
          ]),
        )),
      ]),
    );
  }

  Widget _buildMiniCalendar(DateTime now) {
    final firstDay = DateTime(now.year, now.month, 1);
    final startWeekday = firstDay.weekday;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leaveSet = _applications
        .where((a) => a.status == 'Approved')
        .map((a) => a.fromDate.split(' ')[0])
        .toSet();
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M','T','W','T','F','S','S'].map((d) =>
              SizedBox(width: 36, child: Center(child: Text(d,
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w700,
                      color: HRTheme.textSecondary))))).toList()),
      const SizedBox(height: 4),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4,
            childAspectRatio: 1.0),
        itemCount: startWeekday - 1 + daysInMonth,
        itemBuilder: (_, i) {
          if (i < startWeekday - 1) return const SizedBox();
          final day = i - startWeekday + 2;
          final isToday = day == now.day;
          final isLeave = leaveSet.contains('$day');
          return Container(
            decoration: BoxDecoration(
              color: isToday ? HRTheme.primaryDark
                  : isLeave ? HRTheme.leave.withOpacity(0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text('$day', style: GoogleFonts.poppins(
              fontSize: 12, fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
              color: isToday ? Colors.white
                  : isLeave ? HRTheme.leave
                  : HRTheme.textPrimary,
            ))),
          );
        },
      ),
    ]);
  }

  void _showApplyLeave() {
    String? selectedType;
    DateTime? from, to;
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, ss) => Container(
        padding: EdgeInsets.only(
          top: 20, left: 16, right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? HRTheme.bgCardDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXXL)),
        ),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(HRTheme.radiusFull)))),
          const SizedBox(height: 16),
          Text('Apply Leave', style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w700, color: HRTheme.textPrimary)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(labelText: 'Leave Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM))),
            items: ['Annual Leave','Sick Leave','Casual Leave','Emergency Leave','Compensatory Off']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => ss(() => selectedType = v),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context, initialDate: DateTime.now(),
                    firstDate: DateTime.now(), lastDate: DateTime(2027));
                if (d != null) ss(() => from = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 16, color: HRTheme.leave),
                  const SizedBox(width: 8),
                  Text(from == null ? 'From Date' : '${from!.day}/${from!.month}/${from!.year}',
                      style: GoogleFonts.poppins(fontSize: 13,
                          color: from == null ? HRTheme.textHint : HRTheme.textPrimary)),
                ]),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () async {
                final d = await showDatePicker(context: context,
                    initialDate: from ?? DateTime.now(),
                    firstDate: from ?? DateTime.now(), lastDate: DateTime(2027));
                if (d != null) ss(() => to = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
                child: Row(children: [
                  const Icon(Icons.calendar_today, size: 16, color: HRTheme.leave),
                  const SizedBox(width: 8),
                  Text(to == null ? 'To Date' : '${to!.day}/${to!.month}/${to!.year}',
                      style: GoogleFonts.poppins(fontSize: 13,
                          color: to == null ? HRTheme.textHint : HRTheme.textPrimary)),
                ]),
              ),
            )),
          ]),
          if (from != null && to != null) ...[
            const SizedBox(height: 8),
            Text('Total Days: ${to!.difference(from!).inDays + 1}',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: HRTheme.leave)),
          ],
          const SizedBox(height: 12),
          TextFormField(controller: reasonCtrl, maxLines: 3,
              decoration: InputDecoration(labelText: 'Reason',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)))),
          const SizedBox(height: 16),
          HRPrimaryButton(label: 'Submit Leave Request', icon: Icons.send_rounded,
              color: HRTheme.leave,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Leave request submitted!', style: GoogleFonts.poppins()),
                  backgroundColor: HRTheme.success, behavior: SnackBarBehavior.floating));
              }),
        ])),
      )),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  final LeaveApplication app;
  const _LeaveCard({required this.app});

  HRStatus get _status {
    switch (app.status) {
      case 'Approved': return HRStatus.approved;
      case 'Rejected': return HRStatus.rejected;
      default: return HRStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HRCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(app.leaveType,
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700))),
          HRStatusBadge.fromStatus(_status),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.date_range_rounded, size: 14, color: HRTheme.textSecondary),
          const SizedBox(width: 6),
          Text('${app.fromDate} – ${app.toDate}',
              style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
          const SizedBox(width: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: HRTheme.infoLight,
                  borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
              child: Text('${app.days} Day${app.days > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: HRTheme.info))),
        ]),
        const SizedBox(height: 4),
        Text('Reason: ${app.reason}',
            style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
        if (app.remarks != null) ...[
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _status == HRStatus.approved ? HRTheme.successLight
                    : _status == HRStatus.rejected ? HRTheme.errorLight : HRTheme.pendingLight,
                borderRadius: BorderRadius.circular(HRTheme.radiusSM),
              ),
              child: Text('Remarks: ${app.remarks}',
                  style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textPrimary))),
        ],
        const SizedBox(height: 4),
        Text('Applied: ${app.appliedOn}',
            style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textHint)),
      ]),
    );
  }
}
