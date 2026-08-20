import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/hr_theme.dart';
import '../data/hr_api_service.dart';
import '../models/hr_models.dart';
import '../widgets/hr_widgets.dart';
import '../../models/global_user_data.dart';

class HRShiftScreen extends StatefulWidget {
  const HRShiftScreen({super.key});

  @override
  State<HRShiftScreen> createState() => _HRShiftScreenState();
}

class _HRShiftScreenState extends State<HRShiftScreen> {
  bool _isLoading = true;
  String? _error;
  List<ShiftSchedule> _weekSchedule = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  String? _currentUserEmployeeCode;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _fetchRosterData();
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
    _fetchRosterData();
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
    _fetchRosterData();
  }

  String _formatWeekRangeLabel() {
    final start = _currentWeekStart;
    final end = _currentWeekStart.add(const Duration(days: 6));
    final startDay = start.day.toString();
    final startMonth = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][start.month - 1];
    final endDay = end.day.toString();
    final endMonth = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][end.month - 1];
    return '$startDay $startMonth - $endDay $endMonth';
  }

  Future<void> _fetchRosterData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userData = GlobalUserData().userData;
      if (userData != null) {
        _currentUserEmployeeCode = userData['userId']?.toString() ?? userData['empId']?.toString() ?? 'EMP001';
        print('SHIFT ROSTER - Resolved profile employeeCode: $_currentUserEmployeeCode (Code: $_currentUserEmployeeCode)');
      }
    } catch (e) {
      debugPrint('Failed to resolve employee code: $e');
    }

    try {
      final now = DateTime.now();
      final monday = _currentWeekStart;
      final sunday = _currentWeekStart.add(const Duration(days: 6));

      print('SHIFT ROSTER - Requesting dates: ${_formatDate(monday)} to ${_formatDate(sunday)}');
      final response = await HRApiService.getShiftRoster(
        fromDate: _formatDate(monday),
        toDate: _formatDate(sunday),
        pageSize: 100,
      );

      print('SHIFT ROSTER - Raw API Response: $response');

      final data = _asMap(response is Map ? response['data'] ?? response : null);
      final columns = _asList(data['columns'] ?? data['columnList']);
      final dataList = _asList(data['dataList'] ?? data['content'] ?? data['records']);

      print('SHIFT ROSTER - dataList length: ${dataList.length}');

      // Flatten dataList in case it contains nested lists (e.g. [[row1, row2]])
      final List<dynamic> flatList = [];
      for (final item in dataList) {
        if (item is List) {
          flatList.addAll(item);
        } else {
          flatList.add(item);
        }
      }

      print('SHIFT ROSTER - flatList length: ${flatList.length}');
      if (flatList.isNotEmpty) {
        print('SHIFT ROSTER - first flatList row: ${flatList.first}');
      }

      if (columns.isEmpty || flatList.isEmpty) {
        print('SHIFT ROSTER - columns or flatList is empty! Building empty week schedule...');
        _buildEmptyWeekSchedule();
        setState(() {
          if (now.isAfter(monday.subtract(const Duration(days: 1))) && 
              now.isBefore(sunday.add(const Duration(days: 1)))) {
            _selectedDate = now;
          } else {
            _selectedDate = monday;
          }
          _isLoading = false;
        });
        return;
      }

      // Safe lookup for row matching logged-in user code
      final dynamic foundRow = flatList.firstWhere(
        (r) {
          if (r is! Map) return false;
          final code = r['employeeCode']?.toString().toLowerCase() ?? '';
          return code.isNotEmpty && code == _currentUserEmployeeCode?.toLowerCase();
        },
        orElse: () => flatList.first,
      );

      final rowMap = foundRow is Map ? Map<String, dynamic>.from(foundRow) : <String, dynamic>{};
      final List<dynamic> empShiftList = _asList(rowMap['empShiftList']);
      
      final schedule = <ShiftSchedule>[];
      final weekDates = List.generate(7, (i) => monday.add(Duration(days: i)));

      for (final date in weekDates) {
        final dateStr = _formatDate(date);
        final dateKeyStr = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
        
        // Find matching shift in employee shift list
        final dynamic matchedShift = empShiftList.firstWhere(
          (s) {
            if (s is! Map) return false;
            final sDate = s['date']?.toString() ?? '';
            return sDate == dateKeyStr;
          },
          orElse: () => null,
        );

        final details = _asMap(matchedShift);
        final shiftName = details['shiftName']?.toString() ??
            details['name']?.toString() ??
            details['shiftCode']?.toString() ??
            matchedShift?.toString() ??
            '';

        schedule.add(ShiftSchedule(
          date: dateStr,
          day: _weekdayShort(date.weekday),
          shiftName: shiftName,
          startTime: details['inTime']?.toString() ?? details['startTime']?.toString() ?? '',
          endTime: details['outTime']?.toString() ?? details['endTime']?.toString() ?? '',
          ward: details['ward']?.toString() ?? details['location']?.toString() ?? '',
          type: details['type']?.toString() ?? 'Regular',
          isToday: date.year == now.year && date.month == now.month && date.day == now.day,
        ));
      }

      setState(() {
        _weekSchedule = schedule;
        if (now.isAfter(monday.subtract(const Duration(days: 1))) && 
            now.isBefore(sunday.add(const Duration(days: 1)))) {
          _selectedDate = now;
        } else {
          _selectedDate = monday;
        }
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('Error loading roster: $e');
      _buildEmptyWeekSchedule();
      setState(() {
        final now = DateTime.now();
        final monday = _currentWeekStart;
        final sunday = _currentWeekStart.add(const Duration(days: 6));
        if (now.isAfter(monday.subtract(const Duration(days: 1))) && 
            now.isBefore(sunday.add(const Duration(days: 1)))) {
          _selectedDate = now;
        } else {
          _selectedDate = monday;
        }
        _isLoading = false;
      });
    }
  }

  void _buildEmptyWeekSchedule() {
    final monday = _currentWeekStart;
    final now = DateTime.now();
    final schedule = <ShiftSchedule>[];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      schedule.add(ShiftSchedule(
        date: _formatDate(date),
        day: _weekdayShort(date.weekday),
        shiftName: '',
        startTime: '',
        endTime: '',
        ward: '',
        type: 'Regular',
        isToday: date.year == now.year && date.month == now.month && date.day == now.day,
      ));
    }
    _weekSchedule = schedule;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _asMap(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) => value is List ? value : const [];

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

  String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (weekday < 1 || weekday > 7) return '';
    return names[weekday - 1];
  }

  String _calculateScheduledHours() {
    int activeDays = _weekSchedule.where((s) => s.shiftName.isNotEmpty && s.shiftName.toLowerCase() != 'off' && s.shiftName.toLowerCase() != 'weekly off').length;
    return '${activeDays * 8} hrs';
  }

  String _calculateOffDays() {
    int offDays = _weekSchedule.where((s) => s.shiftName.isEmpty || s.shiftName.toLowerCase() == 'off' || s.shiftName.toLowerCase() == 'weekly off').length;
    return '$offDays Days';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final selectedSchedule = (_weekSchedule.isNotEmpty)
        ? _weekSchedule.firstWhere(
            (s) {
              final parsed = DateTime.tryParse(s.date);
              return parsed != null &&
                  parsed.year == _selectedDate.year &&
                  parsed.month == _selectedDate.month &&
                  parsed.day == _selectedDate.day;
            },
            orElse: () => _weekSchedule.first,
          )
        : ShiftSchedule(
            date: _formatDate(_selectedDate),
            day: _weekdayShort(_selectedDate.weekday),
            shiftName: '',
            startTime: '',
            endTime: '',
            ward: '',
            type: 'Regular',
            isToday: true,
          );

    final isOff = selectedSchedule.shiftName.toLowerCase() == 'off' ||
        selectedSchedule.shiftName.toLowerCase() == 'weekly off' ||
        selectedSchedule.shiftName.isEmpty;

    return Scaffold(
      backgroundColor: isDark ? HRTheme.bgDark : const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HRGradientHeader(
            title: 'My Shift',
            subtitle: 'Schedule and requests',
          ),
          HRTabBar(
            tabs: const ['Roster', 'Swipe Requests', 'OD Requests'],
            selectedIndex: _tab,
            onTabChanged: (i) => setState(() => _tab = i),
            activeColor: HRTheme.shift,
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildRosterTab(isDark, selectedSchedule, isOff),
                _buildSwipeRequestsTab(isDark),
                _buildODRequestsTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterTab(bool isDark, ShiftSchedule selectedSchedule, bool isOff) {
    return _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ScrollConfiguration(
            behavior: WebScrollBehavior(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                          Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: HRTheme.shift, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Shift Roster",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : HRTheme.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.chevron_left_rounded, color: HRTheme.shift, size: 24),
                                onPressed: _previousWeek,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatWeekRangeLabel(),
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white70 : HRTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.chevron_right_rounded, color: HRTheme.shift, size: 24),
                                onPressed: _nextWeek,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          
                          // Horizontal Day slider
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _weekSchedule.length,
                              itemBuilder: (context, index) {
                                final item = _weekSchedule[index];
                                final parsedDate = DateTime.tryParse(item.date) ?? DateTime.now();
                                final isSelected = parsedDate.year == _selectedDate.year &&
                                    parsedDate.month == _selectedDate.month &&
                                    parsedDate.day == _selectedDate.day;
                                    
                                final dayNum = parsedDate.day.toString();
                                final monthName = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][parsedDate.month - 1];
                                
                                final itemOff = item.shiftName.toLowerCase() == 'off' ||
                                    item.shiftName.toLowerCase() == 'weekly off' ||
                                    item.shiftName.isEmpty;
                                    
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = parsedDate;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 76,
                                    margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
                                    decoration: BoxDecoration(
                                      gradient: isSelected 
                                          ? const LinearGradient(
                                              colors: [Color(0xFF0F8F90), Color(0xFF0D9488)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected 
                                          ? null 
                                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: isSelected 
                                          ? [BoxShadow(color: const Color(0xFF0D9488).withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                                          : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                                      border: isSelected 
                                          ? null 
                                          : Border.all(
                                              color: isDark ? Colors.white12 : Colors.grey.shade200,
                                              width: 1.2,
                                            ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.day.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white70 : (isDark ? Colors.white54 : Colors.black45),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          dayNum,
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected ? Colors.white : (isDark ? Colors.white : HRTheme.textPrimary),
                                          ),
                                        ),
                                        Text(
                                          monthName.toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white60 : (isDark ? Colors.white30 : Colors.black38),
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: itemOff 
                                                ? (isSelected ? Colors.white54 : (isDark ? Colors.white12 : Colors.grey.shade300))
                                                : (isSelected ? Colors.amber : const Color(0xFF0D9488)),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Shift details card below
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: double.infinity,
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                )
                              ],
                              border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade100,
                                  width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top status badge row
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isOff 
                                            ? Colors.amber.withOpacity(0.12)
                                            : const Color(0xFF0D9488).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isOff ? Icons.wb_sunny_rounded : Icons.work_rounded,
                                            size: 12,
                                            color: isOff ? Colors.amber.shade800 : const Color(0xFF0D9488),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isOff ? 'OFF DAY' : selectedSchedule.type.toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              color: isOff ? Colors.amber.shade800 : const Color(0xFF0D9488),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    if (selectedSchedule.isToday)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0D9488),
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        child: Text(
                                          'TODAY',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                
                                // Main Shift Title Row with big icon
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Shift Name',
                                            style: GoogleFonts.poppins(
                                              color: isDark ? Colors.white30 : Colors.black38,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            isOff ? 'Weekly Off' : selectedSchedule.shiftName,
                                            style: GoogleFonts.poppins(
                                              color: isDark ? Colors.white : HRTheme.textPrimary,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: isOff 
                                            ? Colors.amber.withOpacity(0.12)
                                            : const Color(0xFF0D9488).withOpacity(0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isOff ? Icons.coffee_rounded : Icons.access_time_rounded,
                                        color: isOff ? Colors.amber.shade700 : const Color(0xFF0D9488),
                                        size: 26,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                const Divider(height: 24),
                                
                                // Shift Schedule Details Section
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDetailTile(
                                        isDark: isDark,
                                        icon: Icons.schedule_rounded,
                                        label: 'Duty Schedule',
                                        value: isOff ? 'No duty scheduled' : '${selectedSchedule.startTime} – ${selectedSchedule.endTime}',
                                      ),
                                    ),
                                    if (!isOff && selectedSchedule.ward.isNotEmpty) ...[
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildDetailTile(
                                          isDark: isDark,
                                          icon: Icons.local_hospital_outlined,
                                          label: 'Department / Ward',
                                          value: selectedSchedule.ward,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                
                                if (isOff) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withOpacity(0.02) : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.spa_rounded, color: Colors.green.shade400, size: 18),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            "Enjoy your day off! Rest, relax and recharge yourself.",
                                            style: GoogleFonts.poppins(
                                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          
                          // Weekly Summary Section Header
                          Row(
                            children: [
                              const Icon(Icons.analytics_outlined, color: HRTheme.shift, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Weekly Summary",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : HRTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          
                          // Summary Stats Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  isDark: isDark,
                                  icon: Icons.timer_outlined,
                                  label: 'Scheduled Hours',
                                  value: _calculateScheduledHours(),
                                  color: const Color(0xFF0D9488),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  isDark: isDark,
                                  icon: Icons.celebration_outlined,
                                  label: 'Off Days',
                                  value: _calculateOffDays(),
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Weekly Schedule List Header
                          Row(
                            children: [
                              const Icon(Icons.list_alt_outlined, color: HRTheme.shift, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Weekly Schedule List",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : HRTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          
                          // Vertical List of 7 days
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _weekSchedule.length,
                            itemBuilder: (context, index) {
                              final item = _weekSchedule[index];
                              final parsedDate = DateTime.tryParse(item.date) ?? DateTime.now();
                              final isSelected = parsedDate.year == _selectedDate.year &&
                                  parsedDate.month == _selectedDate.month &&
                                  parsedDate.day == _selectedDate.day;
                                  
                              final dayNum = parsedDate.day.toString();
                              
                              final itemOff = item.shiftName.toLowerCase() == 'off' ||
                                  item.shiftName.toLowerCase() == 'weekly off' ||
                                  item.shiftName.isEmpty;
                                  
                              final itemColor = itemOff ? Colors.grey : _shiftColor(item.shiftName);
                              
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedDate = parsedDate;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? HRTheme.shift.withOpacity(0.06)
                                        : (isDark ? const Color(0xFF1E293B) : Colors.white),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected 
                                          ? HRTheme.shift.withOpacity(0.5) 
                                          : (isDark ? Colors.white12 : Colors.grey.shade100),
                                      width: isSelected ? 1.5 : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.01),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 50,
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? HRTheme.shift.withOpacity(0.12)
                                                : itemColor.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                item.day.toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? HRTheme.shift : itemColor,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                dayNum,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected ? HRTheme.shift : (isDark ? Colors.white : HRTheme.textPrimary),
                                                  height: 1.0,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                itemOff ? 'Weekly Off' : item.shiftName,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: itemOff 
                                                      ? (isDark ? Colors.white60 : Colors.black54)
                                                      : (isDark ? Colors.white : HRTheme.textPrimary),
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time_rounded, 
                                                    size: 12, 
                                                    color: isDark ? Colors.white30 : Colors.black38,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    itemOff ? 'No duty scheduled' : '${item.startTime} – ${item.endTime}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11,
                                                      color: isDark ? Colors.white60 : HRTheme.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: itemOff 
                                                ? (isDark ? Colors.white10 : Colors.grey.shade100)
                                                : itemColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            itemOff ? 'OFF' : 'DUTY',
                                            style: GoogleFonts.poppins(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: itemOff 
                                                  ? (isDark ? Colors.white38 : Colors.grey.shade600)
                                                  : itemColor,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
  }

  Widget _buildSwipeRequestsTab(bool isDark) {
    return const Center(child: Text("Swipe Requests Coming Soon"));
  }

  Widget _buildODRequestsTab(bool isDark) {
    return const Center(child: Text("OD Requests Coming Soon"));
  }

  Widget _buildDetailTile({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? Colors.white30 : Colors.black38),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isDark ? Colors.white30 : Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : HRTheme.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isDark ? Colors.white30 : Colors.black38,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _shiftColor(String name) {
    switch (name.toLowerCase()) {
      case 'morning': return HRTheme.info;
      case 'afternoon': return HRTheme.warning;
      case 'night': return HRTheme.primaryDark;
      default: return HRTheme.textSecondary;
    }
  }


}

class WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
