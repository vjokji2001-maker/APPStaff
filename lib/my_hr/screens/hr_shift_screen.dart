import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/hr_theme.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';

class HRShiftScreen extends StatefulWidget {
  const HRShiftScreen({super.key});
  @override
  State<HRShiftScreen> createState() => _HRShiftScreenState();
}

class _HRShiftScreenState extends State<HRShiftScreen> {
  int _tabIndex = 0;
  final List<String> _tabs = ['Weekly', 'Shift Roster', 'Templates', 'Swap Requests'];

  bool _isLoadingRoster = false;
  bool _isLoadingTemplates = false;
  String? _rosterError;
  String? _templatesError;
  String _searchName = '';
  String _searchCode = '';
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();
  final TextEditingController _searchNameController = TextEditingController();
  final TextEditingController _searchCodeController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _branchController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  int _page = 1;
  final int _pageSize = 10;
  String _sortingField = 'employeeName';
  String _sortingLabel = 'EmployeeName';
  String _sortingOrder = 'ASC';

  List<ShiftRosterColumn> _rosterColumns = [];
  List<ShiftRosterRow> _rosterRows = [];
  ShiftRosterPagination _rosterPagination = const ShiftRosterPagination(currentPage: 1, pageSize: 10, totalRecords: 0, totalPages: 1);

  List<ShiftTemplate> _shiftTemplates = [];

  @override
  void initState() {
    super.initState();
    _fetchRosterData();
    _fetchShiftTemplates();
  }

  @override
  void dispose() {
    _searchNameController.dispose();
    _searchCodeController.dispose();
    _companyController.dispose();
    _branchController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _fetchRosterData() async {
    if (mounted) {
      setState(() {
        _isLoadingRoster = true;
        _rosterError = null;
      });
    }
    try {
      final response = await HRApiService.getShiftRoster(
        fromDate: _formatDate(_fromDate),
        toDate: _formatDate(_toDate),
        searchName: _searchName,
        searchCode: _searchCode,
        companyId: _companyController.text.trim(),
        branchId: _branchController.text.trim(),
        departmentId: _departmentController.text.trim(),
        designationId: _designationController.text.trim(),
        page: _page,
        pageSize: _pageSize,
        sortingField: _sortingField,
        sortingLabel: _sortingLabel,
        sortingOrder: _sortingOrder,
      );

      final data = _asMap(response is Map ? response['data'] ?? response : null);
      final columns = _asList(data['columns'] ?? data['columnList']);
      final dataList = _asList(data['dataList'] ?? data['content'] ?? data['records']);
      final pagination = _asMap(data['pagination'] ?? data['pageInfo']);

      // Build columns list
      final cols = columns
          .whereType<Map>()
          .map((item) => ShiftRosterColumn.fromJson(Map<String, dynamic>.from(item)))
          .where((column) => column.field.isNotEmpty)
          .toList();

      // DataList may be a list of maps or a list of lists (array rows). Handle both.
      final rows = <ShiftRosterRow>[];
      for (final item in dataList) {
        if (item is Map) {
          rows.add(ShiftRosterRow.fromJson(Map<String, dynamic>.from(item)));
        } else if (item is List) {
          final m = <String, dynamic>{};
          for (var i = 0; i < cols.length; i++) {
            final field = cols[i].field;
            m[field] = i < item.length ? item[i] : '';
          }
          rows.add(ShiftRosterRow(values: m));
        }
      }

      // If server reports zero total records but returns an empty-array row ([[]]),
      // treat as no rows so UI doesn't render a single blank 'Off' entry.
      int totalRecords = 0;
      try {
        totalRecords = (pagination['totalRecords'] ?? pagination['total'] ?? pagination['total_records'] ?? pagination['totalItems'] ?? 0) is int
            ? (pagination['totalRecords'] ?? pagination['total'] ?? pagination['total_records'] ?? pagination['totalItems'] ?? 0) as int
            : int.tryParse((pagination['totalRecords'] ?? pagination['total'] ?? pagination['total_records'] ?? pagination['totalItems'] ?? '0').toString()) ?? 0;
      } catch (_) {
        totalRecords = 0;
      }
      final looksLikeEmptyArrayRow = dataList.length == 1 && dataList.first is List && (dataList.first as List).every((e) => e == null || e.toString().trim().isEmpty);
      if (totalRecords == 0 && looksLikeEmptyArrayRow) {
        rows.clear();
      }

      if (!mounted) return;
      setState(() {
        _rosterColumns = cols;
        _rosterRows = rows;
        _rosterPagination = pagination.isNotEmpty
            ? ShiftRosterPagination.fromJson(pagination)
            : ShiftRosterPagination(
                currentPage: _page,
                pageSize: _pageSize,
                totalRecords: rows.length,
                totalPages: 1,
              );
      });
    } catch (e) {
      debugPrint('Error fetching shift roster: $e');
      if (mounted) {
        setState(() {
          _rosterColumns = [];
          _rosterRows = [];
          _rosterError = 'Shift roster could not be loaded. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingRoster = false);
    }
  }

  Future<void> _fetchShiftTemplates() async {
    if (mounted) {
      setState(() {
        _isLoadingTemplates = true;
        _templatesError = null;
      });
    }
    try {
      final response = await HRApiService.getShiftTemplates();
      final data = response is Map ? response['data'] ?? response : response;
      final list = _asList(data is Map ? data['dataList'] ?? data['content'] ?? data['records'] : data);
      if (!mounted) return;
      setState(() {
        _shiftTemplates = list
            .whereType<Map>()
            .map((item) => ShiftTemplate.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      });
    } catch (e) {
      debugPrint('Error fetching shift templates: $e');
      if (mounted) {
        setState(() {
          _shiftTemplates = [];
          _templatesError = 'Shift templates could not be loaded. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingTemplates = false);
    }
  }

  void _onSearchRoster() {
    setState(() {
      _searchName = _searchNameController.text.trim();
      _searchCode = _searchCodeController.text.trim();
      _page = 1;
    });
    _fetchRosterData();
  }

  void _clearRosterFilters() {
    _searchNameController.clear();
    _searchCodeController.clear();
    _companyController.clear();
    _branchController.clear();
    _departmentController.clear();
    _designationController.clear();
    setState(() {
      _searchName = '';
      _searchCode = '';
      _companyController.text = '';
      _branchController.text = '';
      _departmentController.text = '';
      _designationController.text = '';
      _fromDate = DateTime.now().subtract(const Duration(days: 7));
      _toDate = DateTime.now();
      _page = 1;
    });
    _fetchRosterData();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) => value is List ? value : const [];

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
          if (_fromDate.isAfter(_toDate)) {
            _toDate = _fromDate;
          }
        } else {
          _toDate = picked;
          if (_toDate.isBefore(_fromDate)) {
            _fromDate = _toDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : HRTheme.bgLight,
      floatingActionButton: _tabIndex == 3
          ? FloatingActionButton.extended(
              onPressed: _showSwapRequestSheet,
              backgroundColor: HRTheme.shift,
              icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white),
              label: Text('Request Swap', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            )
          : null,
      body: Column(children: [
        HRGradientHeader(
          title: 'My Shift',
          subtitle: 'Schedule, roster and templates',
        ),
        HRTabBar(
          tabs: _tabs,
          selectedIndex: _tabIndex,
          onTabChanged: (i) => setState(() => _tabIndex = i),
          activeColor: HRTheme.shift,
        ),
        Expanded(child: _buildTab()),
      ]),
    );
  }

  Widget _buildTab() {
    switch (_tabIndex) {
      case 0:
        return _buildWeeklyTab();
      case 1:
        return _buildRosterTab();
      case 2:
        return _buildTemplatesTab();
      case 3:
        return _buildSwapRequestsTab();
      default:
        return _buildWeeklyTab();
    }
  }

  Widget _buildWeeklyTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoadingRoster) return const Center(child: CircularProgressIndicator());
    if (_rosterError != null) return _buildDataState(_rosterError!, _fetchRosterData, isDark);

    final schedule = _weeklyScheduleFromRoster();
    if (schedule.isEmpty) {
      return _buildDataState('No shift schedule is available for the selected dates.', _fetchRosterData, isDark);
    }
    final today = schedule.firstWhere((s) => s.isToday, orElse: () => schedule.first);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: HRTheme.tealGradient,
            borderRadius: BorderRadius.circular(HRTheme.radiusLG),
            boxShadow: HRTheme.elevatedShadow,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text("Today's Shift", style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
                child: Text(today.type, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
              ),
            ]),
            const SizedBox(height: 10),
            Text(today.shiftName, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.access_time_rounded, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text('${today.startTime} – ${today.endTime}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.local_hospital_outlined, color: Colors.white70, size: 14),
              const SizedBox(width: 4),
              Text(today.ward, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
            ]),
          ]),
        ),
        const SizedBox(height: 20),
        const HRSectionHeader(title: 'This Week', icon: Icons.view_week_outlined),
        ...schedule.map((s) => _buildShiftCard(s, isDark)),
        const SizedBox(height: 24),
      ]),
    );
  }

  List<ShiftSchedule> _weeklyScheduleFromRoster() {
    if (_rosterColumns.isEmpty || _rosterRows.isEmpty) return const [];

    final row = _rosterRows.first;
    final now = DateTime.now();
    final schedule = <ShiftSchedule>[];
    for (final column in _rosterColumns) {
      final date = _parseRosterDate(column.field) ?? _parseRosterDate(column.label);
      if (date == null) continue;

      final value = row.values[column.field] ?? row.values[column.field.toLowerCase()];
      final details = _asMap(value);
      final shiftName = details['shiftName']?.toString() ??
          details['name']?.toString() ??
          details['shiftCode']?.toString() ??
          value?.toString() ??
          '';
      schedule.add(ShiftSchedule(
        date: _formatDate(date),
        day: _weekdayShort(date.weekday),
        shiftName: shiftName,
        startTime: details['inTime']?.toString() ?? details['startTime']?.toString() ?? '',
        endTime: details['outTime']?.toString() ?? details['endTime']?.toString() ?? '',
        ward: details['ward']?.toString() ?? details['location']?.toString() ?? '',
        type: details['type']?.toString() ?? 'Regular',
        isToday: date.year == now.year && date.month == now.month && date.day == now.day,
      ));
    }
    schedule.sort((a, b) => a.date.compareTo(b.date));
    return schedule;
  }

  DateTime? _parseRosterDate(String value) {
    final isoMatch = RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\b').firstMatch(value);
    if (isoMatch != null) return DateTime.tryParse(isoMatch.group(0)!);

    final indianMatch = RegExp(r'\b(\d{2})-(\d{2})-(\d{4})\b').firstMatch(value);
    if (indianMatch == null) return null;
    return DateTime(
      int.parse(indianMatch.group(3)!),
      int.parse(indianMatch.group(2)!),
      int.parse(indianMatch.group(1)!),
    );
  }

  Widget _buildDataState(String message, VoidCallback onRetry, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.event_busy_rounded, size: 42, color: HRTheme.textSecondary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(color: isDark ? Colors.white70 : HRTheme.textSecondary)),
          const SizedBox(height: 12),
          OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
        ]),
      ),
    );
  }

 Widget _buildShiftCard(ShiftSchedule s, bool isDark) {
  final isOff = s.shiftName.toLowerCase() == 'off' ||
      s.shiftName.toLowerCase() == 'weekly off' ||
      s.shiftName.isEmpty;

  final typeColor = _shiftColor(s.shiftName);

  // Extract only the day number (e.g. "23") from "23-07-2026"
  final dayNumber = s.date.contains('-')
      ? s.date.split('-').first
      : s.date.split(' ').first;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: s.isToday
          ? HRTheme.shift.withOpacity(0.08)
          : (isDark ? HRTheme.bgCardDark : Colors.white),
      borderRadius: BorderRadius.circular(HRTheme.radiusMD),
      border: s.isToday
          ? Border.all(color: HRTheme.shift.withOpacity(0.4), width: 1.5)
          : null,
      boxShadow: HRTheme.cardShadow,
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: s.isToday
              ? HRTheme.shift.withOpacity(0.15)
              : typeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(HRTheme.radiusSM),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              s.day, // Mon / Tue / ...
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: s.isToday ? HRTheme.shift : typeColor,
              ),
            ),
            Text(
              dayNumber, // only "23"
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: s.isToday ? HRTheme.shift : typeColor,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
      title: Text(
        isOff ? 'Day Off' : s.shiftName,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isOff
              ? HRTheme.textHint
              : (isDark ? Colors.white : HRTheme.textPrimary),
        ),
      ),
      subtitle: isOff
          ? Text(
              'Weekly Off',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: HRTheme.textHint,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.startTime.isNotEmpty)
                  Text(
                    '${s.startTime} – ${s.endTime}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: HRTheme.textSecondary,
                    ),
                  ),
                if (s.ward.isNotEmpty)
                  Text(
                    s.ward,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: HRTheme.textHint,
                    ),
                  ),
              ],
            ),
      trailing: s.isToday
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: HRTheme.shift.withOpacity(0.12),
                borderRadius: BorderRadius.circular(HRTheme.radiusFull),
              ),
              child: Text(
                'Today',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: HRTheme.shift,
                ),
              ),
            )
          : (!isOff
              ? HRStatusBadge(
                  label: s.type,
                  color: typeColor,
                  bgColor: typeColor.withOpacity(0.1),
                )
              : null),
    ),
  );
}

  Color _shiftColor(String name) {
    switch (name) {
      case 'Morning': return HRTheme.info;
      case 'Afternoon': return HRTheme.warning;
      case 'Night': return HRTheme.primaryDark;
      default: return HRTheme.textSecondary;
    }
  }

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekday < 1 || weekday > 7) return '';
    return names[weekday - 1];
  }

  Widget _buildRosterTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'Shift Roster', icon: Icons.schedule_rounded),
        const SizedBox(height: 16),
        _buildRosterFilters(isDark),
        const SizedBox(height: 16),
        _isLoadingRoster
            ? const Center(child: CircularProgressIndicator())
            : _renderRosterTable(isDark),
        const SizedBox(height: 16),
        _buildRosterPagination(),
      ]),
    );
  }

  Widget _buildRosterFilters(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildFilterChip('From', _formatDate(_fromDate), () => _selectDate(context, true)),
        _buildFilterChip('To', _formatDate(_toDate), () => _selectDate(context, false)),
        _buildFilterInput('Employee Name', _searchNameController),
        _buildFilterInput('Employee Code', _searchCodeController),
        _buildFilterInput('Company ID', _companyController),
        _buildFilterInput('Branch ID', _branchController),
        _buildFilterInput('Department ID', _departmentController),
        _buildFilterInput('Designation ID', _designationController),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: HRTheme.shift),
              onPressed: _onSearchRoster,
              child: const Text('Search'),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: isDark ? Colors.white : HRTheme.textPrimary),
              onPressed: _clearRosterFilters,
              child: const Text('Clear'),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: HRTheme.bgLight,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(HRTheme.radiusSM),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: HRTheme.textPrimary)),
        ]),
      ),
    );
  }

  Widget _buildFilterInput(String label, TextEditingController controller) {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
        ),
      ),
    );
  }

  Widget _renderRosterTable(bool isDark) {
    if (_rosterRows.isEmpty || _rosterColumns.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? HRTheme.bgCardDark : Colors.white,
          borderRadius: BorderRadius.circular(HRTheme.radiusMD),
          boxShadow: HRTheme.cardShadow,
        ),
        child: Text('No roster data found for the selected filters.', style: GoogleFonts.poppins(color: HRTheme.textSecondary)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateColor.resolveWith((states) => HRTheme.shift.withOpacity(0.08)),
        columns: _rosterColumns
            .map((col) => DataColumn(
                  label: InkWell(
                    onTap: () {
                      setState(() {
                        final asc = _sortingField == col.field && _sortingOrder == 'ASC';
                        _sortingField = col.field;
                        _sortingLabel = col.label;
                        _sortingOrder = asc ? 'DESC' : 'ASC';
                        _fetchRosterData();
                      });
                    },
                    child: Row(children: [
                      Text(col.label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(
                        _sortingField == col.field
                            ? (_sortingOrder == 'ASC' ? Icons.arrow_upward : Icons.arrow_downward)
                            : Icons.unfold_more,
                        size: 16,
                        color: HRTheme.textSecondary,
                      ),
                    ]),
                  ),
                ))
            .toList(),
        rows: _rosterRows.map((row) {
          return DataRow(
            cells: _rosterColumns.map((col) {
              final value = row.values[col.field] ?? row.values[col.field.toLowerCase()] ?? '';
              return DataCell(
                Text(_displayRosterValue(value), style: GoogleFonts.poppins(fontSize: 12, color: isDark ? Colors.white : HRTheme.textPrimary)),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  String _displayRosterValue(dynamic value) {
    if (value is! Map) return value?.toString() ?? '';
    final data = _asMap(value);
    return data['shiftName']?.toString() ??
        data['name']?.toString() ??
        data['shiftCode']?.toString() ??
        data['value']?.toString() ??
        '';
  }

  Widget _buildRosterPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Showing page ${_rosterPagination.currentPage} of ${_rosterPagination.totalPages} · ${_rosterPagination.totalRecords} records',
          style: GoogleFonts.poppins(color: HRTheme.textSecondary, fontSize: 12),
        ),
        Row(children: [
          IconButton(
            onPressed: _page > 1 ? () {
              setState(() {
                _page -= 1;
              });
              _fetchRosterData();
            } : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            onPressed: _page < _rosterPagination.totalPages ? () {
              setState(() {
                _page += 1;
              });
              _fetchRosterData();
            } : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ]),
      ],
    );
  }

  Widget _buildTemplatesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HRSectionHeader(title: 'Shift Templates', icon: Icons.work_outline_rounded),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text('Manage your shift templates and policy settings.', style: GoogleFonts.poppins(color: HRTheme.textSecondary))),
          Row(children: [
            HRPrimaryButton(label: 'New Template', icon: Icons.add_rounded, color: HRTheme.shift, onPressed: () => _showTemplateSheet()),
            const SizedBox(width: 8),
            HRPrimaryButton(label: 'Refresh', icon: Icons.refresh_rounded, color: HRTheme.shift, onPressed: _fetchShiftTemplates),
          ]),
        ]),
        const SizedBox(height: 18),
        _isLoadingTemplates
            ? const Center(child: CircularProgressIndicator())
            : _templatesError != null
                ? _buildDataState(_templatesError!, _fetchShiftTemplates, isDark)
                : _shiftTemplates.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? HRTheme.bgCardDark : Colors.white,
                      borderRadius: BorderRadius.circular(HRTheme.radiusMD),
                      boxShadow: HRTheme.cardShadow,
                    ),
                    child: Text('No shift templates available.', style: GoogleFonts.poppins(color: HRTheme.textSecondary)),
                  )
                : Column(children: _shiftTemplates.map(_buildTemplateCard).toList()),
      ]),
    );
  }

  Widget _buildTemplateCard(ShiftTemplate template) {
    return HRCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(template.name.isNotEmpty ? template.name : 'Unnamed Template', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700))),
            Text(template.code, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary)),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 10, runSpacing: 6, children: [
            _templateBadge('In: ${template.inTime}', HRTheme.info),
            _templateBadge('Out: ${template.outTime}', HRTheme.warning),
            _templateBadge('Total: ${template.totalHours}', HRTheme.primaryDark),
          ]),
          const SizedBox(height: 12),
          Wrap(spacing: 10, runSpacing: 6, children: [
            if (template.nightShift) _templateBadge('Night Shift', HRTheme.shift),
            if (template.halfDay) _templateBadge('Half Day', HRTheme.warning),
            if (template.hourBased) _templateBadge('Hour Based', HRTheme.info),
            if (template.fullRate != null) _templateBadge('Full Rate: ${template.fullRate}', HRTheme.success),
            if (template.halfRate != null) _templateBadge('Half Rate: ${template.halfRate}', HRTheme.success),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            OutlinedButton.icon(
              onPressed: () => _showTemplateSheet(template),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => _confirmDeleteTemplate(template),
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Delete'),
              style: OutlinedButton.styleFrom(foregroundColor: HRTheme.error),
            ),
          ]),
        ]),
      ),
    );
  }

  Future<void> _confirmDeleteTemplate(ShiftTemplate template) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete ${template.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await HRApiService.deleteShiftTemplate(template.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${template.name} deleted')));
      _fetchShiftTemplates();
    } catch (e) {
      debugPrint('Error deleting shift template: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to delete template')));
    }
  }

  Widget _templateBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusFull)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSwapRequestsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // There is no swap-request endpoint configured yet, so never show mock
    // records as if they were live employee data.
    const swaps = <ShiftSwapRequest>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        if (swaps.isEmpty)
          const HREmptyState(icon: Icons.swap_horiz_rounded, title: 'No Swap Requests', subtitle: 'Tap + to request a shift swap')
        else
          ...swaps.map((s) => HRCard(
            margin: const EdgeInsets.only(bottom: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Swap with ${s.requestTo}', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : HRTheme.textPrimary)),
                HRStatusBadge(
                  label: s.status,
                  color: s.status == 'Approved' ? HRTheme.success : s.status == 'Pending' ? HRTheme.pending : HRTheme.error,
                  bgColor: s.status == 'Approved' ? HRTheme.successLight : s.status == 'Pending' ? HRTheme.pendingLight : HRTheme.errorLight,
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _dateChip('My Date', s.myDate, HRTheme.info),
                const SizedBox(width: 8),
                const Icon(Icons.swap_horiz_rounded, size: 18, color: HRTheme.textSecondary),
                const SizedBox(width: 8),
                _dateChip('Their Date', s.theirDate, HRTheme.warning),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: HRTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(child: Text(s.reason, style: GoogleFonts.poppins(fontSize: 12, color: HRTheme.textSecondary))),
              ]),
              const SizedBox(height: 4),
              Text('Requested on ${s.requestedOn}', style: GoogleFonts.poppins(fontSize: 11, color: HRTheme.textHint)),
            ]),
          )),
      ],
    );
  }

  Widget _dateChip(String label, String date, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(HRTheme.radiusSM)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 9, color: color)),
      Text(date, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]),
  );

  void _showSwapRequestSheet() {
    final toCtrl = TextEditingController();
    final myDateCtrl = TextEditingController();
    final theirDateCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXL))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('New Shift Swap Request', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _formField('Request To (Colleague)', toCtrl, Icons.person_outlined),
            const SizedBox(height: 10),
            _formField('My Shift Date', myDateCtrl, Icons.calendar_today_outlined),
            const SizedBox(height: 10),
            _formField('Their Shift Date', theirDateCtrl, Icons.event_outlined),
            const SizedBox(height: 10),
            _formField('Reason', reasonCtrl, Icons.notes_rounded, maxLines: 2),
            const SizedBox(height: 16),
            HRPrimaryButton(label: 'Submit Request', icon: Icons.send_rounded, color: HRTheme.shift, onPressed: () => Navigator.pop(ctx)),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _formField(String hint, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(fontSize: 13, color: HRTheme.textHint),
        prefixIcon: Icon(icon, size: 18, color: HRTheme.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(HRTheme.radiusSM), borderSide: BorderSide(color: Colors.grey.shade300)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Future<void> _showTemplateSheet([ShiftTemplate? template]) async {
    final nameCtrl = TextEditingController(text: template?.name ?? '');
    final codeCtrl = TextEditingController(text: template?.code ?? '');
    final inTimeCtrl = TextEditingController(text: template?.inTime ?? '');
    final outTimeCtrl = TextEditingController(text: template?.outTime ?? '');
    final totalHoursCtrl = TextEditingController(text: template?.totalHours ?? '');
    final fullRateCtrl = TextEditingController(text: template?.fullRate?.toString() ?? '');
    final halfRateCtrl = TextEditingController(text: template?.halfRate?.toString() ?? '');
    bool nightShift = template?.nightShift ?? false;
    bool halfDay = template?.halfDay ?? false;
    bool hourBased = template?.hourBased ?? false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(HRTheme.radiusXL))),
      builder: (ctx) {
        bool isSaving = false;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (ctx, setModalState) {
                return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text(template == null ? 'New Shift Template' : 'Edit Shift Template', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _formField('Template Name', nameCtrl, Icons.drive_file_rename_outline),
                  const SizedBox(height: 10),
                  _formField('Template Code', codeCtrl, Icons.code_rounded),
                  const SizedBox(height: 10),
                  _formField('In Time', inTimeCtrl, Icons.login_rounded),
                  const SizedBox(height: 10),
                  _formField('Out Time', outTimeCtrl, Icons.logout_rounded),
                  const SizedBox(height: 10),
                  _formField('Total Hours', totalHoursCtrl, Icons.timelapse_rounded),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: _formField('Full Rate', fullRateCtrl, Icons.attach_money_rounded)),
                    const SizedBox(width: 10),
                    Expanded(child: _formField('Half Rate', halfRateCtrl, Icons.money_off_rounded)),
                  ]),
                  const SizedBox(height: 12),
                  Wrap(spacing: 12, runSpacing: 8, children: [
                    FilterChip(
                      label: const Text('Night Shift'),
                      selected: nightShift,
                      onSelected: (selected) => setModalState(() => nightShift = selected),
                    ),
                    FilterChip(
                      label: const Text('Half Day'),
                      selected: halfDay,
                      onSelected: (selected) => setModalState(() => halfDay = selected),
                    ),
                    FilterChip(
                      label: const Text('Hour Based'),
                      selected: hourBased,
                      onSelected: (selected) => setModalState(() => hourBased = selected),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  HRPrimaryButton(
                    label: template == null ? 'Create Template' : 'Update Template',
                    icon: template == null ? Icons.add_rounded : Icons.save_rounded,
                    color: HRTheme.shift,
                    onPressed: isSaving
                        ? null
                        : () async {
                            final data = {
                              if (template != null) 'id': template.id,
                              'name': nameCtrl.text.trim(),
                              'code': codeCtrl.text.trim(),
                              'inTime': inTimeCtrl.text.trim(),
                              'outTime': outTimeCtrl.text.trim(),
                              'totalWorkingHours': totalHoursCtrl.text.trim(),
                              'nightShift': nightShift,
                              'halfDayApplicable': halfDay,
                              'hourBased': hourBased,
                              if (fullRateCtrl.text.trim().isNotEmpty) 'fullRate': double.tryParse(fullRateCtrl.text.trim()) ?? 0.0,
                              if (halfRateCtrl.text.trim().isNotEmpty) 'halfRate': double.tryParse(halfRateCtrl.text.trim()) ?? 0.0,
                            };

                            try {
                              setModalState(() => isSaving = true);
                              if (template == null) {
                                await HRApiService.createShiftTemplate(data);
                              } else {
                                await HRApiService.updateShiftTemplate(data);
                              }
                              if (!mounted) return;
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(template == null ? 'Template created' : 'Template updated')));
                              _fetchShiftTemplates();
                            } catch (e) {
                              debugPrint('Error saving shift template: $e');
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to save template')));
                            } finally {
                              setModalState(() => isSaving = false);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                ]);
              },
            ),
          ),
        );
      },
    );
  }
}
