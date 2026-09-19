import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/api/event_api_service.dart';
import 'package:staff_mate/pages/smartcarehomescreen.dart'; // For AppColors if needed, though they hardcoded colors
import 'package:flutter/services.dart';
class EventManagementPortalScreen extends StatefulWidget {
  const EventManagementPortalScreen({super.key});

  @override
  State<EventManagementPortalScreen> createState() =>
      _EventManagementPortalScreenState();
}

class _EventManagementPortalScreenState
    extends State<EventManagementPortalScreen> {
  String selectedFilter = 'all';
  String searchQuery = '';

  List<Map<String, dynamic>> _eventCategories = [];
  bool _loadingCategories = false;

  List<Map<String, dynamic>> events = [];
  bool _loadingEvents = false;

  List<Map<String, dynamic>> _eventTasks = [];
  bool _loadingEventTasks = false;
  int? _selectedEventId;

  @override
  void initState() {
    super.initState();
    _loadEventCategories();
    _loadAllEvents();
  }

  Future<void> _loadEventTasks(int eventId) async {
    if (!mounted) return;

    setState(() {
      _loadingEventTasks = true;
      _selectedEventId = eventId;
      _eventTasks = [];
    });

    try {
      // Assuming you might add this to EventApiService later, for now we mock it or if you have it:
      // final tasks = await EventApiService.getEventTasks(eventId.toString());
      // For now, let's just show an empty list or a mock since getEventTasks wasn't in EventApiService
      final tasks = <Map<String, dynamic>>[];

      if (!mounted) return;
      setState(() {
        _eventTasks = tasks;
      });
    } catch (e) {
      debugPrint('ERROR LOADING EVENT TASKS: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load event tasks: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingEventTasks = false;
      });
    }
  }

  Future<void> _loadAllEvents() async {
    if (!mounted) return;

    setState(() {
      _loadingEvents = true;
    });

    try {
      final response = await EventApiService.getAllEvents();

      if (response != null) {
        List? list;
        if (response is List) {
          list = response;
        } else if (response is Map && response['data'] != null) {
          if (response['data'] is List) {
            list = response['data'] as List;
          } else if (response['data'] is Map &&
              response['data']['list'] != null) {
            list = response['data']['list'] as List;
          }
        }

        if (list != null) {
          if (!mounted) return;

          setState(() {
            events = list!.map<Map<String, dynamic>>((rawItem) {
              final item = Map<String, dynamic>.from(rawItem as Map);
              return {
                'id': item['id']?.toString() ?? '',
                'name':
                    item['eventTitle'] ??
                    item['eventName'] ??
                    item['name'] ??
                    '',
                'tagline': item['subtitle'] ?? item['description'] ?? '',
                'type':
                    item['eventCategoryName'] ??
                    item['categoryName'] ??
                    item['type'] ??
                    'Other',
                'date': item['startDate'] ?? item['date'] ?? '',
                'time': '${item['startTime'] ?? ''} – ${item['endTime'] ?? ''}',
                'location': item['location'] ?? item['venue'] ?? '',
                'manager':
                    item['managerName'] ?? item['eventManagerName'] ?? '',
                'status': (item['status'] ?? 'upcoming')
                    .toString()
                    .toLowerCase(),
                'raw': item,
              };
            }).toList();
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR LOADING EVENTS: $e');
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingEvents = false;
      });
    }
  }

  Future<void> _loadEventCategories() async {
    setState(() {
      _loadingCategories = true;
    });

    try {
      final response = await EventApiService.getEventCategories();
      if (response != null) {
        List? list;
        if (response is List) {
          list = response;
        } else if (response is Map && response['data'] != null) {
          if (response['data'] is List) {
            list = response['data'] as List;
          } else if (response['data'] is Map &&
              response['data']['list'] != null) {
            list = response['data']['list'] as List;
          }
        }

        if (list != null) {
          if (!mounted) return;
          setState(() {
            _eventCategories = list!
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint('ERROR LOADING EVENT CATEGORIES: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _loadingCategories = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredEvents {
    return events.where((e) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!e['name'].toString().toLowerCase().contains(q) &&
            !e['location'].toString().toLowerCase().contains(q)) {
          return false;
        }
      }
      if (selectedFilter == 'today')
        return e['status'] == 'ongoing' || e['status'] == 'today';
      if (selectedFilter == 'upcoming') return e['status'] == 'upcoming';
      if (selectedFilter == 'completed') return e['status'] == 'completed';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = events.length;
    final live = events
        .where((e) => e['status'] == 'ongoing' || e['status'] == 'today')
        .length;
    final up = events.where((e) => e['status'] == 'upcoming').length;
    final comp = events.where((e) => e['status'] == 'completed').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                color: const Color(0xFF182875),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Title takes available space
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'STAFFMATE OPERATIONS',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFC7D2FE),
                                ),
                              ),
                              Text(
                                'Event Management',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Create button
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => CreateNewHospitalEventDialog(
                                categories: _eventCategories,
                                onEventCreated: _loadAllEvents,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: Color(0xFF182875),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coordinate health camps, clinical training, and emergency code blue drills.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Stat Cards Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildStatCard(
                        'TOTAL',
                        total,
                        'All events',
                        Icons.calendar_today,
                        const Color(0xFF182875),
                        'all',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        'TODAY / LIVE',
                        live,
                        'Active today',
                        Icons.circle,
                        const Color(0xFFD97706),
                        'today',
                        isLiveDot: true,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        'UPCOMING',
                        up,
                        'Next 15 days',
                        Icons.access_time,
                        const Color(0xFF0284C7),
                        'upcoming',
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        'COMPLETED',
                        comp,
                        'Past 15 days',
                        Icons.check_circle_outline,
                        const Color(0xFF059669),
                        'completed',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Search & Filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => searchQuery = v),
                        style: GoogleFonts.poppins(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: 'Search event name or location...',
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildPillTab('All ($total)', 'all'),
                            const SizedBox(width: 6),
                            _buildPillTab('Live ($live)', 'today'),
                            const SizedBox(width: 6),
                            _buildPillTab('Upcoming ($up)', 'upcoming'),
                            const SizedBox(width: 6),
                            _buildPillTab('Completed ($comp)', 'completed'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Event List
              if (_loadingEvents)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filteredEvents.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      'No events found',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final ev = filteredEvents[i];

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  ev['type'].toString().toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF182875),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: ev['status'] == 'completed'
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ev['status'].toString().toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: ev['status'] == 'completed'
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFF0369A1),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            ev['name'].toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            ev['tagline'].toString(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Color(0xFF182875),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${ev['date']} (${ev['time']})',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          if (ev['location'].toString().isNotEmpty)
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 13,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    ev['location'].toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          if (ev['manager'].toString().isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 13,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    ev['manager'].toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showEventDetailsPopup(ev);
                                },
                                icon: const Icon(Icons.info_outline, size: 16),
                                label: const Text('View Details'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              if (_selectedEventId != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Event Tasks',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_loadingEventTasks)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_eventTasks.isEmpty)
                          Text(
                            'No tasks found for this event.',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          )
                        else
                          Column(
                            children: _eventTasks.map((task) {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['taskDescription']?.toString() ?? '',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Assigned to: ${task['assignedPerson']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          (task['priority']?.toString() ?? '')
                                              .toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFFD97706),
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (task['status']?.toString() ??
                                                            '')
                                                        .toUpperCase() ==
                                                    'COMPLETED'
                                                ? const Color(0xFFDCFCE7)
                                                : const Color(0xFFE0F2FE),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            (task['status']?.toString() ?? '')
                                                .toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 8,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  (task['status']?.toString() ??
                                                              '')
                                                          .toUpperCase() ==
                                                      'COMPLETED'
                                                  ? const Color(0xFF15803D)
                                                  : const Color(0xFF0369A1),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (task['dueDate'] != null) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        'Due: ${task['dueDate']}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    int count,
    String subtitle,
    IconData icon,
    Color color,
    String key, {
    bool isLiveDot = false,
  }) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: Container(
        width: 125,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF182875)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (isLiveDot)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD97706),
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  Icon(icon, size: 12, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF0F172A) : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(String label, String key) {
    final isSelected = selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF182875) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  void _showEventDetailsPopup(Map<String, dynamic> event) {
    final raw = event['raw'] as Map<String, dynamic>? ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF182875),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event_note, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Event Preview',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status & Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              raw['status']?.toString().toUpperCase() ??
                                  'UPCOMING',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0369A1),
                              ),
                            ),
                          ),
                          Text(
                            raw['eventCode'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Titles
                      Text(
                        raw['eventTitle'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (raw['subtitle'] != null &&
                          raw['subtitle'].toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          raw['subtitle'],
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      _buildDetailSection(
                        'Description',
                        raw['description'],
                        Icons.description,
                      ),
                      _buildDetailRow(
                        'Date & Time',
                        '${raw['startDate'] ?? ''} (${raw['startTime'] ?? ''} - ${raw['endTime'] ?? ''})',
                        Icons.schedule,
                      ),
                      _buildDetailRow(
                        'Location',
                        '${raw['location'] ?? ''}, ${raw['venue'] ?? ''}',
                        Icons.place,
                      ),
                      _buildDetailRow(
                        'Attendees & Budget',
                        'Attendees: ${raw['expectedAttendees'] ?? 'N/A'} | Budget: ₹${raw['budgetEstimate'] ?? 'N/A'}',
                        Icons.groups,
                      ),

                      const Divider(height: 32),

                      Text(
                        'Management',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Organizer',
                        '${raw['organizerName'] ?? 'N/A'} (${raw['organizerContact'] ?? '-'})',
                        Icons.business,
                      ),
                      _buildDetailRow(
                        'Manager',
                        '${raw['managerName'] ?? 'N/A'} - ${raw['managerDesignation'] ?? ''} (${raw['managerContact'] ?? '-'})',
                        Icons.person,
                      ),

                      const Divider(height: 32),

                      Text(
                        'Medical & Operations',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailSection(
                        'Clinical Directives',
                        raw['clinicalDirectives'],
                        Icons.medical_services,
                      ),
                      _buildDetailSection(
                        'Emergency Protocol',
                        raw['emergencyProtocol'],
                        Icons.warning,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    if (value.trim().isEmpty ||
        value.trim() == '()' ||
        value.trim() == ' -  ()')
      return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, dynamic value, IconData icon) {
    final text = value?.toString() ?? '';
    if (text.trim().isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateNewHospitalEventDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final VoidCallback onEventCreated;

  const CreateNewHospitalEventDialog({
    Key? key,
    required this.categories,
    required this.onEventCreated,
  }) : super(key: key);

  @override
  State<CreateNewHospitalEventDialog> createState() =>
      _CreateNewHospitalEventDialogState();
}

class _CreateNewHospitalEventDialogState
    extends State<CreateNewHospitalEventDialog> {
  Map<String, dynamic>? _selectedCategory;
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _locationController = TextEditingController();
  final _venueController = TextEditingController();
  final _expectedAttendeesController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _organizerContactController = TextEditingController();
  final _budgetController = TextEditingController();
  final _managerNameController = TextEditingController();
  final _managerDesignationController = TextEditingController();
  final _managerContactController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _clinicalDirectivesController = TextEditingController();
  final _emergencyProtocolController = TextEditingController();

  bool _isSaving = false;
  bool _categoriesLoading = false;
  List<Map<String, dynamic>> _loadedCategories = [];
  String? _errorMessage; // ← Error banner message

  @override
  void initState() {
    super.initState();
    // Default values
    _startDateController.text = "2026-08-25";
    _endDateController.text = "2026-08-25";
    _startTimeController.text = "10:00:00";
    _endTimeController.text = "16:00:00";

    // If parent passed categories, use them; else load fresh from API
    if (widget.categories.isNotEmpty) {
      _loadedCategories = widget.categories;
    } else {
      _fetchCategoriesInDialog();
    }
  }

  /// Load event categories directly inside the dialog
  Future<void> _fetchCategoriesInDialog() async {
    setState(() {
      _categoriesLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await EventApiService.getEventCategories();
      debugPrint('EVENT CATEGORIES RAW RESPONSE: $response');
      List<dynamic> list = [];

      if (response is List) {
        list = response;
      } else if (response is Map) {
        final data = response['data'];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = (data['list'] ?? data['content'] ?? data['records'] ?? []) as List;
        }
      }

      if (list.isEmpty && response != null) {
        debugPrint('EVENT CATEGORIES: Parsed empty list. Response: $response');
      }

      final mapped = list.map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        // Normalise field names — API may return different key names
        return {
          'eventCategoryId': m['eventCategoryId'] ?? m['id'] ?? m['categoryId'],
          'categoryName'   : m['categoryName'] ?? m['name'] ?? m['category'] ?? 'Unknown',
          ...m,
        };
      }).toList();

      setState(() {
        _loadedCategories = mapped;
        _categoriesLoading = false;
        if (mapped.isEmpty) {
          _errorMessage = 'No event categories found. Please add categories first.';
        }
      });
    } catch (e) {
      debugPrint('Error loading categories in dialog: $e');
      setState(() {
        _categoriesLoading = false;
        _errorMessage = 'Could not load event categories: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build deduplicated list from loaded categories
    final uniqueCategories = <String, Map<String, dynamic>>{};
    for (final category in _loadedCategories) {
      final name = category['categoryName']?.toString() ?? 'Other';
      uniqueCategories[name] = category;
    }
    final categoriesList = uniqueCategories.values.toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF182875),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_note, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Create New Event',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ── Error / Warning Banner (form ke upar) ───────
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  border: Border.all(color: const Color(0xFFFFCA2C), width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFB45309), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _errorMessage = null),
                      child: const Icon(Icons.close,
                          color: Color(0xFFB45309), size: 16),
                    ),
                  ],
                ),
              ),

            // ── Form Body ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      Icons.info_outline,
                      'Basic Information',
                    ),
                    _buildTextField(
                      _titleController,
                      'Event Title *',
                      Icons.title,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _subtitleController,
                      'Subtitle',
                      Icons.subtitles,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _descriptionController,
                      'Description',
                      Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // ── Event Category Dropdown ─────────────
                    _categoriesLoading
                        ? Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF182875),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Loading categories...',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: const Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          )
                        : DropdownButtonFormField<Map<String, dynamic>>(
                            decoration: InputDecoration(
                              labelText: 'Event Category *',
                              prefixIcon: const Icon(
                                Icons.category,
                                color: Color(0xFF182875),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              // Retry hint if empty
                              suffixIcon: categoriesList.isEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.refresh,
                                          color: Color(0xFF182875)),
                                      tooltip: 'Retry loading categories',
                                      onPressed: _fetchCategoriesInDialog,
                                    )
                                  : null,
                            ),
                            value: _selectedCategory,
                            hint: Text(
                              categoriesList.isEmpty
                                  ? 'No categories available — tap ↻ to retry'
                                  : 'Select a category',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF94A3B8)),
                            ),
                            items: categoriesList.map((category) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: category,
                                child: Text(
                                  category['categoryName']?.toString() ?? 'Other',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: categoriesList.isEmpty
                                ? null
                                : (value) => setState(
                                    () => _selectedCategory = value),
                          ),
                    const SizedBox(height: 32),

                    _buildSectionHeader(Icons.schedule, 'Timing'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _startDateController,
                            'Start Date *',
                            Icons.calendar_today,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _endDateController,
                            'End Date *',
                            Icons.event,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _startTimeController,
                            'Start Time *',
                            Icons.access_time,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _endTimeController,
                            'End Time *',
                            Icons.access_time_filled,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    _buildSectionHeader(
                      Icons.location_on,
                      'Location & Details',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            _locationController,
                            'Location',
                            Icons.place,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            _venueController,
                            'Venue',
                            Icons.business,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  LayoutBuilder(
  builder: (context, constraints) {
    final isMobile = constraints.maxWidth < 500;

    if (isMobile) {
      return Column(
        children: [
          _buildTextField(
            _expectedAttendeesController,
            'Expected Attendees',
            Icons.groups,
            isNumber: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            _budgetController,
            'Budget Estimate',
            Icons.attach_money,
            isNumber: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            _expectedAttendeesController,
            'Expected Attendees',
            Icons.groups,
            isNumber: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            _budgetController,
            'Budget Estimate',
            Icons.attach_money,
            isNumber: true,
          ),
        ),
      ],
    );
  },
),
                    const SizedBox(height: 32),

                    _buildSectionHeader(Icons.person, 'Management'),
                    _buildTextField(
                      _organizerNameController,
                      'Organizer Name',
                      Icons.account_circle,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _organizerContactController,
                      'Organizer Contact',
                      Icons.phone,
                      isNumber: true,
                      
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _managerNameController,
                      'Manager Name',
                      Icons.manage_accounts,
                    ),
                    const SizedBox(height: 16),
                   LayoutBuilder(
  builder: (context, constraints) {
    final isMobile = constraints.maxWidth < 500;

    if (isMobile) {
      return Column(
        children: [
          _buildTextField(
            _managerDesignationController,
            'Manager Designation',
            Icons.badge,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            _managerContactController,
            'Manager Contact',
            Icons.phone_android,
            isNumber: true,
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            _managerDesignationController,
            'Manager Designation',
            Icons.badge,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTextField(
            _managerContactController,
            'Manager Contact',
            Icons.phone_android,
            isNumber: true,
          ),
        ),
      ],
    );
  },
),
                    const SizedBox(height: 32),

                    _buildSectionHeader(
                      Icons.local_hospital,
                      'Medical & Safety',
                    ),
                    _buildTextField(
                      _clinicalDirectivesController,
                      'Clinical Directives',
                      Icons.medical_services,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      _emergencyProtocolController,
                      'Emergency Protocol',
                      Icons.warning,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF182875)),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF182875),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveEvent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF182875),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Create Event',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF182875), size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  int maxLines = 1,
  bool isNumber = false,
}) {
  return TextField(
    controller: controller,
    maxLines: maxLines,

    // Keyboard
    keyboardType: isNumber
        ? TextInputType.phone
        : TextInputType.text,

    // Restrict number fields to digits and maximum 10 digits
    inputFormatters: isNumber
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ]
        : null,

    style: GoogleFonts.poppins(
      fontSize: 13,
      color: const Color(0xFF0F172A),
    ),

    decoration: InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: const Color(0xFF64748B),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF94A3B8),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF182875),
          width: 1.5,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    ),
  );
}

  Future<void> _saveEvent() async {
    // ── Validation: show errors in banner at top of form ──
    if (_titleController.text.trim().isEmpty) {
      setState(() => _errorMessage = '⚠ Event Title is required.');
      return;
    }
    if (_selectedCategory == null) {
      setState(() => _errorMessage = '⚠ Please select an Event Category before creating.');
      return;
    }
    if (_startDateController.text.trim().isEmpty || _endDateController.text.trim().isEmpty) {
      setState(() => _errorMessage = '⚠ Start Date and End Date are required.');
      return;
    }

    // Clear any previous error
    setState(() {
      _errorMessage = null;
      _isSaving = true;
    });

    final payload = {
      "eventTitle": _titleController.text.trim(),
      "subtitle": _subtitleController.text,
      "eventCategoryId": _selectedCategory!['eventCategoryId'],
      "status": "UPCOMING",
      "startDate": _startDateController.text,
      "endDate": _endDateController.text,
      "startTime": _startTimeController.text,
      "endTime": _endTimeController.text,
      "location": _locationController.text,
      "venue": _venueController.text,
      "expectedAttendees": int.tryParse(_expectedAttendeesController.text) ?? 0,
      "organizerName": _organizerNameController.text,
      "organizerContact": _organizerContactController.text,
      "budgetEstimate": int.tryParse(_budgetController.text) ?? 0,
      "eventManagerId": 101,
      "managerName": _managerNameController.text.isEmpty
          ? "System User"
          : _managerNameController.text,
      "managerDesignation": _managerDesignationController.text,
      "managerContact": _managerContactController.text,
      "description": _descriptionController.text,
      "clinicalDirectives": _clinicalDirectivesController.text,
      "emergencyProtocol": _emergencyProtocolController.text,
    };

    final res = await EventApiService.createEvent(payload);
    setState(() => _isSaving = false);

    if (res != null &&
        (res['statusCode'] == 200 ||
            res['statusCode'] == 201 ||
            res['status_code'] == 200 ||
            res['status_code'] == 201)) {
      widget.onEventCreated();
      if (mounted) Navigator.pop(context);
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event Created Successfully',
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
    } else {
      // Show error in banner
      final msg = res?['message']?.toString() ??
          res?['error']?.toString() ??
          'Failed to create event. Please try again.';
      setState(() => _errorMessage = '❌ $msg');
    }
  }
}
