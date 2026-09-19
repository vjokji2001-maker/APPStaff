import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppColors {
  static const Color primaryDarkBlue = Color(0xFF1A237E);
  static const Color midDarkBlue = Color(0xFF1B263B);
  static const Color accentBlue = Color(0xFF0289A1);
  static const Color lightBlue = Color(0xFF87CEEB);
  static const Color whiteColor = Colors.white;
  static const Color textDark = Color(0xFF0D1B2A);
  static const Color textBodyColor = Color(0xFF4A5568);
  static const Color lightGreyColor = Color(0xFFF5F7FA);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFE53935);
  static const Color purple = Color(0xFF9C27B0);
  static const Color zoomBlue = Color(0xFF2D8CFF);
  static const Color meetGreen = Color(0xFF34A853);
}

class TrainingModuleScreen extends StatefulWidget {
  final int initialTab;

  const TrainingModuleScreen({super.key, this.initialTab = 0});

  @override
  State<TrainingModuleScreen> createState() => _TrainingModuleScreenState();
}

class _TrainingModuleScreenState extends State<TrainingModuleScreen>
    with SingleTickerProviderStateMixin {
  late int selectedTab;
  late TabController _tabController;

  // Filters
  String selectedRole = 'All Roles';
  String selectedCategory = 'All';
  String selectedStatus = 'All';
  final TextEditingController searchController = TextEditingController();

  final List<String> roleOptions = [
    'All Roles',
    'Doctor',
    'Nurse',
    'Administrator',
    'Technician',
    'All Staff',
  ];
  final List<String> categoryOptions = [
    'All',
    'Clinical',
    'Safety',
    'Emergency',
    'Soft Skills',
    'Compliance',
  ];
  final List<String> statusOptions = [
    'All',
    'Not Started',
    'In Progress',
    'Completed',
    'Expired',
  ];

  // Updated mock data (dates relative to Aug 2026)
  final List<Map<String, dynamic>> trainings = [
    {
      'id': '1',
      'title': 'Advanced Cardiac Life Support (ACLS)',
      'category': 'Clinical',
      'categoryColor': Colors.blue,
      'duration': '8 hours',
      'mode': 'In-Person',
      'modeIcon': Icons.people_outline,
      'meetingType': 'inperson',
      'isMandatory': true,
      'progress': 0,
      'status': 'Not Started',
      'expiryWarning': false,
      'description': 'Comprehensive ACLS certification course',
      'detailedDesc':
          'This American Heart Association ACLS course covers advanced cardiovascular life support techniques, team dynamics, and emergency response protocols for healthcare professionals.',
      'keyTopics': [
        'CPR & AED',
        'Airway Management',
        'Pharmacology',
        'Rhythm Recognition',
      ],
      'role': 'Doctors, Nurses',
      'sessionDate': '2026-08-20',
      'sessionTime': '09:00 AM - 05:00 PM',
      'venue': 'Conference Room A, Main Hospital',
      'instructor': 'Dr. James Wilson',
      'availableSeats': 15,
      'totalSeats': 30,
      'certificateAvailable': true,
      'registrationDeadline': '2026-08-15',
      'meetingLink': null,
    },
    {
      'id': '2',
      'title': 'Infection Control & Prevention',
      'category': 'Safety',
      'categoryColor': Colors.green,
      'duration': '4 hours',
      'mode': 'Virtual',
      'modeIcon': Icons.videocam_outlined,
      'meetingType': 'zoom',
      'isMandatory': true,
      'progress': 0,
      'status': 'Not Started',
      'expiryWarning': false,
      'description': 'Latest infection control protocols',
      'detailedDesc':
          'Essential training on infection prevention, PPE usage, sterilization techniques, and waste management in healthcare settings.',
      'keyTopics': [
        'Hand Hygiene',
        'PPE Donning/Doffing',
        'Sterilization',
        'Biohazard Waste',
      ],
      'role': 'All Staff',
      'sessionDate': '2026-08-25',
      'sessionTime': '10:00 AM - 02:00 PM',
      'venue': 'Zoom Meeting',
      'instructor': 'Dr. Sarah Chen',
      'availableSeats': 45,
      'totalSeats': 100,
      'certificateAvailable': true,
      'registrationDeadline': '2026-08-22',
      'meetingLink': 'https://zoom.us/j/123456789',
      'meetingId': '123 456 789',
      'password': '123456',
    },
    {
      'id': '3',
      'title': 'Emergency Response Team Training',
      'category': 'Emergency',
      'categoryColor': Colors.red,
      'duration': '6 hours',
      'mode': 'In-Person',
      'modeIcon': Icons.people_outline,
      'meetingType': 'inperson',
      'isMandatory': false,
      'progress': 100,
      'status': 'Completed',
      'expiryWarning': false,
      'description': 'ERT certification program',
      'detailedDesc':
          'Hands-on training for emergency response team members including disaster preparedness, triage, and crisis management.',
      'keyTopics': [
        'Disaster Triage',
        'Crisis Communication',
        'Decontamination',
        'Command Center',
      ],
      'role': 'ERT Members',
      'sessionDate': '2026-07-15',
      'sessionTime': '08:00 AM - 02:00 PM',
      'venue': 'Training Ground, Building B',
      'instructor': 'Chief Michael Roberts',
      'availableSeats': 0,
      'totalSeats': 25,
      'certificateAvailable': true,
      'completionDate': '2026-07-15',
      'meetingLink': null,
    },
    {
      'id': '4',
      'title': 'Patient Communication Skills',
      'category': 'Soft Skills',
      'categoryColor': Colors.purple,
      'duration': '3 hours',
      'mode': 'Virtual',
      'modeIcon': Icons.videocam_outlined,
      'meetingType': 'meet',
      'isMandatory': false,
      'progress': 40,
      'status': 'In Progress',
      'expiryWarning': false,
      'description': 'Effective communication workshop',
      'detailedDesc':
          'Learn advanced communication techniques for better patient interaction, family counseling, and breaking bad news with empathy.',
      'keyTopics': [
        'Active Listening',
        'Empathy',
        'Breaking Bad News',
        'Cultural Sensitivity',
      ],
      'role': 'Nurses, Front Desk',
      'sessionDate': '2026-08-12',
      'sessionTime': '01:00 PM - 04:00 PM',
      'venue': 'Google Meet',
      'instructor': 'Dr. Lisa Park',
      'availableSeats': 25,
      'totalSeats': 50,
      'certificateAvailable': true,
      'registrationDeadline': '2026-08-10',
      'meetingLink': 'https://meet.google.com/abc-defg-hij',
    },
    {
      'id': '5',
      'title': 'Fire Safety & Evacuation Drill',
      'category': 'Safety',
      'categoryColor': Colors.orange,
      'duration': '2 hours',
      'mode': 'In-Person',
      'modeIcon': Icons.people_outline,
      'meetingType': 'inperson',
      'isMandatory': true,
      'progress': 0,
      'status': 'Expired',
      'expiryWarning': true,
      'description': 'Annual fire safety certification',
      'detailedDesc':
          'Mandatory annual fire safety training covering fire prevention, evacuation procedures, and fire extinguisher use.',
      'keyTopics': [
        'Fire Extinguishers',
        'Evacuation Routes',
        'Fire Prevention',
        'Emergency Codes',
      ],
      'role': 'All Staff',
      'sessionDate': '2026-06-10',
      'sessionTime': '09:00 AM - 11:00 AM',
      'venue': 'Main Auditorium',
      'instructor': 'Safety Officer Thompson',
      'availableSeats': 0,
      'totalSeats': 200,
      'certificateAvailable': true,
      'registrationDeadline': '2026-06-05',
      'meetingLink': null,
    },
  ];

  final Map<String, dynamic> progressSummary = {
    'total': 12,
    'completed': 5,
    'pending': 6,
    'expired': 1,
    'completionPercentage': 42,
  };

  @override
  void initState() {
    super.initState();
    selectedTab = widget.initialTab;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: selectedTab,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging == false) {
        setState(() {
          selectedTab = _tabController.index;
        });
      }
    });
    searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Filtered list (search + role + category + status)
  List<Map<String, dynamic>> get filteredTrainings {
    final query = searchController.text.trim().toLowerCase();

    return trainings.where((t) {
      // Search
      final matchesSearch =
          query.isEmpty ||
          t['title'].toString().toLowerCase().contains(query) ||
          t['category'].toString().toLowerCase().contains(query) ||
          t['instructor'].toString().toLowerCase().contains(query) ||
          t['role'].toString().toLowerCase().contains(query);

      // Role
      final matchesRole =
          selectedRole == 'All Roles' ||
          t['role'].toString().toLowerCase().contains(
            selectedRole.toLowerCase(),
          ) ||
          (selectedRole == 'All Staff' &&
              t['role'].toString().toLowerCase().contains('all'));

      // Category
      final matchesCategory =
          selectedCategory == 'All' || t['category'] == selectedCategory;

      // Status
      final matchesStatus =
          selectedStatus == 'All' || t['status'] == selectedStatus;

      return matchesSearch && matchesRole && matchesCategory && matchesStatus;
    }).toList();
  }

  void _showFilterDialog() {
    String tempRole = selectedRole;
    String tempCategory = selectedCategory;
    String tempStatus = selectedStatus;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Filter Trainings',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterSection(
                            title: 'Role',
                            options: roleOptions,
                            selected: tempRole,
                            onSelect: (v) => setModalState(() => tempRole = v),
                          ),
                          const SizedBox(height: 24),
                          _buildFilterSection(
                            title: 'Category',
                            options: categoryOptions,
                            selected: tempCategory,
                            onSelect: (v) =>
                                setModalState(() => tempCategory = v),
                          ),
                          const SizedBox(height: 24),
                          _buildFilterSection(
                            title: 'Status',
                            options: statusOptions,
                            selected: tempStatus,
                            onSelect: (v) =>
                                setModalState(() => tempStatus = v),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempRole = 'All Roles';
                                tempCategory = 'All';
                                tempStatus = 'All';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: AppColors.accentBlue,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Reset',
                              style: GoogleFonts.poppins(
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Important: update parent state
                              setState(() {
                                selectedRole = tempRole;
                                selectedCategory = tempCategory;
                                selectedStatus = tempStatus;
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Apply',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.lightGreyColor,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentBlue
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  option,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: selectedTab,
              children: [
                _buildTrainingList(),
                _buildMyProgress(),
                _buildCompletedTrainings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final mandatoryPending = trainings
        .where((t) => t['isMandatory'] == true && t['status'] != 'Completed')
        .length;

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryDarkBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Training & Development',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (mandatoryPending > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$mandatoryPending Mandatory Pending',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      'Pending',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${trainings.where((t) => t['status'] == 'Not Started' || t['status'] == 'In Progress').length}',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryDarkBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.accentBlue,
        indicatorWeight: 3,
        labelColor: AppColors.accentBlue,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'All Trainings'),
          Tab(text: 'My Progress'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTrainingList() {
    final list = filteredTrainings;

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No trainings found',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildTrainingCard(list[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final hasActiveFilter =
        selectedRole != 'All Roles' ||
        selectedCategory != 'All' ||
        selectedStatus != 'All';

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.lightGreyColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search training...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    size: 20,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _showFilterDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: hasActiveFilter
                    ? AppColors.accentBlue
                    : AppColors.accentBlue.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Center(
                    child: Icon(Icons.tune, color: Colors.white, size: 22),
                  ),
                  if (hasActiveFilter)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
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

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    Color statusColor;
    IconData statusIcon;

    switch (training['status']) {
      case 'Not Started':
        statusColor = Colors.grey;
        statusIcon = Icons.radio_button_unchecked;
        break;
      case 'In Progress':
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case 'Completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Expired':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    final sessionDate = DateTime.parse(training['sessionDate']);
    final formattedDate = DateFormat('EEE, MMM d, yyyy').format(sessionDate);
    final isRegistrationOpen =
        training['availableSeats'] > 0 && training['status'] == 'Not Started';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingDetailScreen(
              training: training,
              onRegister: isRegistrationOpen
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TrainingRegistrationPage(training: training),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: (training['categoryColor'] as Color).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    training['modeIcon'] as IconData,
                    color: training['categoryColor'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              training['title'],
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textDark,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (training['isMandatory'] == true)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Mandatory',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (training['categoryColor'] as Color)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              training['category'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: training['categoryColor'] as Color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              training['role'],
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreyColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          formattedDate,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Text(
                          training['sessionTime'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          training['venue'],
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Instructor: ${training['instructor']}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: training['availableSeats'] > 0
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        training['availableSeats'] > 0
                            ? Icons.event_available
                            : Icons.event_busy,
                        size: 14,
                        color: training['availableSeats'] > 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        training['availableSeats'] > 0
                            ? '${training['availableSeats']} seats left'
                            : 'Fully Booked',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: training['availableSeats'] > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      training['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isRegistrationOpen) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TrainingRegistrationPage(training: training),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Register Now',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== MY PROGRESS TAB ====================
  Widget _buildMyProgress() {
    final registeredTrainings = trainings
        .where(
          (t) => t['status'] == 'Not Started' || t['status'] == 'In Progress',
        )
        .toList();

    final upcoming = trainings
        .where(
          (t) =>
              t['status'] == 'Not Started' &&
              DateTime.parse(t['sessionDate']).isAfter(DateTime.now()),
        )
        .toList();

    final inProgress = trainings
        .where((t) => t['status'] == 'In Progress')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Total',
                        '${progressSummary['total']}',
                        Icons.assignment,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        'Completed',
                        '${progressSummary['completed']}',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        'Registered',
                        '${registeredTrainings.length}',
                        Icons.event_available,
                        AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        'Expired',
                        '${progressSummary['expired']}',
                        Icons.error,
                        Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 75,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreyColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Completion',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${progressSummary['completionPercentage']}%',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildExpandableSection(
            title: 'Upcoming Sessions',
            icon: Icons.upcoming,
            color: AppColors.accentBlue,
            itemCount: upcoming.length,
            child: Column(
              children: upcoming
                  .take(3)
                  .map((t) => _buildUpcomingSessionCard(t))
                  .toList(),
            ),
            onViewAll: () {
              _showAllItemsSheet(
                'Upcoming Sessions',
                upcoming,
                Icons.upcoming,
                AppColors.accentBlue,
              );
            },
          ),
          const SizedBox(height: 16),
          _buildExpandableSection(
            title: 'In Progress',
            icon: Icons.pending,
            color: Colors.orange,
            itemCount: inProgress.length,
            child: Column(
              children: inProgress
                  .take(3)
                  .map((t) => _buildProgressItem(t))
                  .toList(),
            ),
            onViewAll: () {
              _showAllItemsSheet(
                'In Progress',
                inProgress,
                Icons.pending,
                Colors.orange,
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.recommend,
                  color: AppColors.purple,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Recommended for You',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trainings.length > 3 ? 3 : trainings.length,
              itemBuilder: (context, index) {
                return _buildRecommendedCard(trainings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    required Color color,
    required int itemCount,
    required Widget child,
    required VoidCallback onViewAll,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                if (itemCount > 3)
                  GestureDetector(
                    onTap: onViewAll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'View All',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            size: 12,
                            color: AppColors.accentBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (itemCount == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'No items',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14),
              child: child,
            ),
        ],
      ),
    );
  }

  void _showAllItemsSheet(
    String title,
    List<Map<String, dynamic>> items,
    IconData icon,
    Color color,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  if (title == 'Upcoming Sessions') {
                    return _buildUpcomingSessionCard(items[index]);
                  }
                  return _buildProgressItem(items[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionCard(Map<String, dynamic> training) {
    final sessionDate = DateTime.parse(training['sessionDate']);

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingDetailScreen(
              training: training,
              onRegister: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TrainingRegistrationPage(training: training),
                  ),
                );
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: (training['categoryColor'] as Color).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(sessionDate),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: training['categoryColor'] as Color,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(sessionDate),
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: training['categoryColor'] as Color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          training['sessionTime'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          training['venue'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${training['availableSeats']} seats',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(Map<String, dynamic> training) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TrainingDetailScreen(training: training, onRegister: null),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.lightGreyColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: (training['categoryColor'] as Color).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                training['modeIcon'] as IconData,
                color: training['categoryColor'] as Color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 10,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat(
                          'MMM d',
                        ).format(DateTime.parse(training['sessionDate'])),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 10,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        training['sessionTime'].toString().split(' - ')[0],
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: training['progress'] > 0
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${training['progress']}%',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: training['progress'] > 0
                      ? Colors.blue.shade700
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      height: 75,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(Map<String, dynamic> training) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingDetailScreen(
              training: training,
              onRegister:
                  training['status'] == 'Not Started' &&
                      training['availableSeats'] > 0
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TrainingRegistrationPage(training: training),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        );
      },
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (training['categoryColor'] as Color).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    training['modeIcon'] as IconData,
                    color: training['categoryColor'] as Color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    training['duration'],
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              training['title'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 10,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat(
                    'MMM d',
                  ).format(DateTime.parse(training['sessionDate'])),
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.people, size: 10, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  '${training['availableSeats']} seats',
                  style: GoogleFonts.poppins(
                    fontSize: 9,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== COMPLETED TAB ====================
  Widget _buildCompletedTrainings() {
    final completed = trainings
        .where((t) => t['status'] == 'Completed')
        .toList();

    if (completed.isEmpty) {
      return Center(
        child: Text(
          'No completed trainings yet',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: completed.length,
      itemBuilder: (context, index) {
        return _buildCompletedCard(completed[index]);
      },
    );
  }

  Widget _buildCompletedCard(Map<String, dynamic> training) {
    final completionDate = DateTime.parse(
      training['completionDate'] ?? training['sessionDate'],
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TrainingDetailScreen(training: training, onRegister: null),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    training['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed: ${DateFormat('MMM d, yyyy').format(completionDate)}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CertificateScreen(training: training),
                    ),
                  );
                },
                icon: const Icon(Icons.card_membership_outlined, size: 20),
                color: AppColors.accentBlue,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== REGISTRATION PAGE ====================
class TrainingRegistrationPage extends StatefulWidget {
  final Map<String, dynamic> training;

  const TrainingRegistrationPage({super.key, required this.training});

  @override
  State<TrainingRegistrationPage> createState() =>
      _TrainingRegistrationPageState();
}

class _TrainingRegistrationPageState extends State<TrainingRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedRole;
  bool _isSubmitting = false;

  final List<String> _roles = [
    'Doctor',
    'Nurse',
    'Administrator',
    'Technician',
    'Pharmacist',
    'Lab Technician',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Stronger validators
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\.']+$").hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces and dots';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (digitsOnly.length > 15) {
      return 'Phone number is too long';
    }
    return null;
  }

  String? _validateRole(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your role';
    }
    return null;
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Capture the navigator BEFORE showing the dialog
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              'Registration Successful!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'You have successfully registered for ${widget.training['title']}.\n\nA confirmation email has been sent to ${_emailController.text.trim()}.',
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // 1. Close the success dialog
                Navigator.of(dialogContext).pop();

                // 2. Close Registration page
                navigator.pop();

                // 3. (Optional) Close Detail page if user came from there
                if (navigator.canPop()) {
                  navigator.pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Done',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionDate = DateTime.parse(widget.training['sessionDate']);

    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: Colors.white,
        title: Text(
          'Training Registration',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Training Summary Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (widget.training['categoryColor'] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.training['modeIcon'] as IconData,
                          color: widget.training['categoryColor'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.training['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (widget.training['categoryColor'] as Color)
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.training['category'],
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                      widget.training['categoryColor'] as Color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreyColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          Icons.calendar_today,
                          'Date',
                          DateFormat('EEEE, MMMM d, yyyy').format(sessionDate),
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          Icons.access_time,
                          'Time',
                          widget.training['sessionTime'],
                        ),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          Icons.location_on,
                          'Venue',
                          widget.training['venue'],
                        ),
                        if (widget.training['meetingType'] != 'inperson') ...[
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            widget.training['meetingType'] == 'zoom'
                                ? Icons.videocam
                                : Icons.video_call,
                            'Platform',
                            widget.training['meetingType']
                                .toString()
                                .toUpperCase(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Registration Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Information',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      textCapitalization: TextCapitalization.words,
                      decoration: _inputDecoration(
                        label: 'Full Name',
                        icon: Icons.person_outline,
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: _inputDecoration(
                        label: 'Select your role',
                        icon: Icons.work_outline,
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(
                            role,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedRole = value);
                      },
                      validator: _validateRole,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration(
                        label: 'Email Address',
                        icon: Icons.email_outlined,
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],

                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.normal, // 👈 important
                        color: Colors.black87,
                      ),

                      decoration: InputDecoration(
                        hintText: 'Phone Number',

                        hintStyle: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),

                        prefixIcon: const Icon(
                          Icons.phone,
                          color: Color(0xFF0B8FA3),
                        ),

                        filled: true,
                        fillColor: const Color(0xFFF5F6FA),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }

                        if (value.length != 10) {
                          return 'Phone number must be 10 digits';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGreyColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'By registering, you agree to the terms and conditions of the training program.',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.accentBlue
                              .withValues(alpha: 0.6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Complete Registration',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
      prefixIcon: Icon(icon, color: AppColors.accentBlue, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
      ),
      filled: true,
      fillColor: AppColors.lightGreyColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentBlue),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== DETAIL SCREEN ====================
class TrainingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> training;
  final VoidCallback? onRegister;

  const TrainingDetailScreen({
    super.key,
    required this.training,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final sessionDate = DateTime.parse(training['sessionDate']);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(sessionDate);
    final isRegistrationOpen =
        training['availableSeats'] > 0 && training['status'] == 'Not Started';

    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: Colors.white,
        title: Text(
          'Training Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (training['categoryColor'] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          training['modeIcon'] as IconData,
                          color: training['categoryColor'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              training['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (training['categoryColor'] as Color)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    training['category'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: training['categoryColor'] as Color,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (training['isMandatory'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Mandatory',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreyColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          Icons.calendar_today,
                          'Date',
                          formattedDate,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.access_time,
                          'Time',
                          training['sessionTime'],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.location_on,
                          'Venue',
                          training['venue'],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.person,
                          'Instructor',
                          training['instructor'],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.people,
                          'Target Audience',
                          training['role'],
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.access_time_filled,
                          'Duration',
                          training['duration'],
                        ),
                        if (training['meetingType'] != 'inperson') ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            training['meetingType'] == 'zoom'
                                ? Icons.videocam
                                : Icons.video_call,
                            'Platform',
                            training['meetingType'].toString().toUpperCase(),
                          ),
                          if (training['meetingId'] != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.numbers,
                              'Meeting ID',
                              training['meetingId'],
                            ),
                          ],
                          if (training['password'] != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                              Icons.lock,
                              'Password',
                              training['password'],
                            ),
                          ],
                        ],
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          Icons.people_outline,
                          'Available Seats',
                          '${training['availableSeats']} of ${training['totalSeats']}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About This Training',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    training['detailedDesc'],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Key Topics',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(training['keyTopics'] as List).map<Widget>((topic) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.circle,
                            size: 6,
                            color: AppColors.accentBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              topic,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (training['status'] == 'Not Started' && isRegistrationOpen)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      onRegister ??
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TrainingRegistrationPage(training: training),
                          ),
                        );
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Register for this Training',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (training['status'] == 'Completed')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CertificateScreen(training: training),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.card_membership_outlined, size: 20),
                  label: Text(
                    'View Certificate',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else if (training['status'] == 'Expired')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.red.shade700,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This training session has expired. Registration is closed.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.red.shade700,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accentBlue),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== CERTIFICATE SCREEN ====================
class CertificateScreen extends StatelessWidget {
  final Map<String, dynamic> training;

  const CertificateScreen({super.key, required this.training});

  @override
  Widget build(BuildContext context) {
    final completionDate = DateTime.parse(
      training['completionDate'] ?? training['sessionDate'],
    );

    return Scaffold(
      backgroundColor: AppColors.lightGreyColor,

      appBar: AppBar(
        backgroundColor: AppColors.primaryDarkBlue,
        foregroundColor: Colors.white,
        title: Text(
          'Certificate',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, size: 22),
          ),
        ],
      ),

      // ================= BODY =================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ================= CERTIFICATE =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],

                  border: Border.all(color: Colors.amber.shade200, width: 3),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // MEDAL ICON
                    Icon(
                      Icons.military_tech,
                      size: 60,
                      color: Colors.amber.shade700,
                    ),

                    const SizedBox(height: 16),

                    // CERTIFICATE
                    Text(
                      'CERTIFICATE',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDarkBlue,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // OF COMPLETION
                    Text(
                      'OF COMPLETION',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // DESCRIPTION
                    Text(
                      'This is to certify that',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // NAME
                    Text(
                      'John Doe',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'has successfully completed',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TRAINING TITLE
                    Text(
                      training['title']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // ================= DATE + ID =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // DATE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                DateFormat(
                                  'MMM d, yyyy',
                                ).format(completionDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // CERTIFICATE ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Certificate ID',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'CERT-${training['id'].toString().padLeft(6, '0')}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // INSTRUCTOR
                    Text(
                      'Instructor: ${training['instructor'] ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // SPACE BETWEEN CERTIFICATE AND BUTTON
              const SizedBox(height: 30),

              // ================= DOWNLOAD BUTTON =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},

                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(vertical: 16),

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),

                    elevation: 0,
                  ),

                  icon: const Icon(Icons.file_download_outlined, size: 20),

                  label: Text(
                    'Download Certificate',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              // Bottom spacing
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
