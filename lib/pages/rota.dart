import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../my_hr/data/hr_api_service.dart';

class AppColors {
  static const Color primary = Color(0xFF0A5C8E);
  static const Color primaryDark = Color(0xFF064663);
  static const Color accent = Color(0xFF00A8A8);
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  static const Color purple = Color(0xFF9B59B6);
  static const Color background = Color(0xFFF8F9FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textHint = Color(0xFFBDC3C7);
  static const Color divider = Color(0xFFECF0F1);
}

class RotaPage extends StatefulWidget {
  const RotaPage({Key? key}) : super(key: key);

  @override
  State<RotaPage> createState() => _RotaPageState();
}

class _RotaPageState extends State<RotaPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _loadError;

  final List<String> _filterOptions = [
    'All',
    'Cardiology',
    'Emergency',
    'ICU',
    'Pediatrics',
    'Administration',
  ];
  List<String> get _availableFilters => [
    ..._filterOptions,
    ..._allShifts.map((shift) => shift.department),
  ].toSet().toList();

  List<RotaShift> _allShifts = [];

  List<RotaShift> get _filteredShifts {
    if (_selectedFilter == 'All') return _allShifts;
    return _allShifts
        .where((shift) => shift.department == _selectedFilter)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRota();
  }

  Future<void> _loadRota() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final firstDay = DateTime(_selectedDate.year, _selectedDate.month);
      final lastDay = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
      final response = await HRApiService.getShiftRoster(
        fromDate: DateFormat('yyyy-MM-dd').format(firstDay),
        toDate: DateFormat('yyyy-MM-dd').format(lastDay),
        pageSize: 1000,
        resolveAllEmployees: true,
      );
      final data = response is Map ? response['data'] ?? response : null;
      final rawRows = data is Map
          ? data['dataList'] ?? data['content'] ?? data['records']
          : data is List
          ? data
          : null;
      if (rawRows is! List) {
        throw Exception('Shift roster response did not contain an employee list.');
      }

      final rows = <dynamic>[];
      for (final row in rawRows) {
        if (row is List) {
          rows.addAll(row);
        } else {
          rows.add(row);
        }
      }

      final loaded = <RotaShift>[];
      for (final row in rows) {
        if (row is! Map) continue;
        final staffName = (row['employeeName'] ??
                row['formalName'] ??
                row['name'] ??
                'Employee')
            .toString();
        final employeeId =
            (row['employeeCode'] ?? row['employeeId'] ?? row['empId'] ?? '')
                .toString();
        final role = (row['designationName'] ??
                row['designation'] ??
                row['jobTitle'] ??
                row['role'] ??
                '')
            .toString();
        final department = (row['departmentName'] ??
                row['department'] ??
                row['department_name'] ??
                'Other')
            .toString();
        final shifts = row['empShiftList'];
        if (shifts is! List) continue;

        for (final shift in shifts) {
          if (shift is! Map) continue;
          final date = _parseRosterDate(shift['date']?.toString() ?? '');
          if (date == null) continue;
          final shiftName = (shift['shiftName'] ??
                  shift['name'] ??
                  shift['shiftCode'] ??
                  '')
              .toString();
          final leave = shift['leave'] == true ||
              shift['status']?.toString().toLowerCase().contains('leave') == true;
          final off = shiftName.isEmpty ||
              shiftName.toLowerCase() == 'off' ||
              shiftName.toLowerCase() == 'weekly off';
          loaded.add(
            RotaShift(
              id: '${employeeId}_${DateFormat('yyyyMMdd').format(date)}',
              staffName: staffName,
              employeeId: employeeId,
              role: role,
              department: department,
              date: date,
              shiftType: shiftName.isEmpty ? (leave ? 'Leave' : 'Off') : shiftName,
              shiftTiming:
                  '${shift['inTime'] ?? shift['startTime'] ?? ''} - '
                  '${shift['outTime'] ?? shift['endTime'] ?? ''}',
              assignedWard:
                  (shift['ward'] ?? shift['location'] ?? 'Main Hospital')
                      .toString(),
              status: leave
                  ? ShiftStatus.onLeave
                  : off
                  ? ShiftStatus.offDay
                  : _statusForDate(date),
              emergencyDuty: _asBool(shift['emergencyDuty']),
              backupDuty: _asBool(shift['backupDuty']),
              onCallStatus: _asBool(shift['onCallStatus'] ?? shift['onCall']),
              avatarColor: _avatarColors[loaded.length % _avatarColors.length],
            ),
          );
        }
      }
      loaded.sort((a, b) => a.date.compareTo(b.date));
      if (!mounted) return;
      setState(() {
        _allShifts = loaded;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  static const _avatarColors = [
    0xFF3498DB,
    0xFF2ECC71,
    0xFFF39C12,
    0xFF9B59B6,
    0xFFE74C3C,
  ];

  static DateTime? _parseRosterDate(String value) {
    final iso = DateTime.tryParse(value);
    if (iso != null) return iso;
    for (final pattern in ['dd-MM-yyyy', 'dd/MM/yyyy']) {
      try {
        return DateFormat(pattern).parseStrict(value);
      } on FormatException {
        continue;
      }
    }
    return null;
  }

  static ShiftStatus _statusForDate(DateTime date) {
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (dateOnly.isBefore(todayOnly)) return ShiftStatus.completed;
    if (dateOnly.isAtSameMomentAs(todayOnly)) return ShiftStatus.ongoing;
    return ShiftStatus.upcoming;
  }

  static bool _asBool(dynamic value) =>
      value == true || value?.toString().toLowerCase() == 'true' || value == 1;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCompactControls(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController!,
                children: [
                  _buildShiftsList(),
                  _buildStatusOverview(),
                  _buildEmergencyView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROTA Management',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Staff Schedule',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _downloadROTA,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.download_outlined,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Date Navigator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _navigateDate(-1),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_left,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('d MMM').format(_selectedDate),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _navigateDate(1),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Filter Dropdown - Made more visible
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFilter,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  isExpanded: true,
                  dropdownColor: AppColors.surface,
                  items: _availableFilters.map((filter) {
                    return DropdownMenuItem(
                      value: filter,
                      child: Text(
                        filter,
                        style: GoogleFonts.inter(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedFilter = value!),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Today Button
          GestureDetector(
            onTap: () => setState(() => _selectedDate = DateTime.now()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Today',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: TabBar(
        controller: _tabController!,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primary,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Shifts'),
          Tab(text: 'Overview'),
          Tab(text: 'Emergency'),
        ],
      ),
    );
  }

  Widget _buildShiftsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load the live shift roster.\n$_loadError',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: _loadRota, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final shifts = _filteredShifts;

    if (shifts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text(
              'No shifts found',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shifts.length,
      itemBuilder: (context, index) {
        final shift = shifts[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 300),
          child: SlideAnimation(
            verticalOffset: 20,
            child: FadeInAnimation(child: _buildShiftCard(shift)),
          ),
        );
      },
    );
  }

  Widget _buildShiftCard(RotaShift shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showShiftDetails(shift),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(shift.avatarColor),
                            Color(shift.avatarColor).withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          shift.staffName.split(' ').map((e) => e[0]).join(''),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Staff Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shift.staffName,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(
                                    shift.role,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  shift.role,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: _getRoleColor(shift.role),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                shift.employeeId,
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          shift.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(shift.status),
                            size: 10,
                            color: _getStatusColor(shift.status),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _getStatusText(shift.status),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(shift.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Shift Details Row
                Row(
                  children: [
                    _buildCompactDetail(Icons.access_time, shift.shiftTiming),
                    const SizedBox(width: 8),
                    _buildCompactDetail(
                      Icons.medical_services,
                      shift.department,
                    ),
                    const SizedBox(width: 8),
                    _buildCompactDetail(Icons.location_on, shift.assignedWard),
                  ],
                ),
                if (shift.emergencyDuty ||
                    shift.backupDuty ||
                    shift.onCallStatus) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (shift.emergencyDuty)
                        _buildEmergencyBadge('Emergency', AppColors.error),
                      if (shift.backupDuty)
                        _buildEmergencyBadge('Backup', AppColors.warning),
                      if (shift.onCallStatus)
                        _buildEmergencyBadge('On-Call', AppColors.info),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactDetail(IconData icon, String text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 8, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOverview() {
    final shifts = _allShifts;
    final stats = {
      'Upcoming': shifts.where((s) => s.status == ShiftStatus.upcoming).length,
      'Ongoing': shifts.where((s) => s.status == ShiftStatus.ongoing).length,
      'Completed': shifts
          .where((s) => s.status == ShiftStatus.completed)
          .length,
      'Off': shifts.where((s) => s.status == ShiftStatus.offDay).length,
      'Leave': shifts.where((s) => s.status == ShiftStatus.onLeave).length,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.entries.map((entry) {
                return Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColorFromName(
                          entry.key,
                        ).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          entry.value.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColorFromName(entry.key),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.key,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Department List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Departments',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...[
                  'Cardiology',
                  'Emergency',
                  'ICU',
                  'Pediatrics',
                  'Administration',
                ].map((dept) {
                  final count = shifts
                      .where((s) => s.department == dept)
                      .length;
                  if (count == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getDepartmentColor(dept),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dept,
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                        ),
                        Text(
                          '$count staff',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyView() {
    final emergencyShifts = _allShifts
        .where((s) => s.emergencyDuty || s.backupDuty || s.onCallStatus)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Emergency Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error,
                  AppColors.error.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Protocol',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${emergencyShifts.length} active',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildEmergencyStat(
                      _allShifts.where((s) => s.emergencyDuty).length,
                      Icons.warning,
                    ),
                    const SizedBox(width: 12),
                    _buildEmergencyStat(
                      _allShifts.where((s) => s.backupDuty).length,
                      Icons.backup,
                    ),
                    const SizedBox(width: 12),
                    _buildEmergencyStat(
                      _allShifts.where((s) => s.onCallStatus).length,
                      Icons.phone_in_talk,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Emergency List
          if (emergencyShifts.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No Emergency Assignments',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            ...emergencyShifts.map(
              (shift) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getEmergencyColor(shift).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getEmergencyColor(shift).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          _getEmergencyIcon(shift),
                          color: _getEmergencyColor(shift),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shift.staffName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${shift.role} • ${shift.department}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 4,
                            children: [
                              if (shift.emergencyDuty)
                                _buildEmergencyTag(
                                  'Emergency',
                                  AppColors.error,
                                ),
                              if (shift.backupDuty)
                                _buildEmergencyTag('Backup', AppColors.warning),
                              if (shift.onCallStatus)
                                _buildEmergencyTag('On-Call', AppColors.info),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            shift.shiftType,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            shift.shiftTiming,
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyStat(int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(height: 2),
        Text(
          count.toString(),
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  void _navigateDate(int days) {
    final previousMonth = _selectedDate.month;
    final nextDate = _selectedDate.add(Duration(days: days));
    setState(() => _selectedDate = nextDate);
    if (nextDate.month != previousMonth) _loadRota();
  }

  void _showDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      final monthChanged =
          picked.month != _selectedDate.month || picked.year != _selectedDate.year;
      setState(() => _selectedDate = picked);
      if (monthChanged) _loadRota();
    }
  }

  void _showShiftDetails(RotaShift shift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(shift.avatarColor),
                        Color(shift.avatarColor).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      shift.staffName.split(' ').map((e) => e[0]).join(''),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shift.staffName,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${shift.role} • ${shift.employeeId}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              Icons.calendar_today,
              'Date',
              DateFormat('dd MMM yyyy').format(shift.date),
            ),
            _buildDetailRow(
              Icons.access_time,
              'Shift',
              '${shift.shiftType} (${shift.shiftTiming})',
            ),
            _buildDetailRow(
              Icons.medical_services,
              'Department',
              shift.department,
            ),
            _buildDetailRow(Icons.location_on, 'Ward', shift.assignedWard),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );

  void _downloadROTA() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, size: 32, color: AppColors.success),
            ),
            const SizedBox(height: 12),
            Text(
              'Download Started',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your ROTA report is being generated',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'OK',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) => role.contains('Doctor')
      ? AppColors.info
      : role.contains('Nurse')
      ? AppColors.success
      : AppColors.warning;
  Color _getStatusColor(ShiftStatus status) => status == ShiftStatus.upcoming
      ? AppColors.info
      : status == ShiftStatus.ongoing
      ? AppColors.success
      : status == ShiftStatus.completed
      ? AppColors.warning
      : status == ShiftStatus.offDay
      ? AppColors.textSecondary
      : AppColors.purple;
  Color _getStatusColorFromName(String name) => name == 'Upcoming'
      ? AppColors.info
      : name == 'Ongoing'
      ? AppColors.success
      : name == 'Completed'
      ? AppColors.warning
      : name == 'Off'
      ? AppColors.textSecondary
      : AppColors.purple;
  IconData _getStatusIcon(ShiftStatus status) => status == ShiftStatus.upcoming
      ? Icons.schedule
      : status == ShiftStatus.ongoing
      ? Icons.play_circle
      : status == ShiftStatus.completed
      ? Icons.check_circle
      : status == ShiftStatus.offDay
      ? Icons.beach_access
      : Icons.flight;
  String _getStatusText(ShiftStatus status) => status == ShiftStatus.upcoming
      ? 'Upcoming'
      : status == ShiftStatus.ongoing
      ? 'Ongoing'
      : status == ShiftStatus.completed
      ? 'Completed'
      : status == ShiftStatus.offDay
      ? 'Off Day'
      : 'On Leave';
  Color _getDepartmentColor(String dept) => dept == 'Cardiology'
      ? AppColors.error
      : dept == 'Emergency'
      ? AppColors.warning
      : dept == 'ICU'
      ? AppColors.info
      : AppColors.success;
  Color _getEmergencyColor(RotaShift shift) => shift.emergencyDuty
      ? AppColors.error
      : shift.backupDuty
      ? AppColors.warning
      : AppColors.info;
  IconData _getEmergencyIcon(RotaShift shift) => shift.emergencyDuty
      ? Icons.warning_amber_rounded
      : shift.backupDuty
      ? Icons.backup
      : Icons.phone_in_talk;
}

enum ShiftStatus { upcoming, ongoing, completed, offDay, onLeave }

class RotaShift {
  final String id,
      staffName,
      employeeId,
      role,
      department,
      shiftType,
      shiftTiming,
      assignedWard;
  final DateTime date;
  final ShiftStatus status;
  final bool emergencyDuty, backupDuty, onCallStatus;
  final int avatarColor;
  RotaShift({
    required this.id,
    required this.staffName,
    required this.employeeId,
    required this.role,
    required this.department,
    required this.date,
    required this.shiftType,
    required this.shiftTiming,
    required this.assignedWard,
    required this.status,
    required this.emergencyDuty,
    required this.backupDuty,
    required this.onCallStatus,
    required this.avatarColor,
  });
}
