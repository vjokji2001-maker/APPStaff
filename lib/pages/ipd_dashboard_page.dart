import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staff_mate/api/ipd_service.dart';
import 'package:staff_mate/models/dashboard_data.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:staff_mate/pages/req_pres.dart';
import 'package:staff_mate/pages/req_inve.dart';
import 'package:staff_mate/pages/shift_patient.dart';
import 'package:staff_mate/services/clinic_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:staff_mate/pages/treatment_record.dart'; 
import 'package:staff_mate/pages/notification_details.dart';
import 'package:staff_mate/services/user_information_service.dart'; 
import 'package:staff_mate/pages/vitals_page.dart';
import 'package:staff_mate/pages/day_to_day_notes.dart';
import 'package:staff_mate/pages/upload_doc.dart';
import 'package:staff_mate/APIs/api_endpoints.dart';
import 'package:staff_mate/widgets/ipd/shift_bed_dialog.dart';
import 'package:staff_mate/widgets/ipd/apply_package_dialog.dart';
import 'package:staff_mate/widgets/ipd/day_to_day_notes_dialog.dart';
import 'package:staff_mate/widgets/ipd/day_to_day_notes_sheet.dart';
import 'package:staff_mate/widgets/ipd/vitals_entry_sheet.dart';
class IpdDashboardPage extends StatefulWidget {
  const IpdDashboardPage({super.key});

  @override
  State<IpdDashboardPage> createState() => _IpdDashboardPageState();
}

class _IpdDashboardPageState extends State<IpdDashboardPage> {
  final IpdService ipdService = IpdService();
  final ClinicService clinicService = ClinicService();
  
  late Future<IpdDashboardData> _dashboardDataFuture;
  List<dynamic> _practitionerList = [];
  List<dynamic> _specializationList = [];
  List<dynamic> _wardList = [];

  List<Patient> _allPatients = [];
  List<Patient> _filteredPatients = [];

  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilterCategory;
  String _selectedWard = 'All Ward';
  String _selectedStatus = 'Active';
  String _selectedCategory = 'Format1';
  DateTimeRange? _selectedDateRange;

  final List<String> _wardOptions = ['All Ward'];
  final List<String> statusOptions = ['Active', 'Inactive'];
  final List<String> categoryOptions = ['Format1', 'Free Case'];

  double _excessLimitAmount = 0.0;
  
  int avaLen = 0, tpLen = 0, pTpLen = 0,
      mlcLen = 0, selfLen = 0, totalBed = 0,
      dischargeLen = 0, exceedLen = 0, inhouseLen = 0;

  // Add user initial variable
  String userInitial = '';

  @override
  void initState() {
    super.initState();
    _loadExcessLimit();
    _refreshDashboardData();
    _searchController.addListener(_filterPatients);
    _fetchPractitionerList();
    _fetchSpecializationList();
    _fetchWardList();
    _loadUserInitial(); // Load user initial
  }


Future<void> _loadUserInitial() async {
  try {
    // 1st try: getCompleteUserData
    final completeData = await UserInformationService.getCompleteUserData();
    if (completeData != null && completeData.containsKey('data')) {
      final data = completeData['data'] as Map<String, dynamic>;
      final String init  = data['initial']?.toString() ?? '';
      final String first = data['firstName']?.toString() ?? '';
      final String last  = data['lastName']?.toString() ?? '';
      final String uid   = data['userId']?.toString() ?? '';
      String fullName = '$init $first $last'.trim();
      if (fullName.isEmpty) fullName = uid;
      if (fullName.isNotEmpty && mounted) {
        setState(() => userInitial = fullName[0].toUpperCase());
        return;
      }
    }

    // 2nd try: getSavedUserInformation
    final userInfo = await UserInformationService.getSavedUserInformation();
    if (userInfo.isNotEmpty) {
      final String init  = userInfo['initial']?.toString() ?? '';
      final String first = userInfo['firstName']?.toString() ?? '';
      final String last  = userInfo['lastName']?.toString() ?? '';
      final String uid   = userInfo['userId']?.toString() ?? '';
      String fullName = '$init $first $last'.trim();
      if (fullName.isEmpty) fullName = uid; // userId as guaranteed fallback
      if (fullName.isNotEmpty && mounted) {
        setState(() => userInitial = fullName[0].toUpperCase());
        return;
      }
    }

    // 3rd try: getUserProfileForDisplay
    final profileInfo = await UserInformationService.getUserProfileForDisplay();
    if (profileInfo.isNotEmpty) {
      // Try fullName first, then userId
      final String fullName = profileInfo['fullName']?.toString() ?? '';
      final String uid      = profileInfo['userId']?.toString() ?? '';
      final String resolved = fullName.isNotEmpty ? fullName : uid;
      if (resolved.isNotEmpty && mounted) {
        setState(() => userInitial = resolved[0].toUpperCase());
      }
    }
  } catch (e) {
    debugPrint('Error loading user initial: $e');
  }
}
  Future<void> _loadExcessLimit() async {
    try {
      _excessLimitAmount = await ClinicService.getExcessLimit();
    } catch (e) {
      _excessLimitAmount = 0.0;
    }
  }

  void _refreshDashboardData() {
    setState(() {
      String apiWardId = "0"; 
      _dashboardDataFuture = ipdService.fetchDashboardData(wardId: apiWardId).then((data) {
        _allPatients = data.patients.where((p) => 
          p.ward.isNotEmpty && p.ward != "N/A" && p.ward.toLowerCase() != "n/a"
        ).toList();
        _calculateBedStats();
        _filterPatients(); 
        return data;
      });
    });
  }

  Future<void> _fetchPractitionerList() async {
    try {
      final practitioners = await ipdService.fetchPractitionerList(
        branchId: "1", specializationId: 0, isVisitingConsultant: 1,
      );
      setState(() => _practitionerList = practitioners);
    } catch (e) { debugPrint('Error loading practitioner list: $e'); }
  }

  Future<void> _fetchSpecializationList() async {
    try {
      final specializations = await ipdService.fetchSpecializationList(branchId: "1");
      setState(() => _specializationList = specializations);
    } catch (e) { debugPrint('Error loading specialization list: $e'); }
  }

  Future<void> _fetchWardList() async {
    try {
      final wards = await ipdService.fetchBranchWardList(branchId: "1");
      setState(() {
        _wardList = wards;
        _wardOptions.clear();
        _wardOptions.add('All Ward');
        for (var ward in wards) {
          if (ward is Map<String, dynamic>) {
            final wardName = ward['wardname'] ?? ward['name'] ?? ward['wardName'] ?? '';
            if (wardName.isNotEmpty && wardName != "N/A" && wardName.toLowerCase() != "n/a") {
              _wardOptions.add(wardName);
            }
          }
        }
      });
    } catch (e) {
      setState(() {
        _wardOptions.addAll(['Emergency', 'Semi-pvt.', 'Pvt.', 'Casualty', 'GEN FEMALE', 'DLX', 'MICU', 'SICU', 'NICU', 'Isolation emergency', 'SUIT ROOM', 'OT Ward', 'Labour Room', 'HDU', 'CCU', 'CT ICU', 'General Ward (4F)']);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPatients() {
    List<Patient> tempPatients = List.from(_allPatients);
    
    final seenBedIds = <dynamic>{};
    tempPatients = tempPatients.where((p) => seenBedIds.add(p.bedid)).toList();
    tempPatients.sort((a, b) => a.bedid.compareTo(b.bedid));

    switch (_selectedFilterCategory) {
      case 'Available':
        tempPatients = tempPatients.where((p) => p.active == 0 && p.isUnderMaintenance == 0).toList();
        break;
      case 'To be Discharged':
        tempPatients = tempPatients.where((p) => p.dischargeStatus != '0' && p.dischargeStatus != '0.0').toList();
        break;
      case 'Excess Amount':
        tempPatients = tempPatients.where((p) {
          final balance = p.patientBalance ?? 0.0;
          return balance > 0 && balance > _excessLimitAmount;
        }).toList();
        break;
      case 'MLC':
        tempPatients = tempPatients.where((p) => p.isMlc != '0' && p.isMlc != '0.0').toList();
        break;
      case 'Self':
        tempPatients = tempPatients.where((p) => 
          p.active == 1 && 
          (p.isMlc == '0' || p.isMlc == '0.0') && 
          (p.dischargeStatus == '0' || p.dischargeStatus == '0.0') && 
          (p.isPrivateTp == '0' || p.isPrivateTp == '0.0') && 
          p.party.toLowerCase() == 'self' && 
          p.isUnderMaintenance == 0
        ).toList();
        break;
      case 'TP':
        tempPatients = tempPatients.where((p) => 
          p.active == 1 && 
          (p.isMlc == '0' || p.isMlc == '0.0') && 
          (p.dischargeStatus == '0' || p.dischargeStatus == '0.0') && 
          p.party.toLowerCase().contains('third party') && 
          !p.party.toLowerCase().contains('corporate') && 
          (p.isPrivateTp == '0' || p.isPrivateTp == '0.0') &&
          p.isUnderMaintenance == 0
        ).toList();
        break;
      case 'TP Corporate':
        tempPatients = tempPatients.where((p) => 
          p.active == 1 && 
          p.party.toLowerCase().contains('corporate') && 
          p.isUnderMaintenance == 0
        ).toList();
        break;
      case 'Inhouse Patients':
        tempPatients = tempPatients.where((p) => p.active == 1).toList();
        break;
      case 'Total Bed':
        break;
      default:
        tempPatients = tempPatients.where((p) => p.active == 1 || (p.active == 0 && p.isUnderMaintenance == 0)).toList();
        break;
    }

    _filteredPatients = tempPatients.where((p) {
      final wardMatch = _selectedWard == 'All Ward' || p.ward == _selectedWard;
      bool dateMatch = true;
      if (_selectedDateRange != null) {
        dateMatch = p.admissionDateTime.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
                    p.admissionDateTime.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }
      final searchText = _searchController.text.toLowerCase();
      final searchMatch = searchText.isEmpty ||
          p.patientname.toLowerCase().contains(searchText) ||
          p.ipdNo.toLowerCase().contains(searchText) ||
          p.practitionername.toLowerCase().contains(searchText) ||
          p.ward.toLowerCase().contains(searchText);
      return wardMatch && dateMatch && searchMatch;
    }).toList();

    if (mounted) setState(() {});
  }

  void _calculateBedStats() {
    avaLen = tpLen = pTpLen = mlcLen = selfLen = totalBed = dischargeLen = exceedLen = inhouseLen = 0;
    List<Patient> data = List.from(_allPatients);
    final seenBedIds = <dynamic>{};
    totalBed = data.where((p) => seenBedIds.add(p.bedid)).length;

    for (var p in data) {
      if (p.active == 0 && p.isUnderMaintenance == 0) {
        avaLen++;
      }
      if (p.active == 1) {
        inhouseLen++;
        if (p.party.toLowerCase().contains('corporate') && p.isUnderMaintenance == 0) {
          pTpLen++;
        }
        else if (p.active == 1 && (p.isMlc == '0' || p.isMlc == '0.0') && (p.dischargeStatus == '0' || p.dischargeStatus == '0.0') && p.party.toLowerCase().contains('third party') && !p.party.toLowerCase().contains('corporate') && (p.isPrivateTp == '0' || p.isPrivateTp == '0.0') && p.isUnderMaintenance == 0) {
          tpLen++;
        }
        if ((p.isMlc != '0' && p.isMlc != '0.0') && p.isUnderMaintenance == 0) {
          mlcLen++;
        }
        if ((p.isMlc == '0' || p.isMlc == '0.0') && (p.dischargeStatus == '0' || p.dischargeStatus == '0.0') && (p.isPrivateTp == '0' || p.isPrivateTp == '0.0') && p.party.toLowerCase() == 'self' && p.isUnderMaintenance == 0) {
          selfLen++;
        }
        if ((p.dischargeStatus != '0' && p.dischargeStatus != '0.0') && p.isUnderMaintenance == 0) {
          dischargeLen++;
        }
      }
      final balance = p.patientBalance ?? 0.0;
      if (balance > 0 && balance > _excessLimitAmount) {
        exceedLen++;
      }
    }
  }

  void _openVitalsEntry(Patient patient) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => VitalsPage(patient: patient))
    ).then((_) {
      _refreshDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1A237E); 
    const Color bgGrey = Color(0xFFF5F7FA);

   return Scaffold(
  backgroundColor: bgGrey,
  body: Stack(
    children: [

      FutureBuilder<IpdDashboardData>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_allPatients.isEmpty && snapshot.hasData && snapshot.data!.patients.isNotEmpty) {
            _allPatients = snapshot.data!.patients.where((p) => p.ward.isNotEmpty && p.ward != "N/A" && p.ward.toLowerCase() != "n/a").toList();
            _filteredPatients = List.from(_allPatients);
            _calculateBedStats();
            WidgetsBinding.instance.addPostFrameCallback((_) => _filterPatients());
          }

          return Column(
            children: [

              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10, right: 10, bottom: 20),
                decoration: const BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("IPD Dashboard", style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Text(
                              userInitial,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: darkBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search Patient, ID, Ward...',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
                                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.6), size: 18),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showFilterBottomSheet,
                            child: Container(
                              height: 40, width: 40,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.tune, color: darkBlue, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFittedStat("Total Beds", totalBed, Colors.blue.shade300),
                        _buildFittedStat("Available", avaLen, Colors.tealAccent.shade700),
                        _buildFittedStat("MLC", mlcLen, Colors.redAccent),
                        _buildFittedStat("Excess Amount", exceedLen, Colors.orangeAccent),
                        _buildFittedStat("To be Discharged", dischargeLen, Colors.yellow),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFittedStat("Inhouse", inhouseLen, Colors.brown),
                        _buildFittedStat("TP", tpLen, Colors.lightGreen.shade400),
                        _buildFittedStat("Self", selfLen, Colors.blueGrey.shade500),
                        _buildFittedStat("TP Corp", pTpLen, Colors.pink.shade200),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: _filteredPatients.isEmpty && _allPatients.isNotEmpty
                    ? Center(child: Text("No patients found", style: GoogleFonts.poppins(color: Colors.grey)))
                    : RefreshIndicator(
                        onRefresh: () async {
                          _refreshDashboardData();
                        },
                        color: darkBlue,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(12),
                          physics: const AlwaysScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 1.15,
                          ),
                          itemCount: _filteredPatients.length,
                          itemBuilder: (context, index) {
                            return PatientGridCardCompact(
                              patient: _filteredPatients[index],
                              excessLimit: _excessLimitAmount,
                              onCardTap: () => _showPatientQuickActionSheet(_filteredPatients[index]),
                              onRefresh: _refreshDashboardData,
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    ],
  ),
);
  }
  
  Widget _buildFittedStat(String label, int count, Color color) {
    String filterKey = label;
    if(label == "Excess") filterKey = "Excess Amount";
    if(label == "Discharge") filterKey = "To be Discharged";
    if(label == "Total") filterKey = "Total Bed";
    if(label == "Inhouse") filterKey = "Inhouse Patients";
    if(label == "TP Corp") filterKey = "TP Corporate";

    bool isSelected = _selectedFilterCategory == filterKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilterCategory = isSelected ? null : filterKey;
            _filterPatients();
          });
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$count", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: isSelected ? color : (label == "Inhouse" ? Colors.brown : color), fontSize: 14, height: 1)),
              const SizedBox(height: 2),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 9, color: isSelected ? Colors.black87 : Colors.white.withOpacity(0.8), fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, height: 1)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    String tempSelectedWard = _selectedWard;
    String tempSelectedStatus = _selectedStatus;
    String tempSelectedCategory = _selectedCategory;
    DateTimeRange? tempSelectedDateRange = _selectedDateRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, 
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                  Text("Filter Options", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                 
                  Text("Select Ward", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _wardOptions.map((ward) {
                              bool isSelected = tempSelectedWard == ward;
                              return ChoiceChip(
                                label: Text(ward),
                                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                                selected: isSelected,
                                selectedColor: const Color(0xFF1A237E),
                                backgroundColor: Colors.grey[100],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey[300]!)),
                                onSelected: (selected) { if (selected) setModalState(() => tempSelectedWard = ward); },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          Row(children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildDropdownLabel("Status"), _buildDropdown(value: tempSelectedStatus, items: statusOptions, onChanged: (val) => setModalState(() => tempSelectedStatus = val!))])),
                            const SizedBox(width: 15),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildDropdownLabel("Category"), _buildDropdown(value: tempSelectedCategory, items: categoryOptions, onChanged: (val) => setModalState(() => tempSelectedCategory = val!))])),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(elevation:0, backgroundColor: Colors.grey[200], foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () => setModalState(() { tempSelectedWard = 'All Ward'; tempSelectedStatus = 'Active'; tempSelectedCategory = 'Format1'; tempSelectedDateRange = null; }), child: const Text("Reset"))),
                    const SizedBox(width: 10),
                    Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A237E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)), onPressed: () { setState(() { _selectedWard = tempSelectedWard; _selectedStatus = tempSelectedStatus; _selectedCategory = tempSelectedCategory; _selectedDateRange = tempSelectedDateRange; }); Navigator.pop(context); _filterPatients(); }, child: const Text("Apply"))),
                  ])
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)));
  Widget _buildDropdown({required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, isExpanded: true, items: items.map((item) => DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 13)))).toList(), onChanged: onChanged)),
    );
  }
void _showPatientQuickActionSheet(Patient patient) {
  if (patient.active == 0) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bed ${patient.bedname} is Available")));
    return;
  }

  final actions = [
    {'icon': Icons.receipt, 'label': 'Prescription', 'color': Colors.blue, 'onTap': () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReqPrescriptionPage(patientName: patient.patientname, patient: patient))).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.science, 'label': 'Investigation', 'color': Colors.orange, 'onTap': () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ReqInvestigationPage(patientName: patient.patientname, patient: patient))).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.assignment_outlined, 'label': 'Records', 'color': Colors.teal, 'onTap': () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => TreatmentRecordPage(patient: patient))).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.favorite, 'label': 'Vitals', 'color': Colors.redAccent, 'onTap': () {
      Navigator.pop(context);
      _openVitalsEntry(patient);
    }},
    {'icon': Icons.card_giftcard, 'label': 'Packages', 'color': Colors.pink, 'onTap': () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => ApplyPackageDialog(patient: patient),
      ).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.notifications_none, 'label': 'Notifications', 'color': Colors.purple, 'onTap': () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationDetailsPage(patientName: patient.patientname, patientId: patient.ipdNo, admissionId: patient.admissionId))).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.note_add, 'label': 'Day Notes', 'color': Colors.brown, 'onTap': () async {
      Navigator.pop(context);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('day_notes_read_${patient.admissionId}', true);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => DayToDayNotesDialog(patient: patient),
      ).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.upload_file, 'label': 'Upload Doc', 'color': Colors.green, 'onTap': () {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => UploadDocScreen(patient: patient))).then((_) => _refreshDashboardData());
    }},
    {'icon': Icons.local_hospital, 'label': 'Shift Patient', 'color': Colors.deepPurple, 'onTap': () {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => ShiftBedDialog(
          patient: patient,
          onShiftComplete: _refreshDashboardData,
        ),
      );
    }},
  ];

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),

          // Patient info
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Text(patient.patientname[0], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
            title: Text(patient.patientname, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            subtitle: Text("${patient.ward} | Bed: ${patient.bedname}\nIPD: ${patient.ipdNo}", style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("₹${patient.patientBalance}", style: TextStyle(fontWeight: FontWeight.bold, color: patient.patientBalance > 0 ? Colors.red : Colors.green)),
                const Text("Balance", style: TextStyle(fontSize: 10)),
              ],
            ),
          ),

          const Divider(height: 20),
          
          Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 8,
            runSpacing: 16,
            children: actions.map((a) => _actionBtn(
              a['icon'] as IconData,
              a['label'] as String,
              a['color'] as Color,
              a['onTap'] as VoidCallback,
            )).toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
  return SizedBox(
    width: 72, // ← fixed width for all buttons
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    ),
  );
}
}

class PatientGridCardCompact extends StatelessWidget {
  final Patient patient;
  final double excessLimit;
  final VoidCallback onCardTap;
  final VoidCallback? onRefresh;
  
  const PatientGridCardCompact({
    super.key, 
    required this.patient, 
    required this.excessLimit,
    required this.onCardTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    bool isAvailable = patient.active == 0 && patient.isUnderMaintenance == 0;
    
    final balance = patient.patientBalance ?? 0.0;
    bool hasExcess = balance > 0 && balance > excessLimit;
    Color statusColor;
    
    // Safely handle potentially null strings in dart2js
    final safeParty = (patient.party as dynamic) ?? '';
    String party = safeParty.toString().toLowerCase();
    
    final safeDischarge = (patient.dischargeStatus as dynamic) ?? '';
    String dischargeStr = safeDischarge.toString().toLowerCase();

    final safeMlc = (patient.isMlc as dynamic) ?? '';
    String mlcStr = safeMlc.toString().toLowerCase();
    
    if (isAvailable) statusColor = Colors.tealAccent.shade700; 
    else if (dischargeStr == '1' || dischargeStr == 'true') statusColor = Colors.yellow; 
    else if (mlcStr == '1' || mlcStr == 'true') statusColor = Colors.redAccent;
    else if (hasExcess) statusColor = Colors.orangeAccent; 
    else if (party.contains('corporate')) statusColor = Colors.pink.shade200; 
    else if (party.contains('third party')) statusColor = Colors.lightGreen.shade400; 
    else if (party == 'self') statusColor = Colors.blueGrey.shade500;
    else statusColor = Colors.blue.shade300; 

    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 2, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Container(color: statusColor.withOpacity(0.08)),
            Positioned(left: 0, top: 0, bottom: 0, width: 5, child: Container(color: statusColor)),

            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 6, 4), 
              child: isAvailable 
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bed, color: statusColor, size: 24),
                        Text((patient.bedname as dynamic)?.toString() ?? 'N/A', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                        Text("Avail", style: GoogleFonts.poppins(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 11, 
                            backgroundColor: statusColor.withOpacity(0.2), 
                            child: Text(
                              ((patient.patientname as dynamic)?.toString() ?? '').isNotEmpty 
                                ? (patient.patientname as dynamic).toString()[0] 
                                : "?", 
                              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold)
                            )
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text((patient.bedname as dynamic)?.toString() ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87))),
                        ],
                      ),
                      const SizedBox(height: 4), 
                      Text((patient.patientname as dynamic)?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.black87)),
                      Text((patient.ward as dynamic)?.toString() ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, color: Colors.grey[700])),
                      Text("IPD: ${(patient.ipdNo as dynamic)?.toString() ?? ''}", style: TextStyle(fontSize: 9, color: Colors.grey[600])),
                    ],
                  ),
            ),
            if (!isAvailable)
              Positioned(
                top: 4,
                right: 4,
                child: BlinkingNotesIcon(
                  patient: patient,
                  onNotesTap: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => DayToDayNotesDialog(patient: patient),
                    );
                    if (onRefresh != null) {
                      onRefresh!();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );   
  }
}


// class VitalsEntrySheet extends StatefulWidget {
//   final Patient patient;
//   const VitalsEntrySheet({super.key, required this.patient});

//   @override
//   State<VitalsEntrySheet> createState() => _VitalsEntrySheetState();
// }

// class _VitalsEntrySheetState extends State<VitalsEntrySheet> {
//   final TextEditingController _dateController = TextEditingController();
//   final TextEditingController _tempController = TextEditingController();
//   final TextEditingController _hrController = TextEditingController();
//   final TextEditingController _rrController = TextEditingController();
//   final TextEditingController _sysBpController = TextEditingController();
//   final TextEditingController _diaBpController = TextEditingController();
//   final TextEditingController _rbsController = TextEditingController();
//   final TextEditingController _spo2Controller = TextEditingController();
  
//   String _selectedHH = '00';
//   String _selectedMM = '00';
//   bool _isLoading = false;
//   String? _errorMessage;



class BlinkingNotesIcon extends StatefulWidget {
  final Patient patient;
  final VoidCallback onNotesTap;

  const BlinkingNotesIcon({
    super.key,
    required this.patient,
    required this.onNotesTap,
  });

  @override
  State<BlinkingNotesIcon> createState() => _BlinkingNotesIconState();
}

class _BlinkingNotesIconState extends State<BlinkingNotesIcon> {
  late bool _hasUnread;

  @override
  void initState() {
    super.initState();
    _hasUnread = widget.patient.unreadNotesCount > 0;
  }
  
  @override
  void didUpdateWidget(BlinkingNotesIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.patient.unreadNotesCount != oldWidget.patient.unreadNotesCount) {
      setState(() {
        _hasUnread = widget.patient.unreadNotesCount > 0;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    Widget icon = Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.notifications,
          color: _hasUnread ? Colors.redAccent : Colors.grey.shade400,
          size: 20,
        ),
        if (_hasUnread)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${widget.patient.unreadNotesCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );

    return GestureDetector(
      onTap: widget.onNotesTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            if (_hasUnread)
              BoxShadow(
                color: Colors.redAccent.withOpacity(0.3),
                blurRadius: 4,
                spreadRadius: 1,
              )
          ],
        ),
        child: icon,
      ),
    );
  }
}
