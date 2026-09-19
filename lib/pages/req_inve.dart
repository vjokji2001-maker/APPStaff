import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:staff_mate/models/patient.dart';
import 'package:staff_mate/services/notification_service.dart';
import 'package:staff_mate/api/ipd_service.dart';
import '../services/investigation_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AI HELPER CLASS – All 9 features live here
// ─────────────────────────────────────────────────────────────────────────────
class InvestigationAI {
  // ── 1. Common Test Bundles ────────────────────────────────────────────────
  static const Map<String, List<String>> bundles = {
    'cbc': [
      'hemoglobin',
      'tlc',
      'dlc',
      'platelet count',
      'pcv',
      'mcv',
      'mch',
      'mchc',
    ],
    'complete blood count': ['hemoglobin', 'tlc', 'dlc', 'platelet count'],
    'kft': ['urea', 'creatinine', 'uric acid', 'sodium', 'potassium'],
    'kidney function': ['urea', 'creatinine', 'uric acid'],
    'lft': [
      'sgot',
      'sgpt',
      'bilirubin',
      'alkaline phosphatase',
      'albumin',
      'protein',
    ],
    'liver function': ['sgot', 'sgpt', 'bilirubin'],
    'lipid': ['cholesterol', 'triglyceride', 'hdl', 'ldl'],
    'lipid profile': ['cholesterol', 'triglyceride', 'hdl', 'ldl'],
    'tft': ['t3', 't4', 'tsh'],
    'thyroid': ['t3', 't4', 'tsh'],
    'urine': ['urine routine', 'urine microscopy'],
    'blood sugar': ['fbs', 'ppbs', 'hba1c'],
  };

  // ── 2. Auto-Indication Generator ──────────────────────────────────────────
  static const Map<String, String> indications = {
    'cbc': 'Routine blood investigation / fever / anemia evaluation',
    'complete blood count':
        'Routine blood investigation / fever / anemia evaluation',
    'kft': 'Renal function assessment / pre-operative evaluation',
    'kidney': 'Renal function assessment / pre-operative evaluation',
    'lft': 'Liver function / jaundice / hepatitis evaluation',
    'liver': 'Liver function / jaundice / hepatitis evaluation',
    'lipid': 'Lipid profile / cardiovascular risk assessment',
    'tft': 'Thyroid function evaluation',
    'thyroid': 'Thyroid function evaluation',
    'ecg': 'Cardiac evaluation / chest pain / pre-operative',
    'x-ray': 'Radiological evaluation',
    'xray': 'Radiological evaluation',
    'urine': 'Urinary tract infection / routine check',
    'blood sugar': 'Diabetes screening / monitoring',
    'hba1c': 'Diabetes control assessment',
    'mri': 'Detailed imaging for soft tissue / neurological evaluation',
    'ct': 'Cross-sectional imaging evaluation',
  };

  // ── 3. Common Abbreviations (Fuzzy Matching Engine) ───────────────────────
  static const Map<String, List<String>> abbreviations = {
    'cbc': ['complete blood count', 'blood count', 'hemogram'],
    'kft': ['kidney function test', 'renal function', 'rft'],
    'lft': ['liver function test', 'hepatic function'],
    'rft': ['renal function test', 'kidney function'],
    'tft': ['thyroid function test'],
    'ecg': ['electrocardiogram', 'ekg'],
    'ekg': ['electrocardiogram', 'ecg'],
    'xray': ['x-ray', 'radiograph', 'chest x ray'],
    'x ray': ['x-ray', 'radiograph'],
    'ct': ['computed tomography', 'cat scan'],
    'ct scan': ['computed tomography'],
    'mri': ['magnetic resonance imaging'],
    'urine': ['urinalysis', 'urine analysis', 'urine r/e', 'urine routine'],
    'ua': ['urinalysis', 'urine analysis'],
    'stool': ['stool analysis', 'stool r/e'],
    'blood': ['blood test'],
    'sugar': ['blood sugar', 'glucose', 'fbs', 'ppbs'],
    'lipid': ['lipid profile'],
    'hba1c': ['glycated hemoglobin', 'hb a1c'],
    'pt': ['prothrombin time'],
    'inr': ['international normalized ratio'],
    'esr': ['erythrocyte sedimentation rate'],
    'crp': ['c-reactive protein'],
  };

  // ── 4. Fuzzy Matching Engine (Dice + contains + abbreviation) ─────────────
  static double similarity(String a, String b) {
    a = _normalize(a);
    b = _normalize(b);
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;
    if (a.contains(b) || b.contains(a)) return 0.88;

    // Dice coefficient on character bigrams
    final bigramsA = _bigrams(a);
    final bigramsB = _bigrams(b);
    if (bigramsA.isEmpty || bigramsB.isEmpty) return 0.0;
    final intersection = bigramsA.intersection(bigramsB).length;
    return (2.0 * intersection) / (bigramsA.length + bigramsB.length);
  }

  static String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static Set<String> _bigrams(String s) {
    final set = <String>{};
    for (int i = 0; i < s.length - 1; i++) {
      set.add(s.substring(i, i + 2));
    }
    return set;
  }

  static bool isAbbreviationMatch(String spoken, String fullName) {
    final normSpoken = _normalize(spoken).replaceAll(' ', '');
    final normFull = _normalize(fullName).replaceAll(' ', '');
    if (normFull.contains(normSpoken) && normSpoken.length > 2) return true;

    for (final entry in abbreviations.entries) {
      if (normSpoken.contains(entry.key) || entry.key.contains(normSpoken)) {
        for (final form in entry.value) {
          if (normFull.contains(form.replaceAll(' ', ''))) return true;
        }
      }
    }
    return false;
  }

  // ── 5. Smart Search Ranking ───────────────────────────────────────────────
  static List<Map<String, dynamic>> rankTests({
    required List<Map<String, dynamic>> tests,
    String? department,
    String? gender,
    int? age,
  }) {
    final scored = tests.map((t) {
      double score = 0.0;
      final name = (t['name'] ?? '').toString().toLowerCase();

      if (department != null) {
        final dept = department.toLowerCase();
        if (dept.contains('cardio') &&
            (name.contains('ecg') ||
                name.contains('echo') ||
                name.contains('troponin')))
          score += 3.0;
        if (dept.contains('gynae') || dept.contains('obg')) {
          if (name.contains('pap') ||
              name.contains('pregnancy') ||
              name.contains('beta hcg') ||
              name.contains('ultrasound'))
            score += 3.0;
        }
        if (dept.contains('neuro') &&
            (name.contains('mri') ||
                name.contains('eeg') ||
                name.contains('ct brain')))
          score += 3.0;
        if (dept.contains('ortho') &&
            (name.contains('x-ray') ||
                name.contains('xray') ||
                name.contains('bone')))
          score += 2.5;
        if (dept.contains('path') || dept.contains('lab')) {
          if (name.contains('cbc') ||
              name.contains('kft') ||
              name.contains('lft'))
            score += 1.5;
        }
      }

      if (gender != null) {
        final g = gender.toLowerCase();
        if (g == 'female' || g == 'f') {
          if (name.contains('pap') ||
              name.contains('pregnancy') ||
              name.contains('beta') ||
              name.contains('thyroid'))
            score += 1.2;
        }
        if (g == 'male' || g == 'm') {
          if (name.contains('psa') || name.contains('prostate')) score += 1.5;
        }
      }

      if (age != null) {
        if (age > 50 &&
            (name.contains('lipid') ||
                name.contains('ecg') ||
                name.contains('sugar') ||
                name.contains('hba1c')))
          score += 1.5;
        if (age < 12 && (name.contains('cbc') || name.contains('blood')))
          score += 1.0;
      }

      // Popular tests get a small boost
      if (name.contains('cbc') ||
          name.contains('kft') ||
          name.contains('lft') ||
          name.contains('urine'))
        score += 0.5;

      return MapEntry(t, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  // ── 6. Smart Test Suggestion (based on age/gender/dept) ───────────────────
  static List<String> suggestTests({
    String? department,
    String? gender,
    int? age,
  }) {
    final suggestions = <String>[];

    // Always useful
    suggestions.addAll(['CBC', 'KFT', 'LFT', 'Urine Routine']);

    if (age != null && age > 40) {
      suggestions.addAll(['Lipid Profile', 'Blood Sugar', 'ECG']);
    }
    if (age != null && age > 50) {
      suggestions.add('HbA1c');
    }

    if (gender != null &&
        (gender.toLowerCase() == 'female' || gender.toLowerCase() == 'f')) {
      suggestions.addAll(['TFT', 'Beta HCG']);
    }

    if (department != null) {
      final d = department.toLowerCase();
      if (d.contains('cardio')) suggestions.addAll(['ECG', 'Echo', 'Troponin']);
      if (d.contains('neuro')) suggestions.addAll(['MRI Brain', 'CT Brain']);
      if (d.contains('ortho')) suggestions.add('X-Ray');
      if (d.contains('gynae'))
        suggestions.addAll(['Pap Smear', 'Ultrasound Pelvis']);
    }

    return suggestions.toSet().toList();
  }

  // ── 7. Contraindication rules (simple) ────────────────────────────────────
  static String? checkContraindication(
    String testName, {
    String? notes,
    String? gender,
    int? age,
  }) {
    final name = testName.toLowerCase();
    if (notes != null) {
      final n = notes.toLowerCase();
      if ((name.contains('mri') || name.contains('magnetic')) &&
          (n.contains('pacemaker') ||
              n.contains('metal implant') ||
              n.contains('cochlear'))) {
        return 'MRI is contraindicated in patients with metal implants / pacemaker.';
      }
      if ((name.contains('contrast') || name.contains('ct with')) &&
          (n.contains('creatinine high') ||
              n.contains('kidney failure') ||
              n.contains('ckd'))) {
        return 'Contrast study risky in patients with impaired renal function.';
      }
    }
    return null;
  }

  // ── 8. Get indication for a test ──────────────────────────────────────────
  static String? getIndication(String testName) {
    final name = testName.toLowerCase();
    for (final entry in indications.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return null;
  }

  // ── 9. Get related bundle tests ───────────────────────────────────────────
  static List<String> getBundle(String testName) {
    final name = testName.toLowerCase();
    for (final entry in bundles.entries) {
      if (name.contains(entry.key)) return entry.value;
    }
    return [];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION MODEL
// ─────────────────────────────────────────────────────────────────────────────
class InvestigationLocation {
  final int id;
  final String name;

  const InvestigationLocation({required this.id, required this.name});

  factory InvestigationLocation.fromJson(Map<String, dynamic> json) {
    return InvestigationLocation(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ReqInvestigationPage extends StatefulWidget {
  final String patientName;
  final Patient patient;
  const ReqInvestigationPage({
    super.key,
    required this.patient,
    required this.patientName,
  });

  @override
  State<ReqInvestigationPage> createState() => _ReqInvestigationPageState();
}

class _ReqInvestigationPageState extends State<ReqInvestigationPage> {
  final TextEditingController _packageController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchCodeController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _parameterController = TextEditingController();
  final TextEditingController _indicationsController = TextEditingController();
  final TextEditingController _totalController = TextEditingController(
    text: "0",
  );
  final TextEditingController _consultantNameController =
      TextEditingController();
  final TextEditingController _templateController = TextEditingController();

  String? _selectedLocation;
  String? _selectedJobTitle;
  Map<String, dynamic>? _selectedInvestigationType;
  String? _selectedPackage;
  bool _isUrgent = false;

  final List<Map<String, dynamic>> _investigationItems = [];
  final List<String> locations = ["AH (Nagpur)", "Other Location"];
  final List<String> jobTitles = [
    "Pathlab",
    "Radiology",
    "Cardiology",
    "Other",
  ];
  List<String> templateList = [];
  List<Map<String, dynamic>> investigationTypes = [];
  List<dynamic> parameterList = [];
  List<InvestigationLocation> _dispLocations = [];
  InvestigationLocation? _selectedDispLocation;
  bool _dispLocationsLoading = true;

  String? _tpId;
  String? _wardId;
  Map<String, dynamic>? _patientIpdData;
  Map<String, bool> selectedParameters = {};
  bool _showParameterDropdown = false;
  bool _isLoadingAmount = false;
  final bool _isLoadingJobTitles = false;
  bool _isLoadingTemplates = false;
  bool _isLoadingParameters = false;
  bool _isLoadingPatientIpdData = false;
  bool _isSubmitting = false;
  bool _isLoadingInvestigationTypes = false;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;
  bool _isListeningForPackage = false;
  bool _isListeningForInvestigationType = false;
  String _recognizedText = '';
  Timer? _speechTimeoutTimer;

  final List<Map<String, dynamic>> _recognizedTests = [];
  bool _isProcessingMultipleTests = false;
  bool _isSpeechInitialized = false;

  // AI state
  List<String> _smartSuggestions = [];
  List<String> _bundleSuggestions = [];
  String? _patientDepartment;
  int? _patientAge;

  final Map<String, int> _jobTitleToTypeId = {
    'Pathlab': 5,
    'Radiology': 7,
    'Cardiology': 20,
    'Other': 1,
  };

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _activeSnackBar;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    _selectedLocation = locations.isNotEmpty ? locations[0] : "AH (Nagpur)";
    _loadInitialData();
    _loadTemplates();
    _initSpeech();
    _loadDispLocations();
    _prepareSmartSuggestions();
  }

  // ── Smart Suggestions on load ─────────────────────────────────────────────
  void _prepareSmartSuggestions() {
    // Try to extract age if available on patient model
    try {
      final ageField = (widget.patient as dynamic).age;
      if (ageField != null) {
        _patientAge = int.tryParse(ageField.toString());
      }
    } catch (_) {}

    _smartSuggestions = InvestigationAI.suggestTests(
      department: _patientDepartment,
      gender: widget.patient.gender,
      age: _patientAge,
    );
  }

  Future<void> _loadDispLocations() async {
    try {
      final ipdService = IpdService();
      final result = await ipdService.fetchPrescriptionLocations();
      if (result['success'] == true && mounted) {
        final List<dynamic> raw = result['data'] ?? [];
        setState(() {
          _dispLocations = raw
              .map(
                (e) =>
                    InvestigationLocation.fromJson(e as Map<String, dynamic>),
              )
              .toList();
          _dispLocationsLoading = false;
          if (_dispLocations.isNotEmpty) {
            final ipd = _dispLocations.firstWhere(
              (l) => l.name.toLowerCase().contains('ipd'),
              orElse: () => _dispLocations.first,
            );
            _selectedDispLocation = ipd;
          }
        });
      } else if (mounted) {
        setState(() => _dispLocationsLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading dispensing locations: $e');
      if (mounted) setState(() => _dispLocationsLoading = false);
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (mounted) {
            setState(() {
              if (status == stt.SpeechToText.notListeningStatus) {
                _isListeningForPackage = false;
                _isListeningForInvestigationType = false;
              }
            });
          }
        },
        onError: (error) {
          debugPrint('Speech initialization error: $error');
          if (mounted) {
            setState(() {
              _speechAvailable = false;
              _isListeningForPackage = false;
              _isListeningForInvestigationType = false;
            });
            _showSnackBar(
              'Speech recognition error: $error',
              Colors.orange,
              duration: 1,
            );
          }
        },
      );
      _isSpeechInitialized = true;
      debugPrint('Speech initialized: $_speechAvailable');
    } catch (e) {
      debugPrint('Failed to initialize speech: $e');
      _speechAvailable = false;
      _isSpeechInitialized = false;
    }
  }

  void _showSnackBar(
    String message,
    Color backgroundColor, {
    int duration = 1,
  }) {
    if (_activeSnackBar != null) {
      _activeSnackBar!.close();
    }
    if (mounted) {
      _activeSnackBar = ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: duration),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 10, right: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      Future.delayed(Duration(seconds: duration), () {
        if (_activeSnackBar != null && mounted) {
          _activeSnackBar!.close();
          _activeSnackBar = null;
        }
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VOICE METHODS
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _startVoiceSearchForPackage() async {
    if (_isListeningForPackage) {
      await _stopListening();
      return;
    }
    if (!_isSpeechInitialized || !_speechAvailable) {
      await _initSpeech();
    }
    if (!_speechAvailable) {
      _showSnackBar(
        'Speech recognition is not available on this device',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    try {
      bool hasPermission = await _speech.hasPermission;
      if (!hasPermission) {
        bool permissionGranted = await _speech.initialize();
        if (!permissionGranted) {
          _showSnackBar(
            'Microphone permission is required for voice input',
            Colors.orange,
            duration: 1,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
    setState(() {
      _isListeningForPackage = true;
      _isListeningForInvestigationType = false;
      _recognizedText = '';
    });
    try {
      final options = stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() => _recognizedText = result.recognizedWords);
          _speechTimeoutTimer?.cancel();
          _speechTimeoutTimer = Timer(const Duration(seconds: 2), () {
            if (_isListeningForPackage && _recognizedText.isNotEmpty) {
              _processPackageVoiceCommand(_recognizedText);
            }
          });
          if (result.finalResult) {
            _processPackageVoiceCommand(_recognizedText);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_IN',
        listenOptions: options,
      );
      _showSnackBar(
        'Listening for package name... Speak now',
        Colors.blue,
        duration: 1,
      );
    } catch (e) {
      debugPrint('Error starting speech listening: $e');
      if (mounted) {
        setState(() => _isListeningForPackage = false);
        _showSnackBar('Failed to start listening: $e', Colors.red, duration: 1);
      }
    }
  }

  Future<void> _startVoiceSearchForInvestigationType() async {
    if (_isListeningForInvestigationType) {
      await _stopListening();
      return;
    }
    if (!_isSpeechInitialized || !_speechAvailable) {
      await _initSpeech();
    }
    if (!_speechAvailable) {
      _showSnackBar(
        'Speech recognition is not available on this device',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    if (_selectedJobTitle == null) {
      _showSnackBar(
        'Please select a job title first',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    if (investigationTypes.isEmpty) {
      _showSnackBar(
        'No investigation types loaded. Please wait or select job title again.',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    try {
      bool hasPermission = await _speech.hasPermission;
      if (!hasPermission) {
        bool permissionGranted = await _speech.initialize();
        if (!permissionGranted) {
          _showSnackBar(
            'Microphone permission is required for voice input',
            Colors.orange,
            duration: 1,
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Permission check error: $e');
    }
    setState(() {
      _isListeningForInvestigationType = true;
      _isListeningForPackage = false;
      _recognizedText = '';
    });
    try {
      final options = stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
      );
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() => _recognizedText = result.recognizedWords);
          _speechTimeoutTimer?.cancel();
          _speechTimeoutTimer = Timer(const Duration(milliseconds: 1500), () {
            if (_isListeningForInvestigationType &&
                _recognizedText.isNotEmpty) {
              _processMultipleInvestigationTypesVoiceCommand(_recognizedText);
            }
          });
          if (result.finalResult) {
            _speechTimeoutTimer?.cancel();
            _processMultipleInvestigationTypesVoiceCommand(_recognizedText);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 2),
        localeId: 'en_IN',
        listenOptions: options,
      );
      _showSnackBar(
        'Listening for multiple tests... Say test names like "CBC, KFT, Urine"',
        Colors.blue,
        duration: 1,
      );
    } catch (e) {
      debugPrint('Error starting speech listening: $e');
      if (mounted) {
        setState(() => _isListeningForInvestigationType = false);
        _showSnackBar('Failed to start listening: $e', Colors.red, duration: 1);
      }
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speech.stop();
    } catch (e) {
      debugPrint('Error stopping speech: $e');
    }
    _speechTimeoutTimer?.cancel();
    if (mounted) {
      setState(() {
        _isListeningForPackage = false;
        _isListeningForInvestigationType = false;
      });
    }
  }

  void _processPackageVoiceCommand(String text) {
    if (text.isEmpty) {
      _showSnackBar(
        'No speech detected. Please try again.',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    _stopListening();
    String cleanText = text
        .toLowerCase()
        .replaceAll('search for', '')
        .replaceAll('find', '')
        .replaceAll('package', '')
        .replaceAll('test', '')
        .replaceAll('tests', '')
        .replaceAll('investigation', '')
        .trim();
    if (cleanText.isEmpty) {
      _showSnackBar(
        'Could not recognize package name. Please try again.',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    setState(() {
      _packageController.text = cleanText;
      _selectedPackage = cleanText;
    });
    _showSnackBar('Package set to: $cleanText', Colors.green, duration: 1);
  }

  // ── Intelligent Voice NLP + Fuzzy Matching ────────────────────────────────
  Future<void> _processMultipleInvestigationTypesVoiceCommand(
    String text,
  ) async {
    if (text.isEmpty) {
      _showSnackBar(
        'No speech detected. Please try again.',
        Colors.orange,
        duration: 1,
      );
      return;
    }
    await _stopListening();
    if (!mounted) return;
    setState(() => _isProcessingMultipleTests = true);
    debugPrint('Original recognized text: "$text"');

    // NLP cleaning – supports Hindi + English mixed phrases
    String cleanText = text
        .trim()
        .replaceAll(
          RegExp(
            r'^(select|choose|add|please|karo|kar do|add karo|please add)\s+',
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(
          RegExp(
            r"\s+(that'?s it|done|thank you|thanks|bas|ho gaya)$",
            caseSensitive: false,
          ),
          '',
        )
        .replaceAll(RegExp(r'\s+and\s+', caseSensitive: false), ', ')
        .replaceAll(RegExp(r'\s+aur\s+', caseSensitive: false), ', ')
        .replaceAll(RegExp(r'\s+plus\s+', caseSensitive: false), ', ')
        .replaceAll(RegExp(r'\s+with\s+', caseSensitive: false), ', ')
        .replaceAll(RegExp(r'\s+&\s+', caseSensitive: false), ', ')
        .replaceAll(RegExp(r'[^\w\s,]', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    debugPrint('Cleaned text: "$cleanText"');

    List<String> spokenTests = [];
    if (cleanText.contains(',')) {
      spokenTests = cleanText
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 1)
          .toList();
    } else {
      List<String> words = cleanText
          .split(' ')
          .where((w) => w.length > 1)
          .toList();
      if (words.length >= 2) {
        List<String> combinedTests = [];
        int i = 0;
        while (i < words.length) {
          if (i < words.length - 1) {
            String twoWord = '${words[i]} ${words[i + 1]}';
            bool foundTwoWord = investigationTypes.any((type) {
              final typeName = (type['name'] ?? '').toString().toLowerCase();
              return typeName.contains(twoWord) ||
                  twoWord.contains(typeName.replaceAll(' ', '')) ||
                  InvestigationAI.similarity(twoWord, typeName) > 0.7;
            });
            if (foundTwoWord) {
              combinedTests.add(twoWord);
              i += 2;
              continue;
            }
          }
          combinedTests.add(words[i]);
          i++;
        }
        spokenTests = combinedTests;
      } else {
        spokenTests = words;
      }
    }
    spokenTests = spokenTests.toSet().where((test) => test.isNotEmpty).toList();

    if (spokenTests.isEmpty) {
      setState(() => _isProcessingMultipleTests = false);
      _showSnackBar(
        'Could not recognize test names. Please try again or type manually.',
        Colors.orange,
        duration: 1,
      );
      return;
    }

    List<Map<String, dynamic>> matchedTests = [];
    List<String> unmatchedTests = [];

    for (String spokenTest in spokenTests) {
      String normalizedSpoken = spokenTest.toLowerCase().trim();
      bool found = false;

      // Exact / contains match
      for (var type in investigationTypes) {
        final typeName = (type['name'] ?? '').toString().toLowerCase().trim();
        if (typeName == normalizedSpoken ||
            typeName.contains(normalizedSpoken) ||
            normalizedSpoken.contains(typeName)) {
          if (!matchedTests.any((t) => t['id'] == type['id'])) {
            matchedTests.add(type);
            found = true;
            break;
          }
        }
      }

      // Fuzzy + abbreviation match
      if (!found) {
        double bestScore = 0.0;
        Map<String, dynamic>? bestMatch;
        for (var type in investigationTypes) {
          final typeName = (type['name'] ?? '').toString().toLowerCase();
          final score = InvestigationAI.similarity(normalizedSpoken, typeName);
          final abbr = InvestigationAI.isAbbreviationMatch(
            normalizedSpoken,
            typeName,
          );
          final finalScore = abbr ? max(score, 0.92) : score;
          if (finalScore > bestScore && finalScore >= 0.65) {
            bestScore = finalScore;
            bestMatch = type;
          }
        }
        if (bestMatch != null) {
          if (!matchedTests.any((t) => t['id'] == bestMatch!['id'])) {
            matchedTests.add(bestMatch);
            found = true;
          }
        }
      }

      if (!found) unmatchedTests.add(spokenTest);
    }

    if (!mounted) return;
    setState(() => _isProcessingMultipleTests = false);

    if (matchedTests.isEmpty) {
      _showSnackBar(
        'No matching tests found for: ${spokenTests.join(", ")}',
        Colors.orange,
        duration: 2,
      );
      return;
    }

    // Voice Confirmation Bot – show confirmation with count
    _showMultiTestConfirmationDialog(matchedTests, unmatchedTests);
  }

  // ── Multi-test confirmation (with Voice Confirmation style) ───────────────
  void _showMultiTestConfirmationDialog(
    List<Map<String, dynamic>> matchedTests,
    List<String> unmatchedTests,
  ) {
    Map<int, Map<String, dynamic>> testDetails = {};
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            for (var test in matchedTests) {
              if (!testDetails.containsKey(test['id'])) {
                testDetails[test['id']] = {
                  'name': test['name'],
                  'charge': test['charge'] ?? '0',
                  'code': test['code'] ?? test['searchCode'] ?? '',
                  'parameters': '',
                  'isLoading': true,
                };
              }
            }
            _loadTestDetailsForDialog(
              matchedTests,
              testDetails,
              setDialogState,
            );
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.record_voice_over,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AI Voice: ${matchedTests.length} test(s) mil gaye',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 20,
                            color: Colors.indigo.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Confirm karke "Add All" dabayein. Duplicate tests auto-detect honge.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Found ${matchedTests.length} test(s):',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...matchedTests.asMap().entries.map((entry) {
                      int index = entry.key;
                      var test = entry.value;
                      var details = testDetails[test['id']]!;
                      bool isLoading = details['isLoading'] == true;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isLoading
                              ? Colors.grey[100]
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isLoading
                                ? Colors.grey[300]!
                                : Colors.green.shade200,
                          ),
                        ),
                        child: isLoading
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Loading ${test['name'] ?? 'test'} details...',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    radius: 16,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          test['name'] ?? '',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (details['charge'] != null &&
                                            details['charge'] != '0')
                                          Text(
                                            '₹${details['charge']}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        if (details['code'] != null &&
                                            details['code']
                                                .toString()
                                                .isNotEmpty)
                                          Text(
                                            'Code: ${details['code']}',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        matchedTests.removeAt(index);
                                        testDetails.remove(test['id']);
                                      });
                                      if (matchedTests.isEmpty) {
                                        Navigator.pop(context);
                                        _showSnackBar(
                                          'All tests removed',
                                          Colors.orange,
                                          duration: 1,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                      );
                    }).toList(),
                    if (unmatchedTests.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Could not find:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 5),
                      ...unmatchedTests.map(
                        (test) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  test,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: matchedTests.isEmpty
                      ? null
                      : () async {
                          bool allLoaded = testDetails.values.every(
                            (detail) => detail['isLoading'] == false,
                          );
                          if (!allLoaded) {
                            _showSnackBar(
                              'Please wait while we load all test details...',
                              Colors.blue,
                              duration: 1,
                            );
                            return;
                          }
                          Navigator.pop(context);
                          await _addMultipleTests(matchedTests, testDetails);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Add All (${matchedTests.length})',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _loadTestDetailsForDialog(
    List<Map<String, dynamic>> tests,
    Map<int, Map<String, dynamic>> testDetails,
    StateSetter setDialogState,
  ) async {
    for (var test in tests) {
      try {
        final details = await _getTestDetails(test);
        if (mounted) {
          setDialogState(() {
            testDetails[test['id']] = {
              'name': test['name'],
              'charge': details['charge'] ?? test['charge'] ?? '0',
              'code':
                  details['code'] ?? test['code'] ?? test['searchCode'] ?? '',
              'parameters': details['parameters'] ?? '',
              'isLoading': false,
            };
          });
        }
      } catch (e) {
        debugPrint('Error loading details for ${test['name']}: $e');
        if (mounted) {
          setDialogState(() {
            testDetails[test['id']] = {
              'name': test['name'],
              'charge': test['charge'] ?? '0',
              'code': test['code'] ?? test['searchCode'] ?? '',
              'parameters': '',
              'isLoading': false,
            };
          });
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<Map<String, dynamic>> _getTestDetails(
    Map<String, dynamic> test,
  ) async {
    try {
      final int testTypeId = test['id'] ?? 0;
      final String testTypeName = test['name'] ?? '';
      final String fallbackCharge = test['charge']?.toString() ?? '0';
      if (_tpId != null && _wardId != null && testTypeId != 0) {
        final chargeResponse = await InvestigationService.getCharge(
          tpId: _tpId!,
          investigationId: testTypeId,
          wardId: _wardId!,
          name: testTypeName,
        );
        dynamic amount =
            chargeResponse['data'] ??
            chargeResponse['charge'] ??
            chargeResponse['amount'] ??
            chargeResponse['rate'];
        if (amount == null || amount.toString() == '0') amount = fallbackCharge;
        return {
          'name': test['name'],
          'charge': amount.toString(),
          'code': test['code'] ?? test['searchCode'] ?? testTypeId.toString(),
          'parameters': '',
        };
      } else {
        final String gender = widget.patient.gender;
        final params = await InvestigationService.fetchParameterList(
          investigationTypeId: testTypeId,
          gender: gender,
        );
        String parameterString = '';
        if (params.isNotEmpty) {
          parameterString = params
              .map((p) => (p['parameterName'] ?? p['name'] ?? '').toString())
              .where((name) => name.isNotEmpty)
              .join(', ');
        }
        return {
          'name': test['name'],
          'charge': fallbackCharge,
          'code': test['code'] ?? test['searchCode'] ?? testTypeId.toString(),
          'parameters': parameterString,
        };
      }
    } catch (e) {
      debugPrint('Error getting test details: $e');
      return {
        'name': test['name'],
        'charge': test['charge']?.toString() ?? '0',
        'code':
            test['code'] ?? test['searchCode'] ?? test['id']?.toString() ?? '',
        'parameters': '',
      };
    }
  }

  // ── Duplicate Detection + Bundle Recommendation ───────────────────────────
  Future<void> _addMultipleTests(
    List<Map<String, dynamic>> tests,
    Map<int, Map<String, dynamic>> testDetails,
  ) async {
    if (!mounted) return;
    setState(() => _isProcessingMultipleTests = true);
    int addedCount = 0;
    int failedCount = 0;
    int duplicateCount = 0;

    for (var test in tests) {
      try {
        final details = testDetails[test['id']] ?? {};
        String packageName = _packageController.text.trim();
        if (packageName.isEmpty && _selectedPackage != null)
          packageName = _selectedPackage!;

        // Duplicate Detection AI
        final alreadyExists = _investigationItems.any(
          (item) =>
              item['typeId'] == test['id'] ||
              (item['type'] as String).toLowerCase() ==
                  (test['name'] ?? '').toString().toLowerCase(),
        );

        if (alreadyExists) {
          duplicateCount++;
          continue;
        }

        // Contraindication check
        final contra = InvestigationAI.checkContraindication(
          test['name']?.toString() ?? '',
          gender: widget.patient.gender,
          age: _patientAge,
        );
        if (contra != null) {
          _showSnackBar('⚠ $contra', Colors.orange, duration: 3);
        }

        String parameterString = '';
        try {
          final int testTypeId = test['id'] ?? 0;
          final String gender = widget.patient.gender;
          final params = await InvestigationService.fetchParameterList(
            investigationTypeId: testTypeId,
            gender: gender,
          );
          if (params.isNotEmpty) {
            parameterString = params
                .map((p) => (p['parameterName'] ?? p['name'] ?? '').toString())
                .where((name) => name.isNotEmpty)
                .join(', ');
          }
        } catch (e) {
          parameterString = details['parameters']?.toString() ?? '';
        }

        // Auto-Indication
        final autoInd = InvestigationAI.getIndication(
          test['name']?.toString() ?? '',
        );
        final indicationText = _indicationsController.text.trim().isNotEmpty
            ? _indicationsController.text.trim()
            : (autoInd ?? '');

        setState(() {
          _investigationItems.add({
            'package': packageName,
            'type': test['name'] ?? '',
            'typeId': test['id'] ?? 0,
            'gender': test['gender'] ?? widget.patient.gender,
            'searchCode':
                details['code']?.toString() ??
                test['code']?.toString() ??
                test['searchCode']?.toString() ??
                '',
            'amount': details['charge']?.toString() ?? '0',
            'parameter': parameterString,
            'indications': indicationText,
            'urgent': _isUrgent,
          });
        });
        addedCount++;
      } catch (e) {
        debugPrint('Error adding test ${test['name']}: $e');
        failedCount++;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }

    if (mounted) setState(() => _isProcessingMultipleTests = false);
    _updateTotal();
    _clearForm();

    String message = '';
    Color backgroundColor = Colors.green;
    if (addedCount > 0 && failedCount == 0 && duplicateCount == 0) {
      message = '$addedCount test(s) added successfully!';
    } else if (addedCount > 0) {
      message = '$addedCount added';
      if (duplicateCount > 0) message += ', $duplicateCount duplicate skipped';
      if (failedCount > 0) message += ', $failedCount failed';
      backgroundColor = Colors.orange;
    } else if (duplicateCount > 0) {
      message = 'All selected tests were already added (duplicates skipped)';
      backgroundColor = Colors.orange;
    } else {
      message = 'Failed to add tests';
      backgroundColor = Colors.red;
    }
    _showSnackBar(message, backgroundColor, duration: 2);

    // After adding, show bundle recommendation if any
    if (addedCount > 0 && tests.isNotEmpty) {
      final firstName = tests.first['name']?.toString() ?? '';
      final related = InvestigationAI.getBundle(firstName);
      if (related.isNotEmpty) {
        setState(() => _bundleSuggestions = related);
      }
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingPatientIpdData = true);
    try {
      final ipdData = await InvestigationService.fetchPatientIpdDetails(
        patientId: widget.patient.patientid,
      );
      if (ipdData != null && ipdData.isNotEmpty) {
        String? extractedTpId =
            ipdData['tpId']?.toString() ??
            ipdData['treatmentPlanId']?.toString() ??
            ipdData['tpid']?.toString();
        String? extractedWardId =
            ipdData['wardId']?.toString() ??
            ipdData['wardid']?.toString() ??
            ipdData['ward_id']?.toString();
        if (extractedTpId == 'null') extractedTpId = null;
        if (extractedWardId == 'null') extractedWardId = null;

        // Try to extract department for smart ranking
        _patientDepartment =
            ipdData['department']?.toString() ??
            ipdData['dept']?.toString() ??
            ipdData['speciality']?.toString();

        if (mounted) {
          setState(() {
            _tpId = extractedTpId;
            _wardId = extractedWardId;
            _isLoadingPatientIpdData = false;
          });
          _prepareSmartSuggestions();
        }
      } else {
        if (mounted) setState(() => _isLoadingPatientIpdData = false);
      }
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      if (mounted) setState(() => _isLoadingPatientIpdData = false);
    }
  }

  Future<void> _loadTemplates() async {
    if (!mounted) return;
    setState(() => _isLoadingTemplates = true);
    try {
      final templates =
          await InvestigationService.fetchInvestigationTemplates();
      if (mounted) {
        setState(() {
          templateList = templates;
          _isLoadingTemplates = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading templates: $e');
      if (mounted) setState(() => _isLoadingTemplates = false);
    }
  }

  Future<void> _loadInvestigationTypesForJobTitle(String jobTitle) async {
    if (jobTitle.isEmpty || !mounted) return;
    setState(() => _isLoadingInvestigationTypes = true);
    try {
      int typeId = _jobTitleToTypeId[jobTitle] ?? 1;
      final types = await InvestigationService.fetchInvestigationTypes(
        typeId: typeId,
      );

      // Smart Search Ranking
      final ranked = InvestigationAI.rankTests(
        tests: types,
        department: _patientDepartment,
        gender: widget.patient.gender,
        age: _patientAge,
      );

      if (mounted) {
        setState(() {
          investigationTypes = ranked;
          _isLoadingInvestigationTypes = false;
          _selectedInvestigationType = null;
          _amountController.clear();
          _searchCodeController.clear();
          parameterList = [];
          selectedParameters = {};
          _parameterController.clear();
          _showParameterDropdown = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading investigation types: $e');
      if (mounted) {
        setState(() {
          investigationTypes = [];
          _isLoadingInvestigationTypes = false;
          _selectedInvestigationType = null;
        });
        _showSnackBar(
          'Failed to load investigations for $jobTitle',
          Colors.red,
          duration: 1,
        );
      }
    }
  }

  Future<void> _onInvestigationTypeSelected(
    Map<String, dynamic> investigationType,
  ) async {
    if (!mounted) return;
    setState(() => _selectedInvestigationType = investigationType);

    // Auto-Indication Generator
    final autoInd = InvestigationAI.getIndication(
      investigationType['name']?.toString() ?? '',
    );
    if (autoInd != null && _indicationsController.text.trim().isEmpty) {
      _indicationsController.text = autoInd;
    }

    // Bundle Recommendation
    final related = InvestigationAI.getBundle(
      investigationType['name']?.toString() ?? '',
    );
    setState(() => _bundleSuggestions = related);

    // Contraindication Alert
    final contra = InvestigationAI.checkContraindication(
      investigationType['name']?.toString() ?? '',
      gender: widget.patient.gender,
      age: _patientAge,
    );
    if (contra != null) {
      _showSnackBar(
        '⚠ Contraindication: $contra',
        Colors.deepOrange,
        duration: 3,
      );
    }

    try {
      await Future.wait([
        _fetchChargeForInvestigation(investigationType['name']),
        _fetchParametersForInvestigationType(),
      ]);
    } catch (e) {
      debugPrint('Error in onInvestigationTypeSelected: $e');
    }
  }

  Future<void> _fetchParametersForInvestigationType() async {
    if (_selectedInvestigationType == null || !mounted) return;
    setState(() => _isLoadingParameters = true);
    try {
      final int typeId = _selectedInvestigationType!['id'] ?? 0;
      final String gender = widget.patient.gender;
      final params = await InvestigationService.fetchParameterList(
        investigationTypeId: typeId,
        gender: gender,
      );
      if (mounted) {
        setState(() {
          parameterList = params;
          selectedParameters = {
            for (var param in params)
              (param['parameterName'] ?? param['name'] ?? '').toString(): true,
          };
          _parameterController.text = _getSelectedParametersString();
          _isLoadingParameters = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching parameters: $e');
      if (mounted) {
        setState(() {
          parameterList = [];
          selectedParameters = {};
          _isLoadingParameters = false;
        });
      }
    }
  }

  Future<void> _fetchChargeForInvestigation(String investigationType) async {
    if (_isLoadingPatientIpdData)
      await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoadingAmount = true);
    try {
      final int testTypeId = _selectedInvestigationType?['id'] ?? 0;
      final String testTypeName = investigationType.isNotEmpty
          ? investigationType
          : (_selectedInvestigationType?['name'] ?? '');
      final String fallbackCharge =
          _selectedInvestigationType?['charge']?.toString() ?? '0';
      if (_tpId == null || _wardId == null || testTypeId == 0) {
        if (mounted)
          setState(() {
            _amountController.text = fallbackCharge;
            _isLoadingAmount = false;
          });
        return;
      }
      final chargeResponse = await InvestigationService.getCharge(
        tpId: _tpId!,
        investigationId: testTypeId,
        wardId: _wardId!,
        name: testTypeName,
      );
      if (mounted) {
        setState(() {
          dynamic amount =
              chargeResponse['data'] ??
              chargeResponse['charge'] ??
              chargeResponse['amount'] ??
              chargeResponse['rate'];
          if (amount == null || amount.toString() == '0')
            amount = fallbackCharge;
          _amountController.text = amount.toString();
          _isLoadingAmount = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching charge: $e');
      if (mounted) {
        setState(() {
          _amountController.text =
              _selectedInvestigationType?['charge']?.toString() ?? '0';
          _isLoadingAmount = false;
        });
      }
    }
  }

  String _getSelectedParametersString() {
    return selectedParameters.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .join(', ');
  }

  // ── Single Add with Duplicate + Contraindication ──────────────────────────
  void _addItem() {
    if (_selectedInvestigationType == null) {
      _showSnackBar(
        'Please select an Investigation Type.',
        Colors.red,
        duration: 1,
      );
      return;
    }

    // Duplicate Detection
    final alreadyExists = _investigationItems.any(
      (item) =>
          item['typeId'] == _selectedInvestigationType!['id'] ||
          (item['type'] as String).toLowerCase() ==
              (_selectedInvestigationType!['name'] ?? '')
                  .toString()
                  .toLowerCase(),
    );

    if (alreadyExists) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.copy_all, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Duplicate Detected',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            '"${_selectedInvestigationType!['name']}" is already in the request list. Add again?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _doAddItem();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
              ),
              child: Text(
                'Add Anyway',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      return;
    }

    _doAddItem();
  }

  void _doAddItem() {
    String packageName = _packageController.text.trim();
    if (packageName.isEmpty && _selectedPackage != null)
      packageName = _selectedPackage!;

    // Auto-Indication if empty
    String indication = _indicationsController.text.trim();
    if (indication.isEmpty) {
      indication =
          InvestigationAI.getIndication(
            _selectedInvestigationType!['name']?.toString() ?? '',
          ) ??
          '';
    }

    setState(() {
      _investigationItems.add({
        'package': packageName,
        'type': _selectedInvestigationType!['name'] ?? '',
        'typeId': _selectedInvestigationType!['id'] ?? 0,
        'gender': _selectedInvestigationType!['gender'] ?? '',
        'searchCode': _searchCodeController.text.trim(),
        'amount': _amountController.text.trim().isEmpty
            ? '0'
            : _amountController.text.trim(),
        'parameter': _getSelectedParametersString(),
        'indications': indication,
        'urgent': _isUrgent,
      });
      _clearForm();
      _updateTotal();
    });
    _showSnackBar('Item added successfully!', Colors.green, duration: 1);
  }

  void _clearForm() {
    _packageController.clear();
    _selectedPackage = null;
    _selectedInvestigationType = null;
    _searchCodeController.clear();
    _amountController.clear();
    _parameterController.clear();
    _indicationsController.clear();
    _isUrgent = false;
    parameterList = [];
    selectedParameters = {};
    _showParameterDropdown = false;
    // keep bundle suggestions visible for a while
  }

  void _updateTotal() {
    double total = 0;
    for (var item in _investigationItems) {
      total += double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
    }
    _totalController.text = total.toStringAsFixed(2);
  }

  void _suggestJobTitleFromTemplate(String template) {
    final lowerTemplate = template.toLowerCase();
    String? suggestedJobTitle;
    if (lowerTemplate.contains('path') ||
        lowerTemplate.contains('lab') ||
        lowerTemplate.contains('blood')) {
      suggestedJobTitle = "Pathlab";
    } else if (lowerTemplate.contains('radio') ||
        lowerTemplate.contains('x-ray') ||
        lowerTemplate.contains('scan')) {
      suggestedJobTitle = "Radiology";
    } else if (lowerTemplate.contains('cardio') ||
        lowerTemplate.contains('heart') ||
        lowerTemplate.contains('ecg')) {
      suggestedJobTitle = "Cardiology";
    }
    if (suggestedJobTitle != null &&
        jobTitles.contains(suggestedJobTitle) &&
        _selectedJobTitle != suggestedJobTitle) {
      setState(() => _selectedJobTitle = suggestedJobTitle);
      _loadInvestigationTypesForJobTitle(suggestedJobTitle);
      _showSnackBar(
        'Suggested Job Title: $suggestedJobTitle',
        Colors.teal,
        duration: 1,
      );
    }
  }

  Future<void> _submitInvestigationRequest() async {
    if (_investigationItems.isEmpty) {
      _showSnackBar(
        'Please add at least one investigation item.',
        Colors.red,
        duration: 1,
      );
      return;
    }
    if (_selectedJobTitle == null || _selectedJobTitle!.isEmpty) {
      _showSnackBar('Please select a Job Title.', Colors.red, duration: 1);
      return;
    }
    _showSubmitConfirmationDialog();
  }

  void _showSubmitConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.science_outlined,
                color: Color(0xFF1A237E),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Submit Investigation?',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The following investigations will be requested:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _investigationItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = _investigationItems[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EAF6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFC5CAE9)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 13,
                            backgroundColor: const Color(
                              0xFF1A237E,
                            ).withValues(alpha: 0.15),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Color(0xFF1A237E),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['type'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '₹${item['amount']} · ${item['urgent'] == true ? 'Urgent' : 'Normal'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: item['urgent'] == true
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_selectedDispLocation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_pharmacy_outlined,
                        size: 16,
                        color: Colors.green[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Loc: ${_selectedDispLocation!.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Total: ₹${_totalController.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeSubmit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Confirm & Submit',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executeSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final result = await InvestigationService.saveInvestigationRequest(
        patientId: widget.patient.patientid,
        jobTitle: _selectedJobTitle!,
        location: _selectedLocation ?? "AH (Nagpur)",
        consultantName: _consultantNameController.text.trim(),
        testList: _investigationItems,
        investigations: _investigationItems,
        totalAmount: _totalController.text,
        isUrgent: _isUrgent,
        tpId: _tpId,
        wardId: _wardId,
      );
      final bool isSuccess = result['success'] == true;
      final String responseMessage = result['message']?.toString() ?? '';
      if (isSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_investigation_save_time',
          DateTime.now().toIso8601String(),
        );
        await prefs.setBool('shouldRefreshNotifications', true);
        await NotificationRefreshService().markInvestigationSaved();
        String successMessage = responseMessage.isNotEmpty
            ? responseMessage
            : 'Investigation Request Submitted Successfully!';
        if (successMessage.endsWith('.'))
          successMessage = successMessage.substring(
            0,
            successMessage.length - 1,
          );
        _showSnackBar(successMessage, Colors.green, duration: 1);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          _investigationItems.clear();
          _updateTotal();
          Navigator.pop(context, true);
        }
      } else {
        String errorMessage = responseMessage.isNotEmpty
            ? responseMessage
            : 'Failed to submit investigation request';
        final lowerMessage = responseMessage.toLowerCase();
        if (lowerMessage.contains('saved successfully') ||
            lowerMessage.contains('investigation request saved')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'last_investigation_save_time',
            DateTime.now().toIso8601String(),
          );
          await prefs.setBool('shouldRefreshNotifications', true);
          await NotificationRefreshService().markInvestigationSaved();
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            _investigationItems.clear();
            _updateTotal();
            Navigator.pop(context, true);
          }
        } else {
          _showSnackBar(errorMessage, Colors.orange, duration: 1);
        }
      }
    } catch (e) {
      debugPrint('Error submitting investigation: $e');
      _showSnackBar(
        'Network error occurred while submitting',
        Colors.red,
        duration: 1,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 3),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: onChanged,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 16),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              isDense: true,
              hintText: "Enter $label",
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldContainer({required Widget child}) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  Widget _buildSelectableField({
    required String? value,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    String placeholder = "Select",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 3),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            onTap();
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: (value != null && value.isNotEmpty)
                      ? const Color(0xFF1A237E)
                      : Colors.grey[500],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (value != null && value.isNotEmpty) ? value : placeholder,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: (value != null && value.isNotEmpty)
                          ? Colors.black87
                          : Colors.grey[400],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDispLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DISPENSING LOCATION',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 3),
        GestureDetector(
          onTap: _dispLocationsLoading ? null : _showDispLocationSheet,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _dispLocationsLoading ? Colors.grey[100] : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_pharmacy_outlined,
                  color: _selectedDispLocation != null
                      ? const Color(0xFF1A237E)
                      : Colors.grey[500],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _dispLocationsLoading
                      ? Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Loading...',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _selectedDispLocation?.name ?? 'Select Location',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _selectedDispLocation != null
                                ? Colors.black87
                                : Colors.grey[400],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[500],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDispLocationSheet() {
    final suggestions = _dispLocations.length > 6
        ? _dispLocations.sublist(0, 6)
        : List<InvestigationLocation>.from(_dispLocations);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Dispensing Location',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (suggestions.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.bolt, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 6),
                    Text(
                      'Suggested',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.map((loc) {
                    final isSelected = _selectedDispLocation?.id == loc.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDispLocation = loc);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1A237E)
                              : const Color(0xFFE8EAF6),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1A237E)
                                : const Color(0xFFC5CAE9),
                          ),
                        ),
                        child: Text(
                          loc.name,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A237E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(thickness: 1, height: 1),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: Text(
                'All Locations',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: _dispLocations.isEmpty
                  ? Center(
                      child: Text(
                        'No locations available',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: _dispLocations.length,
                      itemBuilder: (_, index) {
                        final loc = _dispLocations[index];
                        final isSelected = _selectedDispLocation?.id == loc.id;
                        return ListTile(
                          visualDensity: VisualDensity.compact,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(
                                      0xFF1A237E,
                                    ).withValues(alpha: 0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_pharmacy_outlined,
                              size: 16,
                              color: isSelected
                                  ? const Color(0xFF1A237E)
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            loc.name,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF1A237E)
                                  : Colors.black87,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF1A237E),
                                  size: 18,
                                )
                              : null,
                          onTap: () {
                            setState(() => _selectedDispLocation = loc);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchableSelectionSheet({
    required String title,
    required Future<List<String>> Function(String query) searchCallback,
    required Function(String) onSelected,
    bool showMic = false,
    Function()? onMicTap,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SearchableSheetContent(
        title: title,
        searchCallback: searchCallback,
        onSelected: onSelected,
        showMic: showMic,
        onMicTap: onMicTap,
        speech: _speech,
      ),
    );
  }

  void _showInvestigationTypeSheet(List<Map<String, dynamic>> types) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        List<Map<String, dynamic>> filteredList = List.from(types);
        TextEditingController searchController = TextEditingController();
        bool isListening = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    "Select Investigation Type",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            autofocus: false,
                            style: GoogleFonts.poppins(fontSize: 14),
                            onChanged: (value) {
                              setSheetState(() {
                                filteredList = value.isEmpty
                                    ? List.from(types)
                                    : types
                                          .where(
                                            (element) => (element['name'] ?? '')
                                                .toString()
                                                .toLowerCase()
                                                .contains(value.toLowerCase()),
                                          )
                                          .toList();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: isListening
                                  ? "Listening..."
                                  : "Type to search...",
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                isListening ? Icons.mic : Icons.search,
                                color: isListening ? Colors.blue : Colors.grey,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: isListening
                              ? const Icon(Icons.stop, color: Colors.red)
                              : Icon(Icons.mic, color: Colors.blue[700]),
                          onPressed: () async {
                            if (isListening) {
                              await _speech.stop();
                              setSheetState(() => isListening = false);
                            } else {
                              if (await _speech.hasPermission) {
                                setSheetState(() => isListening = true);
                                await _speech.listen(
                                  onResult: (result) {
                                    String recognizedText =
                                        result.recognizedWords;
                                    setSheetState(() {
                                      searchController.text = recognizedText;
                                      filteredList = types
                                          .where(
                                            (element) => (element['name'] ?? '')
                                                .toString()
                                                .toLowerCase()
                                                .contains(
                                                  recognizedText.toLowerCase(),
                                                ),
                                          )
                                          .toList();
                                    });
                                  },
                                  listenFor: const Duration(seconds: 10),
                                  localeId: 'en_US',
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredList.isEmpty
                        ? Center(
                            child: Text(
                              "No investigation types found",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: filteredList.length,
                            separatorBuilder: (c, i) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final type = filteredList[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.science,
                                    color: Colors.indigo,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  type['name'] ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle:
                                    type['description']
                                            ?.toString()
                                            .isNotEmpty ==
                                        true
                                    ? Text(
                                        type['description'].toString(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : null,
                                onTap: () async {
                                  Navigator.pop(context);
                                  await _onInvestigationTypeSelected(type);
                                },
                              );
                            },
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

  void _showInvestigationListPopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setBottomState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Request List",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    "${_investigationItems.length} items",
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                ],
              ),
              if (_selectedJobTitle != null) ...[
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.work, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Category: $_selectedJobTitle',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Expanded(
                child: _investigationItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.science_outlined,
                              size: 60,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "No investigations added",
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Add investigations using the form above",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _investigationItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, index) {
                          final item = _investigationItems[index];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.indigo.withValues(
                                    alpha: 0.1,
                                  ),
                                  radius: 14,
                                  child: Text(
                                    "${index + 1}",
                                    style: const TextStyle(
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['type'] ?? '',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "₹${item['amount']} | ${item['urgent'] ? 'Urgent' : 'Normal'}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: item['urgent']
                                              ? Colors.red
                                              : Colors.grey[600],
                                          fontWeight: item['urgent']
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (item['parameter']
                                              ?.toString()
                                              .isNotEmpty ==
                                          true) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          item['parameter'].toString(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _confirmDeleteInvestigation(
                                    index,
                                    ctx,
                                    setBottomState,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteInvestigation(
    int index,
    BuildContext sheetCtx,
    StateSetter setBottomState,
  ) {
    final item = _investigationItems[index];
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Remove Investigation?',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to remove:',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['type'] ?? '',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.red[800],
                    ),
                  ),
                  Text(
                    '₹${item['amount']} · ${item['urgent'] ? 'Urgent' : 'Normal'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dCtx);
              setState(() {
                _investigationItems.removeAt(index);
                _updateTotal();
              });
              setBottomState(() {});
              _showSnackBar(
                '${item['type']} removed',
                Colors.red[700]!,
                duration: 2,
              );
              if (_investigationItems.isEmpty) Navigator.pop(sheetCtx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Remove',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Smart Suggestion Chips UI ─────────────────────────────────────────────
  Widget _buildSmartSuggestions() {
    if (_smartSuggestions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 14, color: Colors.deepPurple[400]),
            const SizedBox(width: 6),
            Text(
              'AI Suggested for this patient',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurple[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _smartSuggestions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final s = _smartSuggestions[i];
              return ActionChip(
                label: Text(s, style: GoogleFonts.poppins(fontSize: 11)),
                backgroundColor: Colors.deepPurple.shade50,
                side: BorderSide(color: Colors.deepPurple.shade100),
                onPressed: () {
                  // Try to auto-select matching investigation type if loaded
                  if (investigationTypes.isNotEmpty) {
                    final match = investigationTypes.firstWhere(
                      (t) => (t['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(s.toLowerCase()),
                      orElse: () => {},
                    );
                    if (match.isNotEmpty) {
                      _onInvestigationTypeSelected(match);
                    } else {
                      _showSnackBar(
                        'Select category first, then try again',
                        Colors.orange,
                        duration: 1,
                      );
                    }
                  } else {
                    _showSnackBar(
                      'Select a Job Title (category) first',
                      Colors.orange,
                      duration: 1,
                    );
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBundleSuggestions() {
    if (_bundleSuggestions.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.hub_outlined, size: 14, color: Colors.teal[600]),
            const SizedBox(width: 6),
            Text(
              'Recommended related tests',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.teal[700],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _bundleSuggestions = []),
              child: Icon(Icons.close, size: 16, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _bundleSuggestions.map((s) {
            return ActionChip(
              label: Text(s, style: GoogleFonts.poppins(fontSize: 11)),
              backgroundColor: Colors.teal.shade50,
              side: BorderSide(color: Colors.teal.shade100),
              onPressed: () {
                if (investigationTypes.isNotEmpty) {
                  final match = investigationTypes.firstWhere(
                    (t) => (t['name'] ?? '').toString().toLowerCase().contains(
                      s.toLowerCase(),
                    ),
                    orElse: () => {},
                  );
                  if (match.isNotEmpty) {
                    _onInvestigationTypeSelected(match);
                  } else {
                    _showSnackBar(
                      '"$s" not found in current category',
                      Colors.orange,
                      duration: 1,
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF1A237E);
    const Color bgGrey = Color(0xFFF5F7FA);
    String formattedDate = DateFormat(
      'dd MMM yyyy, hh:mm a',
    ).format(DateTime.now());
    final bool canSubmit = _investigationItems.isNotEmpty;

    return Scaffold(
      backgroundColor: bgGrey,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 5,
              left: 20,
              right: 20,
              bottom: 15,
            ),
            decoration: const BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Investigation Request",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.patientName,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Smart Suggestions ───────────────────────────────────
                  _buildSmartSuggestions(),

                  Text(
                    "INVESTIGATION CATEGORY",
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: jobTitles.length,
                      separatorBuilder: (c, i) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        bool isSelected = _selectedJobTitle == jobTitles[index];
                        return GestureDetector(
                          onTap: () {
                            final selectedTitle = jobTitles[index];
                            setState(() => _selectedJobTitle = selectedTitle);
                            _loadInvestigationTypesForJobTitle(selectedTitle);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? darkBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? darkBlue
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                jobTitles[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SEARCH PACKAGE",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 3),
                      GestureDetector(
                        onTap: () {
                          _showSearchableSelectionSheet(
                            title: "Search Package",
                            searchCallback: (query) async {
                              if (query.isEmpty) {
                                return await InvestigationService.getCachedInvestigations() ??
                                    await InvestigationService.fetchInvestigations(
                                      query: '',
                                    );
                              }
                              return await InvestigationService.fetchInvestigations(
                                query: query,
                              );
                            },
                            onSelected: (val) {
                              setState(() {
                                _packageController.text = val;
                                _selectedPackage = val;
                              });
                            },
                            showMic: true,
                            onMicTap: _startVoiceSearchForPackage,
                          );
                        },
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: _packageController.text.isNotEmpty
                                    ? darkBlue
                                    : Colors.grey[500],
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isListeningForPackage
                                      ? "Listening... $_recognizedText"
                                      : (_packageController.text.isNotEmpty
                                            ? _packageController.text
                                            : "Search Package..."),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        (_isListeningForPackage ||
                                            _packageController.text.isNotEmpty)
                                        ? Colors.black87
                                        : Colors.grey[400],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _isListeningForPackage
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.stop,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: _stopListening,
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.mic,
                                        color: Colors.blue[700],
                                        size: 18,
                                      ),
                                      onPressed: _startVoiceSearchForPackage,
                                    ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[500],
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_isListeningForPackage)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Listening... Speak clearly',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Investigation Details card ───────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Investigation Details",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: darkBlue,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Bundle recommendations
                        _buildBundleSuggestions(),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Investigation Type",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                if (_isLoadingInvestigationTypes)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                if (_isProcessingMultipleTests)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            GestureDetector(
                              onTap: _selectedJobTitle == null
                                  ? () => _showSnackBar(
                                      'Please select a Job Title first',
                                      Colors.red,
                                      duration: 1,
                                    )
                                  : () {
                                      if (investigationTypes.isNotEmpty &&
                                          !_isLoadingInvestigationTypes) {
                                        _showInvestigationTypeSheet(
                                          investigationTypes,
                                        );
                                      } else if (_isLoadingInvestigationTypes) {
                                        _showSnackBar(
                                          'Loading investigation types...',
                                          Colors.blue,
                                          duration: 1,
                                        );
                                      } else {
                                        _showSnackBar(
                                          'No investigation types available for this category',
                                          Colors.orange,
                                          duration: 1,
                                        );
                                      }
                                    },
                              child: Container(
                                height: 44,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.science,
                                      color: _selectedInvestigationType != null
                                          ? darkBlue
                                          : Colors.grey[500],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _isListeningForInvestigationType
                                            ? "Listening... $_recognizedText"
                                            : (_selectedInvestigationType?['name'] ??
                                                  (_selectedJobTitle == null
                                                      ? 'Select Job Title First'
                                                      : investigationTypes
                                                            .isEmpty
                                                      ? 'No investigations available'
                                                      : 'Select Investigation Type')),
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              (_isListeningForInvestigationType ||
                                                  _selectedInvestigationType !=
                                                      null)
                                              ? Colors.black87
                                              : Colors.grey[400],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    _isListeningForInvestigationType
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.stop,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                            onPressed: _stopListening,
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              Icons.mic,
                                              color: Colors.blue[700],
                                              size: 18,
                                            ),
                                            onPressed:
                                                _startVoiceSearchForInvestigationType,
                                          ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.grey[500],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isListeningForInvestigationType)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Listening... Say test names like "CBC, LFT aur KFT karo"',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (_selectedJobTitle != null &&
                                investigationTypes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${investigationTypes.length} investigation types available for $_selectedJobTitle (AI ranked)',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Amount + Search Code
                        Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  _buildModernInput(
                                    controller: _amountController,
                                    label: "Amount",
                                    icon: Icons.currency_rupee,
                                  ),
                                  if (_isLoadingAmount)
                                    Positioned(
                                      right: 8,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: darkBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildModernInput(
                                controller: _searchCodeController,
                                label: "Search Code",
                                icon: Icons.qr_code,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Parameters
                        GestureDetector(
                          onTap: () {
                            if (parameterList.isNotEmpty &&
                                !_isLoadingParameters) {
                              setState(
                                () => _showParameterDropdown =
                                    !_showParameterDropdown,
                              );
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Parameters",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 3),
                              _buildFieldContainer(
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: _parameterController,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.list,
                                        color: Colors.grey[500],
                                        size: 16,
                                      ),
                                      suffixIcon: _isLoadingParameters
                                          ? const Padding(
                                              padding: EdgeInsets.all(12),
                                              child: SizedBox(
                                                width: 10,
                                                height: 10,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                            )
                                          : Icon(
                                              _showParameterDropdown
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: Colors.grey,
                                              size: 18,
                                            ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      hintText: "Parameters",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 12,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 11,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_showParameterDropdown && parameterList.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              children: [
                                CheckboxListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(
                                    "Select All",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  value: selectedParameters.values.every(
                                    (v) => v,
                                  ),
                                  activeColor: darkBlue,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedParameters = {
                                        for (var p in parameterList)
                                          (p['parameterName'] ?? p['name'])
                                                  .toString():
                                              val ?? true,
                                      };
                                      _parameterController.text =
                                          _getSelectedParametersString();
                                    });
                                  },
                                ),
                                const Divider(height: 1),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 120,
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: parameterList.length,
                                    itemBuilder: (context, index) {
                                      final name =
                                          (parameterList[index]['parameterName'] ??
                                                  parameterList[index]['name'])
                                              .toString();
                                      return CheckboxListTile(
                                        dense: true,
                                        visualDensity: VisualDensity.compact,
                                        title: Text(
                                          name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                          ),
                                        ),
                                        value:
                                            selectedParameters[name] ?? false,
                                        activeColor: darkBlue,
                                        onChanged: (val) {
                                          setState(() {
                                            selectedParameters[name] =
                                                val ?? false;
                                            _parameterController.text =
                                                _getSelectedParametersString();
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 8),

                        // Indications + Urgent
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildModernInput(
                                controller: _indicationsController,
                                label: "Indications (AI auto-fill)",
                                icon: Icons.info_outline,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isUrgent = !_isUrgent),
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _isUrgent
                                        ? Colors.red[50]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _isUrgent
                                          ? Colors.red
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 16,
                                        color: _isUrgent
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Urgent",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: _isUrgent
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Dispensing location ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: _buildDispLocationField(),
                  ),

                  const SizedBox(height: 12),

                  // ── Consultant ──────────────────────────────────────
                  _buildSelectableField(
                    value: _consultantNameController.text,
                    label: "CONSULTANT",
                    icon: Icons.person_outline,
                    placeholder: "Select Consultant",
                    onTap: () {
                      _showSearchableSelectionSheet(
                        title: "Select Consultant",
                        searchCallback: (query) async {
                          if (query.isEmpty) return [];
                          String branchId =
                              (_selectedLocation ?? "AH (Nagpur)") ==
                                  "AH (Nagpur)"
                              ? "1"
                              : "2";
                          final names =
                              await InvestigationService.fetchPractitionersNames(
                                branchId: branchId,
                                specializationId: 0,
                                isVisitingConsultant: 0,
                              );
                          return names
                              .where(
                                (n) => n.toLowerCase().contains(
                                  query.toLowerCase(),
                                ),
                              )
                              .toList();
                        },
                        onSelected: (val) => setState(
                          () => _consultantNameController.text = val,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Bottom bar ─────────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add +
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  onPressed: _addItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: darkBlue,
                    side: const BorderSide(color: darkBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Add +",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // List icon
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _investigationItems.isNotEmpty
                      ? _showInvestigationListPopup
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.list, size: 18),
                      if (_investigationItems.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${_investigationItems.length}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Submit
              Expanded(
                flex: 4,
                child: ElevatedButton(
                  onPressed: (!canSubmit || _isSubmitting)
                      ? null
                      : _submitInvestigationRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit ? darkBlue : Colors.grey[300],
                    foregroundColor: canSubmit
                        ? Colors.white
                        : Colors.grey[500],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: canSubmit ? 5 : 0,
                    shadowColor: darkBlue.withValues(alpha: 0.3),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Submit",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _packageController.dispose();
    _dateController.dispose();
    _searchCodeController.dispose();
    _amountController.dispose();
    _parameterController.dispose();
    _indicationsController.dispose();
    _totalController.dispose();
    _consultantNameController.dispose();
    _templateController.dispose();
    _speechTimeoutTimer?.cancel();
    _speech.stop();
    if (_activeSnackBar != null) _activeSnackBar!.close();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Searchable sheet widget
// ─────────────────────────────────────────────────────────────────────────────
class _SearchableSheetContent extends StatefulWidget {
  final String title;
  final Future<List<String>> Function(String query) searchCallback;
  final Function(String) onSelected;
  final bool showMic;
  final Function()? onMicTap;
  final stt.SpeechToText speech;

  const _SearchableSheetContent({
    required this.title,
    required this.searchCallback,
    required this.onSelected,
    this.showMic = false,
    this.onMicTap,
    required this.speech,
  });

  @override
  State<_SearchableSheetContent> createState() =>
      _SearchableSheetContentState();
}

class _SearchableSheetContentState extends State<_SearchableSheetContent> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _results = [];
  bool _isLoading = false;
  bool _isListening = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await widget.searchCallback(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startVoiceSearchInSheet() async {
    if (_isListening) return;
    bool available = widget.speech.isAvailable;
    if (!available) {
      available = await widget.speech.initialize(
        onError: (e) => debugPrint('Sheet speech error: $e'),
      );
    }
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Speech recognition not available'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    try {
      bool hasPerm = await widget.speech.hasPermission;
      if (!hasPerm) {
        hasPerm = await widget.speech.initialize();
        if (!hasPerm) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Microphone permission required'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Sheet permission check error: $e');
    }
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });
    final options = stt.SpeechListenOptions(
      partialResults: true,
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
    try {
      await widget.speech.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _recognizedText = result.recognizedWords;
            _searchController.text = _recognizedText;
          });
          _performSearch(_recognizedText);
          if (result.finalResult) {
            setState(() => _isListening = false);
          }
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_IN',
        listenOptions: options,
      );
    } catch (e) {
      debugPrint('Sheet listen error: $e');
      if (mounted) setState(() => _isListening = false);
    }
  }

  void _stopListeningInSheet() {
    widget.speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    widget.speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            widget.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => _performSearch(val),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? "Listening..."
                          : "Type to search...",
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        _isListening ? Icons.mic : Icons.search,
                        color: _isListening ? Colors.blue : Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                if (widget.showMic && widget.onMicTap != null)
                  _isListening
                      ? IconButton(
                          icon: const Icon(Icons.stop, color: Colors.red),
                          onPressed: _stopListeningInSheet,
                        )
                      : IconButton(
                          icon: Icon(Icons.mic, color: Colors.blue[700]),
                          onPressed: _startVoiceSearchInSheet,
                        ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? Center(
                    child: Text(
                      "No results found",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _results.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _results[index],
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        onTap: () {
                          widget.onSelected(_results[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
