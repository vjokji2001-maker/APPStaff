import 'dart:convert';
import 'package:http/http.dart' as http;
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
  List<dynamic> _years = [];
  DateTime _calendarDate = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _publicHolidays = [];
  String _aiInsightText = "Loading AI insights...";
  bool _isLoadingInsight = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _fetchBalances();
    _fetchApplications();
    _fetchYears();
    _fetchPublicHolidays(DateTime.now().year);
  }

  Future<void> _fetchPublicHolidays(int year) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_OPENAI_API_KEY_HERE',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a JSON API. Return ONLY a valid JSON array. No markdown, no explanation.",
            },
            {
              "role": "user",
              "content":
                  "List 10 major public holidays in India for the year $year (including Diwali, Holi, Eid, Independence Day, etc. with accurate dates for $year). Format MUST be exactly: [{\"date\": \"YYYY-MM-DD\", \"name\": \"Holiday Name\"}]",
            },
          ],
          "temperature": 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content']
            .toString()
            .trim();

        // Ensure no markdown block
        String jsonStr = content;
        if (jsonStr.startsWith('```json')) {
          jsonStr = jsonStr
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        } else if (jsonStr.startsWith('```')) {
          jsonStr = jsonStr.replaceAll('```', '').trim();
        }

        if (mounted) {
          setState(() {
            _publicHolidays = jsonDecode(jsonStr);
          });
        }
      } else {
        debugPrint('GPT API Holiday Error: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching dynamic holidays via AI: $e');
    }
  }

  Future<void> _fetchYears() async {
    try {
      final yearsList = await HRApiService.getYearCycles();
      setState(() {
        _years = yearsList;
      });
    } catch (e) {
      print('Error fetching years: $e');
    }
  }

  int? _findCurrentYearCycleId(List<dynamic> cycles) {
    if (cycles.isEmpty) return null;
    for (final cycle in cycles) {
      if (cycle['status']?.toString().toUpperCase() == 'ACTIVE') {
        return int.tryParse(cycle['id']?.toString() ?? '');
      }
    }
    return int.tryParse(cycles.first['id']?.toString() ?? '');
  }

  Future<void> _fetchBalances() async {
    try {
      final dynamic res = await HRApiService.getLeaveBalances();
      List<dynamic> dataList = [];
      if (res is Map) {
        final dataMap = res['data'];
        if (dataMap is List) {
          dataList = dataMap;
        } else if (dataMap is Map) {
          dataList = dataMap['dataList'] ?? dataMap['content'] ?? [];
        } else {
          dataList = res['dataList'] ?? res['content'] ?? [];
        }
      } else if (res is List) {
        dataList = res;
      }
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
      List<dynamic> dataList = [];
      if (res is Map) {
        final dataMap = res['data'];
        if (dataMap is List) {
          dataList = dataMap;
        } else if (dataMap is Map) {
          dataList = dataMap['dataList'] ?? dataMap['content'] ?? [];
        } else {
          dataList = res['dataList'] ?? res['content'] ?? [];
        }
      } else if (res is List) {
        dataList = res;
      }
      setState(() {
        _applications = dataList
            .map((e) => LeaveApplication.fromJson(e))
            .toList();
        _isLoadingApplications = false;
      });
      // Fetch AI insight after applications are loaded
      _fetchAiInsight();
    } catch (e) {
      print('Error fetching applications: $e');
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
      body: Column(
        children: [
          HRGradientHeader(
            title: 'My Leave',
            subtitle: 'Manage your leave requests',
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: _showApplyLeave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Apply',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildBalanceTab(),
                _buildHistoryTab(),
                _buildCalendarTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApplyLeave,
        backgroundColor: HRTheme.leave,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Apply Leave',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceTab() {
    if (_isLoadingBalances) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HRCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HRSectionHeader(
                  title: 'Leave Balance Overview',
                  icon: Icons.beach_access_rounded,
                ),
                if (_balances.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: Text('No leave balances available')),
                  ),
                ..._balances.map((lb) {
                  Color color;
                  try {
                    color = Color(
                      int.parse(lb.colorHex.replaceFirst('#', '0xFF')),
                    );
                  } catch (e) {
                    color = HRTheme.leave;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lb.leaveType,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${lb.available}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: color,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / ${lb.total}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: HRTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        HRProgressBar(
                          value: lb.total > 0 ? lb.available / lb.total : 0,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Used: ${lb.used}  Pending: ${lb.pending}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: HRTheme.textSecondary,
                              ),
                            ),
                            Text(
                              'Available: ${lb.available}',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ],
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

  Widget _buildHistoryTab() {
    if (_isLoadingApplications) {
      return const Center(child: CircularProgressIndicator());
    }
    String _filter = 'All';
    return StatefulBuilder(
      builder: (_, ss) {
        final filtered = _filter == 'All'
            ? _applications
            : _applications.where((a) => a.status == _filter).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'Pending', 'Approved', 'Rejected']
                      .map(
                        (f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => ss(() => _filter = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _filter == f
                                    ? HRTheme.leave
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  HRTheme.radiusFull,
                                ),
                                border: Border.all(
                                  color: _filter == f
                                      ? HRTheme.leave
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                f,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: _filter == f
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _filter == f
                                      ? Colors.white
                                      : HRTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const HREmptyState(
                      icon: Icons.event_busy,
                      title: 'No Applications',
                      subtitle: 'No leave applications found',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => _LeaveCard(
                        app: filtered[i],
                        onTap: () => _showLeaveDetails(filtered[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          HRCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          _calendarDate = DateTime(
                            _calendarDate.year,
                            _calendarDate.month - 1,
                            1,
                          );
                          if (_calendarDate.year != DateTime.now().year) {
                            _fetchPublicHolidays(_calendarDate.year);
                          }
                        });
                        _fetchAiInsight();
                      },
                    ),
                    InkWell(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _calendarDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _calendarDate = picked;
                            _fetchPublicHolidays(picked.year);
                          });
                          _fetchAiInsight();
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: HRTheme.primaryDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"][_calendarDate.month - 1]} ${_calendarDate.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: HRTheme.textPrimary,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: HRTheme.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          _calendarDate = DateTime(
                            _calendarDate.year,
                            _calendarDate.month + 1,
                            1,
                          );
                          if (_calendarDate.year != DateTime.now().year) {
                            _fetchPublicHolidays(_calendarDate.year);
                          }
                        });
                        _fetchAiInsight();
                      },
                    ),
                  ],
                ),
                _buildMiniCalendar(_calendarDate),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // AI Smart Insights
          const HRSectionHeader(
            title: 'AI Smart Insights',
            icon: Icons.auto_awesome,
          ),
          HRCard(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: Colors.amber,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _isLoadingInsight
                        ? SizedBox(
                            height: 20,
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _aiInsightText,
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color.fromARGB(255, 11, 24, 29),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Align(
    alignment: Alignment.centerLeft,
    child: Text(
      _aiInsightText,
      maxLines: 2,
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.poppins(
        fontSize: 13,
        color: HRTheme.textPrimary,
      ),
    ),
  ),
                  ),
                ],
              ),
            ),
          ),

          if (_selectedDay != null) ...[
            HRSectionHeader(
              title:
                  'Events on ${["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][_selectedDay!.weekday - 1]}, ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              icon: Icons.event_note_rounded,
            ),
            ..._buildSelectedDayEvents(),
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Tap a date on the calendar to view events.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _fetchAiInsight() async {
    if (_isLoadingInsight) return;
    if (!mounted) return;

    setState(() {
      _isLoadingInsight = true;
      _aiInsightText = "Analyzing your schedule with AI...";
    });

    int approvedThisMonth = _applications.where((a) {
      if (a.status != 'Approved') return false;
      try {
        final d = DateTime.parse(a.fromDate.split(' ')[0]);
        return d.year == _calendarDate.year && d.month == _calendarDate.month;
      } catch (_) {
        return false;
      }
    }).length;

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_OPENAI_API_KEY_HERE',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content":
                  "You are a helpful and positive HR assistant. Keep responses under 2 short sentences. Be encouraging and friendly.",
            },
            {
              "role": "user",
              "content":
                  "The user has taken $approvedThisMonth approved leaves in the month of ${_calendarDate.month}/${_calendarDate.year}. Give a short, encouraging message about their work-life balance.",
            },
          ],
          "max_tokens": 60,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _aiInsightText = data['choices'][0]['message']['content']
                .toString()
                .trim();
            _isLoadingInsight = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _aiInsightText = "Failed to load AI insight from server.";
            _isLoadingInsight = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiInsightText = "Could not connect to AI service.";
          _isLoadingInsight = false;
        });
      }
    }
  }

  List<Widget> _buildSelectedDayEvents() {
    List<Widget> eventWidgets = [];

    // Check for Public Holidays
    if (_selectedDay != null) {
      final String searchDate =
          "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
      final holidaysOnDay = _publicHolidays
          .where((h) => h['date'] == searchDate)
          .toList();

      for (var holiday in holidaysOnDay) {
        eventWidgets.add(
          HRCard(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                  ),
                  child: const Center(
                    child: Icon(Icons.celebration, color: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holiday['name'] ?? holiday['localName'] ?? 'Holiday',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Public Holiday',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final dayLeaves = _applications.where((a) {
      try {
        final d = DateTime.parse(a.fromDate.split(' ')[0]);
        return d.year == _selectedDay!.year &&
            d.month == _selectedDay!.month &&
            d.day == _selectedDay!.day;
      } catch (_) {
        return false;
      }
    }).toList();

    for (var a in dayLeaves) {
      eventWidgets.add(
        HRCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _getStatusColor(a.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: Center(
                  child: Icon(Icons.event, color: _getStatusColor(a.status)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.leaveType,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Status: ${a.status}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: _getStatusColor(a.status),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (eventWidgets.isEmpty) {
      eventWidgets.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            'No leaves or events scheduled for this date.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return eventWidgets;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return HRTheme.leave;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return HRTheme.textPrimary;
    }
  }

  Widget _buildMiniCalendar(DateTime now) {
    final firstDay = DateTime(now.year, now.month, 1);
    final startWeekday = firstDay.weekday;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final leaveSet = _applications
        .where((a) {
          if (a.status != 'Approved') return false;
          try {
            final dateStr = a.fromDate.split(' ')[0];
            final d = DateTime.parse(dateStr);
            return d.year == now.year && d.month == now.month;
          } catch (_) {
            return false;
          }
        })
        .map((a) {
          try {
            final dateStr = a.fromDate.split(' ')[0];
            return DateTime.parse(dateStr).day.toString();
          } catch (_) {
            return '';
          }
        })
        .toSet();

    final bool isCurrentMonth =
        now.year == DateTime.now().year && now.month == DateTime.now().month;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
              .map(
                (d) => SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: HRTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: startWeekday - 1 + daysInMonth,
          itemBuilder: (_, i) {
            if (i < startWeekday - 1) return const SizedBox();
            final day = i - startWeekday + 2;
            final isToday = isCurrentMonth && day == DateTime.now().day;
            final isLeave = leaveSet.contains('$day');

            final String searchDate =
                "${now.year}-${now.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
            final isHoliday = _publicHolidays.any(
              (h) => h['date'] == searchDate,
            );

            final isSelected =
                _selectedDay != null &&
                _selectedDay!.year == now.year &&
                _selectedDay!.month == now.month &&
                _selectedDay!.day == day;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = DateTime(now.year, now.month, day);
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? HRTheme.primaryDark
                      : isToday
                      ? HRTheme.primaryDark.withValues(alpha: 0.5)
                      : isLeave
                      ? HRTheme.leave.withValues(alpha: 0.15)
                      : isHoliday
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: HRTheme.primaryDark, width: 2)
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: (isToday || isSelected)
                          ? FontWeight.w800
                          : FontWeight.w400,
                      color: (isToday || isSelected)
                          ? Colors.white
                          : isLeave
                          ? HRTheme.leave
                          : isHoliday
                          ? Colors.green
                          : HRTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLeaveDetails(LeaveApplication app) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final res = await HRApiService.getLeaveRequestById(app.id);
      if (!mounted) return;
      Navigator.pop(context); // pop loading

      final data = res is Map ? (res['data'] ?? res) : {};
      _showDetailsDialog(data, app);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // pop loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching details: $e')));
    }
  }

  void _showDetailsDialog(Map<String, dynamic> data, LeaveApplication app) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPending = app.status.toLowerCase() == 'pending';
    final isCancelled =
        app.status.toLowerCase() == 'cancelled' ||
        app.status.toLowerCase() == 'rejected';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? HRTheme.bgCardDark : Colors.white,
        title: Text(
          'Leave Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leave Type: ${app.leaveType}'),
            Text('Status: ${app.status}'),
            Text(
              'Duration: ${app.fromDate} to ${app.toDate} (${app.days} Days)',
            ),
            Text('Reason: ${app.reason}'),
            if (data['remarks'] != null) Text('Remarks: ${data['remarks']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          if (isPending)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                Navigator.pop(ctx);
                await _cancelLeaveRequest(app.id);
              },
              child: const Text(
                'Cancel Request',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (isCancelled)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(ctx);
                await _deleteLeaveRequest(app.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _cancelLeaveRequest(String id) async {
    try {
      final empId = await HRApiService.getLoggedEmpId();
      await HRApiService.cancelLeaveRequest({
        "requestId": id,
        "employeeId": empId,
        "reason": "Cancelled by user",
      });
      _fetchData();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Leave request cancelled')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteLeaveRequest(String id) async {
    try {
      await HRApiService.deleteLeaveRequest(id);
      _fetchData();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Leave request deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showApplyLeave() {
    // Initial State values
    int? selectedYearId = _findCurrentYearCycleId(_years);
    DateTime? appDate = DateTime.now();
    LeaveBalance? selectedBalance;
    DateTime? from = DateTime.now();
    DateTime? to = DateTime.now();
    String fromDuration = 'FULL_DAY';
    String toDuration = 'FULL_DAY';
    final reasonCtrl = TextEditingController();

    List<LeaveBalance> dialogBalances = [];
    bool isLoadingBalances = true;

    Future<void> fetchDialogBalances(StateSetter ss, int? yearId) async {
      ss(() => isLoadingBalances = true);
      try {
        final res = await HRApiService.getLeaveBalances(yearId: yearId);
        List<dynamic> dataList = [];
        if (res is Map) {
          final dataMap = res['data'];
          if (dataMap is List) {
            dataList = dataMap;
          } else if (dataMap is Map) {
            dataList = dataMap['dataList'] ?? dataMap['content'] ?? [];
          } else {
            dataList = res['dataList'] ?? res['content'] ?? [];
          }
        } else if (res is List) {
          dataList = res;
        }
        if (!mounted) return;
        ss(() {
          dialogBalances = dataList
              .map((e) => LeaveBalance.fromJson(e))
              .toList();
          if (selectedBalance != null &&
              !dialogBalances.any(
                (b) => b.leaveNameId == selectedBalance?.leaveNameId,
              )) {
            selectedBalance = null;
          }
          isLoadingBalances = false;
        });
      } catch (e) {
        if (!mounted) return;
        ss(() {
          dialogBalances = [];
          selectedBalance = null;
          isLoadingBalances = false;
        });
      }
    }

    bool _init = false;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) {
          if (!_init) {
            _init = true;
            fetchDialogBalances(ss, selectedYearId);
          }
          final isDark = Theme.of(context).brightness == Brightness.dark;

          // Auto calculate total days
          double totalDays = 0.0;
          if (from != null && to != null) {
            if (!to!.isBefore(from!)) {
              int calendarDays = to!.difference(from!).inDays + 1;
              totalDays = calendarDays.toDouble();

              if (fromDuration != 'FULL_DAY') {
                totalDays -= 0.5;
              }
              if (toDuration != 'FULL_DAY') {
                if (calendarDays > 1) {
                  totalDays -= 0.5;
                } else {
                  totalDays = 0.5;
                }
              }
            }
          }

          return Dialog(
            backgroundColor: isDark ? HRTheme.bgCardDark : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HRTheme.radiusLG),
            ),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Leave Request',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : HRTheme.textPrimary,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),

                      // 1. Year Dropdown
                      DropdownButtonFormField<int>(
                        value: selectedYearId,
                        hint: Text(
                          'Select Year',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: HRTheme.textSecondary,
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Year *',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        dropdownColor: isDark
                            ? HRTheme.bgCardDark
                            : Colors.white,
                        items: _years
                            .map(
                              (y) => DropdownMenuItem<int>(
                                value: int.tryParse(y['id']?.toString() ?? ''),
                                child: Text(
                                  y['name']?.toString() ?? 'Financial Yr',
                                  style: GoogleFonts.poppins(fontSize: 13),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          ss(() => selectedYearId = v);
                          fetchDialogBalances(ss, v);
                        },
                      ),
                      const SizedBox(height: 14),

                      // 2. Leave Name Dropdown
                      isLoadingBalances
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            )
                          : DropdownButtonFormField<LeaveBalance>(
                              value: selectedBalance,
                              hint: Text(
                                'Select Leave Name',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: HRTheme.textSecondary,
                                ),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Leave Name *',
                                labelStyle: GoogleFonts.poppins(fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    HRTheme.radiusSM,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              dropdownColor: isDark
                                  ? HRTheme.bgCardDark
                                  : Colors.white,
                              items: dialogBalances
                                  .map(
                                    (b) => DropdownMenuItem<LeaveBalance>(
                                      value: b,
                                      child: Text(
                                        b.leaveType,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => ss(() => selectedBalance = v),
                            ),
                      const SizedBox(height: 14),

                      // 3. Application Date
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: appDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (d != null) ss(() => appDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: HRTheme.leave,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  appDate == null
                                      ? 'Application Date *'
                                      : 'Application Date: ${appDate!.day}-${appDate!.month.toString().padLeft(2, '0')}-${appDate!.year}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: appDate == null
                                        ? HRTheme.textHint
                                        : (isDark
                                              ? Colors.white
                                              : HRTheme.textPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. From Date
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: from ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 30),
                            ),
                            lastDate: DateTime(2027),
                          );
                          if (d != null) {
                            ss(() {
                              from = d;
                              if (to == null || to!.isBefore(d)) {
                                to = d;
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: HRTheme.leave,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  from == null
                                      ? 'From Date *'
                                      : 'From Date: ${from!.day}/${from!.month}/${from!.year}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: from == null
                                        ? HRTheme.textHint
                                        : (isDark
                                              ? Colors.white
                                              : HRTheme.textPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 5. Duration (From Date)
                      DropdownButtonFormField<String>(
                        value: fromDuration,
                        decoration: InputDecoration(
                          labelText: 'Duration (From Date)',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        dropdownColor: isDark
                            ? HRTheme.bgCardDark
                            : Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: 'FULL_DAY',
                            child: Text(
                              'Full Day',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'FIRST_HALF',
                            child: Text(
                              'First Half',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'SECOND_HALF',
                            child: Text(
                              'Second Half',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            ss(() => fromDuration = v ?? 'FULL_DAY'),
                      ),
                      const SizedBox(height: 14),

                      // 6. To Date
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: to ?? from ?? DateTime.now(),
                            firstDate: from ?? DateTime.now(),
                            lastDate: DateTime(2027),
                          );
                          if (d != null) ss(() => to = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: HRTheme.leave,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  to == null
                                      ? 'To Date *'
                                      : 'To Date: ${to!.day}/${to!.month}/${to!.year}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: to == null
                                        ? HRTheme.textHint
                                        : (isDark
                                              ? Colors.white
                                              : HRTheme.textPrimary),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 7. Duration (To Date)
                      DropdownButtonFormField<String>(
                        value: toDuration,
                        decoration: InputDecoration(
                          labelText: 'Duration (To Date)',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        dropdownColor: isDark
                            ? HRTheme.bgCardDark
                            : Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: 'FULL_DAY',
                            child: Text(
                              'Full Day',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'FIRST_HALF',
                            child: Text(
                              'First Half',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'SECOND_HALF',
                            child: Text(
                              'Second Half',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            ss(() => toDuration = v ?? 'FULL_DAY'),
                      ),
                      const SizedBox(height: 14),

                      // 5. Total Days (Read Only Text Field)
                      TextFormField(
                        initialValue: totalDays.toString(),
                        key: ValueKey(
                          'totalDays_$totalDays',
                        ), // Forces rebuild when value changes
                        enabled: false,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Total Days',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          fillColor: isDark
                              ? Colors.black12
                              : Colors.grey.shade100,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                                      // 6. Reason *
                      TextFormField(
                        controller: reasonCtrl,
                        maxLines: 3,
                        style: GoogleFonts.poppins(fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Reason *',
                          labelStyle: GoogleFonts.poppins(fontSize: 13),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              HRTheme.radiusSM,
                            ),
                          ),
                          hintText: 'Enter reason for leave...',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cancel & Apply for Leave Buttons
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 2),
                        child: Row(
                          children: [
                            // CANCEL BUTTON
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 48,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                  },
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // APPLY FOR LEAVE BUTTON
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // TODO: hook up real submit logic
                                    // (validate selectedBalance/from/to/reason,
                                    // call HRApiService.applyLeave(...), then
                                    // Navigator.pop(ctx) and _fetchData()).
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E8B36),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Apply for Leave',
                                      maxLines: 1,
                                      softWrap: false,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ], // close Column children
                  ), // close Column
                ), // close Padding (dialog content)
              ), // close SingleChildScrollView
            ), // close Container
          ); // close Dialog (return statement)
        }, // close StatefulBuilder builder callback
      ), // close StatefulBuilder
    ); // close showDialog
  } // close _showApplyLeave()
} // close _HRLeaveScreenState
             
    

class _LeaveCard extends StatelessWidget {
  final LeaveApplication app;
  final VoidCallback onTap;
  const _LeaveCard({required this.app, required this.onTap});

  HRStatus get _status {
    switch (app.status) {
      case 'Approved':
        return HRStatus.approved;
      case 'Rejected':
        return HRStatus.rejected;
      default:
        return HRStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HRCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    app.leaveType,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                HRStatusBadge.fromStatus(_status),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.date_range_rounded,
                  size: 14,
                  color: HRTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  '${app.fromDate} – ${app.toDate}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: HRTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: HRTheme.infoLight,
                    borderRadius: BorderRadius.circular(HRTheme.radiusFull),
                  ),
                  child: Text(
                    '${app.days} Day${app.days > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: HRTheme.info,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Reason: ${app.reason}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: HRTheme.textSecondary,
              ),
            ),
            if (app.remarks != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _status == HRStatus.approved
                      ? HRTheme.successLight
                      : _status == HRStatus.rejected
                      ? HRTheme.errorLight
                      : HRTheme.pendingLight,
                  borderRadius: BorderRadius.circular(HRTheme.radiusSM),
                ),
                child: Text(
                  'Remarks: ${app.remarks}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: HRTheme.textPrimary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Applied: ${app.appliedOn}',
              style: GoogleFonts.poppins(fontSize: 10, color: HRTheme.textHint),
            ),
          ],
        ),
      ),
    );
  }
}


