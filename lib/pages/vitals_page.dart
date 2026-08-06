import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:staff_mate/api/ipd_service.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// ═══════════════════════════════════════════════════════════════════════════════
// AI VITALS SERVICE – Local rule-based + statistical AI (no external API needed)
// ═══════════════════════════════════════════════════════════════════════════════

class AiVitalsService {
  static const Map<String, Map<String, dynamic>> normalRanges = {
    'temperature': {'min': 97.0, 'max': 99.5, 'criticalMin': 95.0, 'criticalMax': 103.0, 'unit': '°F'},
    'heartRate': {'min': 60, 'max': 100, 'criticalMin': 40, 'criticalMax': 140, 'unit': 'bpm'},
    'respiratoryRate': {'min': 12, 'max': 20, 'criticalMin': 8, 'criticalMax': 30, 'unit': '/min'},
    'systolicBp': {'min': 90, 'max': 140, 'criticalMin': 70, 'criticalMax': 180, 'unit': 'mmHg'},
    'diastolicBp': {'min': 60, 'max': 90, 'criticalMin': 40, 'criticalMax': 110, 'unit': 'mmHg'},
    'rbs': {'min': 70, 'max': 140, 'criticalMin': 50, 'criticalMax': 250, 'unit': 'mg/dL'},
    'spo2': {'min': 95, 'max': 100, 'criticalMin': 88, 'criticalMax': 100, 'unit': '%'},
  };

  /// Returns: normal | caution | critical
  static String getSeverity(String fieldName, double value) {
    final r = normalRanges[fieldName];
    if (r == null) return 'normal';
    final cMin = (r['criticalMin'] as num).toDouble();
    final cMax = (r['criticalMax'] as num).toDouble();
    final minV = (r['min'] as num).toDouble();
    final maxV = (r['max'] as num).toDouble();
    if (value < cMin || value > cMax) return 'critical';
    if (value < minV || value > maxV) return 'caution';
    return 'normal';
  }

  static Color severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red.shade700;
      case 'caution':
        return Colors.orange.shade700;
      default:
        return Colors.green.shade700;
    }
  }

  static IconData severityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.warning_amber_rounded;
      case 'caution':
        return Icons.info_outline;
      default:
        return Icons.check_circle_outline;
    }
  }

  /// AI Health Score 0–100 (higher = better)
  static int calculateHealthScore(Map<String, double> vitals) {
    if (vitals.isEmpty) return 0;
    double total = 0;
    int count = 0;
    vitals.forEach((key, value) {
      final r = normalRanges[key];
      if (r == null) return;
      final minV = (r['min'] as num).toDouble();
      final maxV = (r['max'] as num).toDouble();
      final mid = (minV + maxV) / 2.0;
      final halfRange = (maxV - minV) / 2.0;
      final safeRange = halfRange == 0 ? 1.0 : halfRange;
      final deviation = (value - mid).abs() / safeRange;
      double score = math.max(0.0, 100.0 - (deviation * 40));
      final sev = getSeverity(key, value);
      if (sev == 'critical') score = math.min(score, 30.0);
      if (sev == 'caution') score = math.min(score, 65.0);
      total += score;
      count++;
    });
    return count == 0 ? 0 : (total / count).round().clamp(0, 100);
  }

  static String healthScoreLabel(int score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    if (score >= 30) return 'Poor';
    return 'Critical';
  }

  static Color healthScoreColor(int score) {
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    if (score >= 30) return Colors.deepOrange;
    return Colors.red;
  }

  /// Generate AI suggestions based on current vitals
  static List<String> generateSuggestions(Map<String, double> vitals) {
    final List<String> suggestions = [];
    vitals.forEach((key, value) {
      final sev = getSeverity(key, value);
      if (sev == 'normal') return;
      switch (key) {
        case 'temperature':
          if (value > 100.4) {
            suggestions.add('🌡️ Fever detected ($value°F). Consider antipyretics & hydration. Re-check in 1–2 hrs.');
          } else if (value < 96) {
            suggestions.add('❄️ Hypothermia risk ($value°F). Warm patient, monitor continuously.');
          }
          break;
        case 'heartRate':
          if (value > 100) {
            suggestions.add('❤️ Tachycardia ($value bpm). Check pain, fever, anxiety, dehydration.');
          } else if (value < 50) {
            suggestions.add('❤️ Bradycardia ($value bpm). Assess medications (beta-blockers) & cardiac status.');
          }
          break;
        case 'respiratoryRate':
          if (value > 24) {
            suggestions.add('🫁 Tachypnea ($value/min). Assess SpO2, lung sounds, possible distress.');
          } else if (value < 10) {
            suggestions.add('🫁 Bradypnea ($value/min). Check opioid use / CNS depression.');
          }
          break;
        case 'systolicBp':
          if (value > 160) {
            suggestions.add('🩸 High Systolic BP ($value). Recheck, assess pain/anxiety, notify doctor if sustained.');
          } else if (value < 90) {
            suggestions.add('🩸 Hypotension ($value). Check volume status, sepsis, bleeding.');
          }
          break;
        case 'diastolicBp':
          if (value > 100) {
            suggestions.add('🩸 Elevated Diastolic ($value). Monitor for hypertensive urgency.');
          }
          break;
        case 'spo2':
          if (value < 92) {
            suggestions.add('💨 Low SpO2 ($value%). Apply O2, check airway, call rapid response if <88%.');
          } else if (value < 95) {
            suggestions.add('💨 Borderline SpO2 ($value%). Encourage deep breathing, recheck.');
          }
          break;
        case 'rbs':
          if (value > 200) {
            suggestions.add('🩸 Hyperglycemia ($value mg/dL). Check for ketones if diabetic, inform physician.');
          } else if (value < 70) {
            suggestions.add('🩸 Hypoglycemia ($value mg/dL). Give glucose immediately if symptomatic.');
          }
          break;
      }
    });
    if (suggestions.isEmpty) {
      suggestions.add('✅ All recorded vitals are within acceptable ranges. Continue routine monitoring.');
    }
    return suggestions;
  }

  /// AI chat response (rule-based assistant)
  static String chatReply(String userMessage, Map<String, double> currentVitals) {
    final msg = userMessage.toLowerCase().trim();
    if (msg.contains('score') || msg.contains('health')) {
      final score = calculateHealthScore(currentVitals);
      return 'AI Health Score: $score/100 (${healthScoreLabel(score)}).\n'
          'Based on ${currentVitals.length} vital(s) currently entered.';
    }
    if (msg.contains('suggest') || msg.contains('advice') || msg.contains('what should')) {
      final s = generateSuggestions(currentVitals);
      return s.join('\n\n');
    }
    if (msg.contains('abnormal') || msg.contains('alert') || msg.contains('critical')) {
      final alerts = <String>[];
      currentVitals.forEach((k, v) {
        final sev = getSeverity(k, v);
        if (sev != 'normal') {
          alerts.add('• ${k.toUpperCase()}: $v → ${sev.toUpperCase()}');
        }
      });
      return alerts.isEmpty
          ? 'No abnormal vitals detected right now.'
          : 'Abnormal findings:\n${alerts.join('\n')}';
    }
    if (msg.contains('temp') || msg.contains('fever')) {
      final t = currentVitals['temperature'];
      if (t == null) return 'Temperature not entered yet. Please record it first.';
      return 'Temperature: $t°F → ${getSeverity('temperature', t).toUpperCase()}. '
          '${t > 100.4 ? "Fever present." : t < 97 ? "Below normal." : "Within normal range."}';
    }
    if (msg.contains('bp') || msg.contains('blood pressure')) {
      final s = currentVitals['systolicBp'];
      final d = currentVitals['diastolicBp'];
      if (s == null && d == null) return 'BP not entered yet.';
      return 'BP: ${s ?? "--"}/${d ?? "--"} mmHg. '
          'Sys: ${s != null ? getSeverity('systolicBp', s) : "N/A"}, '
          'Dia: ${d != null ? getSeverity('diastolicBp', d) : "N/A"}';
    }
    if (msg.contains('spo2') || msg.contains('oxygen')) {
      final o = currentVitals['spo2'];
      if (o == null) return 'SpO2 not entered yet.';
      return 'SpO2: $o% → ${getSeverity('spo2', o).toUpperCase()}.';
    }
    if (msg.contains('help') || msg.contains('how')) {
      return 'I can help with:\n'
          '• "health score" – overall score\n'
          '• "suggestions" – clinical tips\n'
          '• "abnormal" – list alerts\n'
          '• "temp / bp / spo2" – specific vital analysis';
    }
    return 'I am your AI Vitals Assistant.\n'
        'Try: "health score", "suggestions", "any abnormal?", or ask about a specific vital.';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SMART NLP VOICE PARSER – Understands natural language for vitals
// ═══════════════════════════════════════════════════════════════════════════════

class SmartVoiceParser {
  /// Extract all possible vitals from a single spoken sentence
  static Map<String, String> parseAll(String text) {
    final result = <String, String>{};
    final t = text.toLowerCase().trim();

    // Temperature
    final tempMatch = RegExp(
      r'(?:temp(?:erature)?|fever)\s*(?:is|of|=|:)?\s*(\d{2,3}(?:\.\d)?)',
    ).firstMatch(t);
    if (tempMatch != null) {
      result['temperature'] = tempMatch.group(1)!;
    } else {
      final pure = RegExp(r'\b(9[0-9](?:\.\d)?|1[0-1][0-9](?:\.\d)?)\b').firstMatch(t);
      // Only assign pure number if context suggests temp (handled by step)
    }

    // Heart rate
    final hrMatch = RegExp(
      r'(?:heart\s*rate|hr|pulse)\s*(?:is|of|=|:)?\s*(\d{2,3})',
    ).firstMatch(t);
    if (hrMatch != null) result['heartRate'] = hrMatch.group(1)!;

    // BP 120/80 or 120 over 80
    final bpMatch = RegExp(
      r'(?:bp|blood\s*pressure)?\s*(\d{2,3})\s*(?:/|over|by)\s*(\d{2,3})',
    ).firstMatch(t);
    if (bpMatch != null) {
      result['systolicBp'] = bpMatch.group(1)!;
      result['diastolicBp'] = bpMatch.group(2)!;
    }

    // Respiratory rate
    final rrMatch = RegExp(
      r'(?:resp(?:iratory)?\s*rate|rr|breath(?:ing)?)\s*(?:is|of|=|:)?\s*(\d{1,2})',
    ).firstMatch(t);
    if (rrMatch != null) result['respiratoryRate'] = rrMatch.group(1)!;

    // SpO2
    final spo2Match = RegExp(
      r'(?:spo2|oxygen|o2\s*sat(?:uration)?)\s*(?:is|of|=|:)?\s*(\d{2,3})',
    ).firstMatch(t);
    if (spo2Match != null) result['spo2'] = spo2Match.group(1)!;

    // RBS / Blood sugar
    final rbsMatch = RegExp(
      r'(?:rbs|blood\s*sugar|glucose|sugar)\s*(?:is|of|=|:)?\s*(\d{2,3})',
    ).firstMatch(t);
    if (rbsMatch != null) result['rbs'] = rbsMatch.group(1)!;

    return result;
  }

  /// Extract a single numeric value (for step-by-step mode)
  static String? extractNumber(String text) {
    try {
      text = text.toLowerCase().trim();
      final digitMatch = RegExp(r'\d+(\.\d+)?').firstMatch(text);
      if (digitMatch != null) return digitMatch.group(0);

      text = text.replaceAll('point', '.').replaceAll('dot', '.');
      final Map<String, int> words = {
        'zero': 0, 'one': 1, 'two': 2, 'three': 3, 'four': 4,
        'five': 5, 'six': 6, 'seven': 7, 'eight': 8, 'nine': 9,
        'ten': 10, 'eleven': 11, 'twelve': 12, 'thirteen': 13,
        'fourteen': 14, 'fifteen': 15, 'sixteen': 16, 'seventeen': 17,
        'eighteen': 18, 'nineteen': 19, 'twenty': 20, 'thirty': 30,
        'forty': 40, 'fifty': 50, 'sixty': 60, 'seventy': 70,
        'eighty': 80, 'ninety': 90, 'hundred': 100,
      };
      final parts = text.split(RegExp(r'\s+'));
      double current = 0;
      bool isDecimal = false;
      String decimalPart = '';
      bool found = false;
      for (final w in parts) {
        if (w == '.') {
          isDecimal = true;
          continue;
        }
        if (words.containsKey(w)) {
          found = true;
          final val = words[w]!;
          if (isDecimal) {
            decimalPart += val.toString();
          } else {
            if (val == 100) {
              current = current == 0 ? 100 : current * 100;
            } else {
              current += val;
            }
          }
        }
      }
      if (found) {
        String res = current.toInt().toString();
        if (decimalPart.isNotEmpty) res += '.$decimalPart';
        return res;
      }
    } catch (_) {}
    return null;
  }

  static bool isSkip(String text) {
    final skip = ['skip', 'next', 'no', 'not needed', 'not required', 'pass', 'none'];
    return skip.contains(text.toLowerCase().trim());
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN PAGE
// ═══════════════════════════════════════════════════════════════════════════════

class VitalsPage extends StatefulWidget {
  final Patient patient;
  const VitalsPage({super.key, required this.patient});

  @override
  State<VitalsPage> createState() => _VitalsPageState();
}

class _VitalsPageState extends State<VitalsPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController!.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Capture Vitals & Intake',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(widget.patient.patientname,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400)),
            const SizedBox(height: 2),
            Text('IPD: ${widget.patient.ipdNo} | Ward: ${widget.patient.ward}',
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w400)),
          ],
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController!,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: const Color(0xFF1A237E),
                unselectedLabelColor: Colors.white.withOpacity(0.8),
                labelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'VITAL SIGNS'),
                  Tab(text: 'INTAKE OUTPUT'),
                ],
                labelPadding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          VitalsTab(patient: widget.patient),
          IntakeAssessmentTab(patient: widget.patient),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// VITALS TAB (with AI)
// ═══════════════════════════════════════════════════════════════════════════════

class VitalsTab extends StatefulWidget {
  final Patient patient;
  const VitalsTab({super.key, required this.patient});

  @override
  State<VitalsTab> createState() => _VitalsTabState();
}

class _VitalsTabState extends State<VitalsTab> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _hrController = TextEditingController();
  final TextEditingController _rrController = TextEditingController();
  final TextEditingController _sysBpController = TextEditingController();
  final TextEditingController _diaBpController = TextEditingController();
  final TextEditingController _rbsController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();

  final Map<String, String?> _fieldErrors = {
    'temperature': null,
    'heartRate': null,
    'respiratoryRate': null,
    'systolicBp': null,
    'diastolicBp': null,
    'rbs': null,
    'spo2': null,
  };

  final Map<String, String> _fieldSeverity = {};

  final List<FocusNode> _focusNodes = List.generate(7, (_) => FocusNode());
  int _currentFieldIndex = 0;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';

  String _selectedHH = '00';
  String _selectedMM = '00';
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _vitalsMasterData = [];
  final IpdService _ipdService = IpdService();

  static const Color darkBlue = Color(0xFF1A237E);
  final Color bgGrey = const Color(0xFFF5F7FA);

  // Voice overlay state
  bool _showVoiceOverlay = false;
  String _voiceInstruction = 'Please speak Temperature';
  int _currentVoiceStep = 0;
  List<String> _voiceSteps = [];
  final Map<int, String> _voiceCollectedValues = {};
  bool _isProcessingVoice = false;
  bool _isVoiceInputComplete = false;

  // AI state
  int _healthScore = 0;
  List<String> _aiSuggestions = [];
  bool _showAiPanel = false;
  bool _showAiChat = false;
  final TextEditingController _aiChatController = TextEditingController();
  final List<Map<String, String>> _aiChatMessages = [];

  final List<Map<String, dynamic>> _vitalPatterns = [
    {'label': 'Temperature', 'controllerIndex': 0, 'hint': '98.6', 'suffix': '°F', 'id': '1', 'fieldName': 'temperature'},
    {'label': 'Heart Rate', 'controllerIndex': 1, 'hint': '72', 'suffix': 'bpm', 'id': '2', 'fieldName': 'heartRate'},
    {'label': 'Systolic BP', 'controllerIndex': 2, 'hint': '120', 'suffix': 'mmHg', 'id': '4', 'fieldName': 'systolicBp'},
    {'label': 'Diastolic BP', 'controllerIndex': 3, 'hint': '80', 'suffix': 'mmHg', 'id': '5', 'fieldName': 'diastolicBp'},
    {'label': 'Respiratory Rate', 'controllerIndex': 4, 'hint': '18', 'suffix': '/min', 'id': '3', 'fieldName': 'respiratoryRate'},
    {'label': 'SpO2', 'controllerIndex': 5, 'hint': '98', 'suffix': '%', 'id': '13', 'fieldName': 'spo2'},
    {'label': 'RBS', 'controllerIndex': 6, 'hint': '100', 'suffix': 'mg/dL', 'id': '6', 'fieldName': 'rbs'},
  ];

  final Map<String, Map<String, dynamic>> _vitalRanges = {
    'temperature': {'min': 90.0, 'max': 110.0, 'unit': '°F'},
    'heartRate': {'min': 30, 'max': 200, 'unit': 'bpm'},
    'respiratoryRate': {'min': 6, 'max': 60, 'unit': '/min'},
    'systolicBp': {'min': 70, 'max': 250, 'unit': 'mmHg'},
    'diastolicBp': {'min': 40, 'max': 150, 'unit': 'mmHg'},
    'rbs': {'min': 20, 'max': 600, 'unit': 'mg/dL'},
    'spo2': {'min': 70, 'max': 100, 'unit': '%'},
  };

  TextEditingController _ctrlFor(int index) {
    switch (index) {
      case 0: return _tempController;
      case 1: return _hrController;
      case 2: return _sysBpController;
      case 3: return _diaBpController;
      case 4: return _rrController;
      case 5: return _spo2Controller;
      case 6: return _rbsController;
      default: return _tempController;
    }
  }

  /// Hot-reload safe: never rely on controllers stored inside maps
  List<String> get _safeVoiceSteps {
    if (_voiceSteps.isNotEmpty) return _voiceSteps;
    return _vitalPatterns.map((v) => v['label'] as String).toList();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
    _selectedHH = DateFormat('HH').format(now);
    _selectedMM = DateFormat('mm').format(now);

    // Controllers are accessed via _ctrlFor only — do not put them in maps
    _voiceSteps = _vitalPatterns.map((v) => v['label'] as String).toList();

    _loadVitalsMasterData();
    _initSpeech();

    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) setState(() => _currentFieldIndex = i);
      });
    }

    for (final c in [
      _tempController, _hrController, _rrController,
      _sysBpController, _diaBpController, _rbsController, _spo2Controller
    ]) {
      c.addListener(_recalculateAi);
    }
  }

  @override
  void dispose() {
    for (var n in _focusNodes) n.dispose();
    _aiChatController.dispose();
    super.dispose();
  }

  Map<String, double> _currentVitalsMap() {
    final m = <String, double>{};
    void add(String key, TextEditingController c) {
      if (c.text.isNotEmpty) {
        final v = double.tryParse(c.text);
        if (v != null) m[key] = v;
      }
    }
    add('temperature', _tempController);
    add('heartRate', _hrController);
    add('respiratoryRate', _rrController);
    add('systolicBp', _sysBpController);
    add('diastolicBp', _diaBpController);
    add('rbs', _rbsController);
    add('spo2', _spo2Controller);
    return m;
  }

  void _recalculateAi() {
    try {
      final vitals = _currentVitalsMap();
      final score = AiVitalsService.calculateHealthScore(vitals);
      final suggestions = AiVitalsService.generateSuggestions(vitals);
      final sev = <String, String>{};
      vitals.forEach((k, v) {
        sev[k] = AiVitalsService.getSeverity(k, v);
      });
      if (mounted) {
        setState(() {
          _healthScore = score;
          _aiSuggestions = suggestions;
          _fieldSeverity
            ..clear()
            ..addAll(sev);
        });
      }
    } catch (e) {
      debugPrint('AI recalculate error: $e');
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
            if (_showVoiceOverlay && !_isProcessingVoice && !_isVoiceInputComplete && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_showVoiceOverlay && !_isVoiceInputComplete && mounted && !_isListening) {
                  _startVoiceListening();
                }
              });
            }
          }
        },
        onError: (error) {
          debugPrint('Speech error: $error');
          if (mounted) setState(() => _isListening = false);
          _retrySpeechListening();
        },
      );
    } catch (e) {
      debugPrint('Speech init error: $e');
      _speechAvailable = false;
    }
  }

  void _retrySpeechListening() {
    if (_showVoiceOverlay && !_isVoiceInputComplete && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_showVoiceOverlay && !_isVoiceInputComplete && mounted) {
          _startVoiceListening();
        }
      });
    }
  }

  void _startVoiceInput() async {
    // Re-initialize if not yet available
    if (!_speechAvailable) {
      await _initSpeech();
    }
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Speech recognition is not available on this device'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ));
      }
      return;
    }

    try {
      bool hasPerm = await _speech.hasPermission;
      if (!hasPerm) {
        bool initialized = await _speech.initialize();
        if (!initialized) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please enable microphone permission from settings'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ));
          }
          return;
        }
      }
    } catch (e) {
      debugPrint('Permission check error in vitals: $e');
    }
    _startVoiceSequence();
  }

  void _startVoiceSequence() {
    // Ensure steps are populated (hot-reload safe)
    if (_voiceSteps.isEmpty) {
      _voiceSteps = _vitalPatterns.map((v) => v['label'] as String).toList();
    }
    final steps = _safeVoiceSteps;
    setState(() {
      _showVoiceOverlay = true;
      _currentVoiceStep = 0;
      _voiceCollectedValues.clear();
      _isProcessingVoice = false;
      _isVoiceInputComplete = false;
      _voiceInstruction = steps.isEmpty
          ? 'Please speak value or say "Skip"'
          : 'Please speak ${steps[0]} or say "Skip"';
      _recognizedText = '';
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _showVoiceOverlay) _startVoiceListening();
    });
  }

  void _hideVoiceOverlay() {
    setState(() {
      _showVoiceOverlay = false;
      _isListening = false;
      _isProcessingVoice = false;
      _isVoiceInputComplete = false;
    });
    _speech.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_voiceCollectedValues.isNotEmpty && mounted) {
        final firstKey = _voiceCollectedValues.keys.first;
        if (firstKey < _focusNodes.length) {
          setState(() => _currentFieldIndex = firstKey);
          _focusNodes[firstKey].requestFocus();
        }
      }
    });
  }

  Future<void> _startVoiceListening() async {
    if (_isListening || _isProcessingVoice || _isVoiceInputComplete) return;
    if (_speech.isListening) {
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    final steps = _safeVoiceSteps;
    final label = (_currentVoiceStep < steps.length) ? steps[_currentVoiceStep] : 'value';
    setState(() {
      _isListening = true;
      _recognizedText = '';
      _voiceInstruction = 'Listening... Speak $label or say "Skip"';
    });
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords);
          if (result.finalResult) {
            _processVoiceInputForCurrentStep(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_IN',
      );
    } catch (e) {
      debugPrint('Listen error: $e');
      if (mounted) setState(() => _isListening = false);
      _retrySpeechListening();
    }
  }

  void _processVoiceInputForCurrentStep(String text) {
    if (text.isEmpty || _isProcessingVoice) return;
    setState(() {
      _isProcessingVoice = true;
      _isListening = false;
    });

    if (SmartVoiceParser.isSkip(text)) {
      _skipCurrentField();
      return;
    }

    // Try NLP multi-parse first (e.g. user said "bp 120 over 80")
    final multi = SmartVoiceParser.parseAll(text);
    if (multi.isNotEmpty) {
      multi.forEach((field, value) {
        final idx = _vitalPatterns.indexWhere((p) => p['fieldName'] == field);
        if (idx >= 0) {
          final validation = _validateVoiceInput(idx, value);
          if (validation['isValid'] == true) {
            _voiceCollectedValues[idx] = value;
            _updateFieldWithValue(idx, value);
          }
        }
      });
      // If current step was filled, move on
      if (_voiceCollectedValues.containsKey(_currentVoiceStep)) {
        _showVoiceStepSuccess(_voiceCollectedValues[_currentVoiceStep]!);
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted && _showVoiceOverlay) _moveToNextVoiceStep();
        });
        return;
      }
    }

    final value = SmartVoiceParser.extractNumber(text);
    if (value != null) {
      final validation = _validateVoiceInput(_currentVoiceStep, value);
      if (validation['isValid'] == true) {
        _voiceCollectedValues[_currentVoiceStep] = value;
        _updateFieldWithValue(_currentVoiceStep, value);
        _showVoiceStepSuccess(value);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted && _showVoiceOverlay) _moveToNextVoiceStep();
        });
      } else {
        final err = validation['message'] as String? ?? 'Out of range';
        _showValidationError(err);
        setState(() {
          _voiceInstruction = err;
          _recognizedText = '';
          _isProcessingVoice = false;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _showVoiceOverlay) _startVoiceListening();
        });
      }
    } else {
      final steps = _safeVoiceSteps;
      final label = (_currentVoiceStep < steps.length) ? steps[_currentVoiceStep] : 'value';
      setState(() {
        _voiceInstruction =
            'Could not understand. Please say $label or "Skip". Example: "98.6"';
        _recognizedText = '';
        _isProcessingVoice = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _showVoiceOverlay) _startVoiceListening();
      });
    }
  }

  Map<String, dynamic> _validateVoiceInput(int stepIndex, String value) {
    if (stepIndex < 0 || stepIndex >= _vitalPatterns.length) {
      return {'isValid': false, 'message': 'Invalid field'};
    }
    final fieldName = _vitalPatterns[stepIndex]['fieldName'] as String? ?? '';
    final range = _vitalRanges[fieldName];
    if (range == null) return {'isValid': true};
    final numValue = double.tryParse(value);
    if (numValue == null) return {'isValid': false, 'message': 'Please speak a valid number'};
    if (numValue < range['min'] || numValue > range['max']) {
      return {
        'isValid': false,
        'message': 'Please select in range (${range['min']}-${range['max']})',
      };
    }
    return {'isValid': true};
  }

  void _showValidationError(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _skipCurrentField() {
    _showSkipSuccess();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _showVoiceOverlay) _moveToNextVoiceStep();
    });
  }

  void _showSkipSuccess() {
    final steps = _safeVoiceSteps;
    final current = (_currentVoiceStep < steps.length) ? steps[_currentVoiceStep] : 'Field';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$current skipped'),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 1),
    ));
    setState(() => _voiceInstruction = '$current skipped. Moving to next...');
  }

  void _updateFieldWithValue(int stepIndex, String value) {
    // Always use _ctrlFor — never read controller from map (hot-reload safe)
    if (stepIndex < 0 || stepIndex > 6) return;
    final controller = _ctrlFor(stepIndex);
    if (mounted) setState(() => controller.text = value);
  }

  void _showVoiceStepSuccess(String value) {
    final steps = _safeVoiceSteps;
    if (_currentVoiceStep >= steps.length) return;
    final current = steps[_currentVoiceStep];
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$current: $value recorded'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 1),
    ));
  }

  void _moveToNextVoiceStep() {
    final steps = _safeVoiceSteps;
    if (_currentVoiceStep < steps.length - 1) {
      setState(() {
        _currentVoiceStep++;
        _isProcessingVoice = false;
        _recognizedText = '';
        _voiceInstruction = 'Please speak ${steps[_currentVoiceStep]} or say "Skip"';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _showVoiceOverlay) _startVoiceListening();
      });
    } else {
      _completeVoiceInput();
    }
  }

  void _moveToPreviousVoiceStep() {
    final steps = _safeVoiceSteps;
    if (_currentVoiceStep > 0) {
      final clearIndex = _currentVoiceStep;
      setState(() {
        _currentVoiceStep--;
        _isProcessingVoice = false;
        _recognizedText = '';
        _voiceInstruction = 'Please speak ${steps[_currentVoiceStep]} or say "Skip"';
      });
      _voiceCollectedValues.remove(clearIndex);
      if (clearIndex >= 0 && clearIndex <= 6) {
        final controller = _ctrlFor(clearIndex);
        if (mounted) setState(() => controller.text = '');
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _showVoiceOverlay) _startVoiceListening();
      });
    }
  }

  void _completeVoiceInput() {
    setState(() {
      _isVoiceInputComplete = true;
      _voiceInstruction = 'Voice input complete!';
      _isListening = false;
    });
    _speech.stop();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showVoiceInputComplete();
    });
  }

  void _showVoiceInputComplete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text('Voice Input Complete!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: darkBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Successfully recorded ${_voiceCollectedValues.length} vital signs:',
                style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 8),
            ..._voiceCollectedValues.entries.map((e) {
              final steps = _safeVoiceSteps;
              final name = (e.key < steps.length) ? steps[e.key] : 'Field ${e.key + 1}';
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text('$name: ${e.value}', style: GoogleFonts.poppins(fontSize: 13)),
                ]),
              );
            }),
            const SizedBox(height: 8),
            Text('Tap "Edit Values" to edit manually or "OK" to continue.',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hideVoiceOverlay();
            },
            child: Text('Edit Values', style: GoogleFonts.poppins(color: darkBlue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hideVoiceOverlay();
            },
            child: Text('OK', style: GoogleFonts.poppins(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadVitalsMasterData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _ipdService.fetchVitalsMasterData();
      if (response['success'] == true) {
        final rawList = response['data'];
        final List<dynamic> masterData =
            (rawList is List) ? List<dynamic>.from(rawList) : <dynamic>[];
        // Web JSON often returns Map<dynamic,dynamic> — always re-cast
        _vitalsMasterData = masterData
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else {
        setState(() =>
            _errorMessage = response['message']?.toString() ?? 'Failed to load vitals data');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error loading vitals data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getVitalHint(String vitalId) {
    if (_vitalsMasterData.isEmpty) return '(0-0)';
    try {
      for (final raw in _vitalsMasterData) {
        if (raw is! Map) continue;
        final vital = Map<String, dynamic>.from(raw);
        final id = vital['id']?.toString() ?? '';
        if (id == vitalId) {
          final min = vital['min_value_f']?.toString() ?? '0';
          final max = vital['max_value_f']?.toString() ?? '0';
          return '($min-$max)';
        }
      }
    } catch (_) {}
    return '(0-0)';
  }

  Future<void> _onSaveVitals() async {
    setState(() => _errorMessage = null);
    if (_dateController.text.isEmpty) {
      setState(() => _errorMessage = 'Please select a date');
      return;
    }
    bool allEmpty = _tempController.text.isEmpty &&
        _hrController.text.isEmpty &&
        _rrController.text.isEmpty &&
        _sysBpController.text.isEmpty &&
        _diaBpController.text.isEmpty &&
        _rbsController.text.isEmpty &&
        _spo2Controller.text.isEmpty;
    if (allEmpty) {
      setState(() => _errorMessage = 'Please enter at least one vital sign');
      return;
    }

    String admissionId = widget.patient.admissionId.toString();
    if (admissionId.isEmpty || admissionId == '0') {
      final prefs = await SharedPreferences.getInstance();
      admissionId = prefs.getString('admissionid') ?? '';
    }
    if (admissionId.isEmpty || admissionId == '0') {
      setState(() => _errorMessage = 'Valid Admission ID not found. Please refresh patient data.');
      return;
    }

    String patientId = widget.patient.patientId.toString();
    if (patientId.isEmpty) patientId = widget.patient.id.toString();
    if (patientId.isEmpty) {
      setState(() => _errorMessage = 'Patient ID not found in patient data.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final vitalEntries = _prepareVitalEntries();
      if (vitalEntries.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter at least one vital sign';
          _isLoading = false;
        });
        return;
      }
      final response = await _ipdService.savePatientVitals(
        patientId: patientId,
        admissionId: admissionId,
        date: _dateController.text,
        time: '$_selectedHH:$_selectedMM',
        vitalEntries: vitalEntries,
      );
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['message'] ?? 'Vitals saved successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ));
          Navigator.pop(context);
        }
      } else {
        setState(() => _errorMessage = response['message'] ?? 'Failed to save vitals.');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _prepareVitalEntries() {
    final entries = <Map<String, dynamic>>[];
    if (_tempController.text.isNotEmpty) entries.add({'vitalMasterId': 1, 'finding': _tempController.text});
    if (_hrController.text.isNotEmpty) entries.add({'vitalMasterId': 2, 'finding': _hrController.text});
    if (_rrController.text.isNotEmpty) entries.add({'vitalMasterId': 3, 'finding': _rrController.text});
    if (_sysBpController.text.isNotEmpty) entries.add({'vitalMasterId': 4, 'finding': _sysBpController.text});
    if (_diaBpController.text.isNotEmpty) entries.add({'vitalMasterId': 5, 'finding': _diaBpController.text});
    if (_rbsController.text.isNotEmpty) entries.add({'vitalMasterId': 6, 'finding': _rbsController.text});
    if (_spo2Controller.text.isNotEmpty) entries.add({'vitalMasterId': 13, 'finding': _spo2Controller.text});
    return entries;
  }

  void _validateManualInput(String fieldName, String value) {
    if (value.isEmpty) {
      setState(() => _fieldErrors[fieldName] = null);
      return;
    }
    final range = _vitalRanges[fieldName];
    if (range == null) return;
    final numValue = double.tryParse(value);
    if (numValue == null) {
      setState(() => _fieldErrors[fieldName] = 'Please enter a valid number');
      return;
    }
    if (numValue < range['min'] || numValue > range['max']) {
      setState(() => _fieldErrors[fieldName] = 'Please select in range (${range['min']}-${range['max']})');
    } else {
      setState(() => _fieldErrors[fieldName] = null);
    }
  }

  void _sendAiChat() {
    final text = _aiChatController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _aiChatMessages.add({'role': 'user', 'text': text});
      _aiChatController.clear();
    });
    final reply = AiVitalsService.chatReply(text, _currentVitalsMap());
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _aiChatMessages.add({'role': 'ai', 'text': reply}));
      }
    });
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 11))),
                  ]),
                ),

              // ── AI Health Score Card ──
              if (_currentVitalsMap().isNotEmpty) _buildAiHealthCard(),

              _buildSectionHeader('Date & Time'),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (ctx, child) => Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(primary: darkBlue),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null && mounted) {
                                setState(() =>
                                    _dateController.text = DateFormat('yyyy-MM-dd').format(picked));
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgGrey,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_month, color: darkBlue, size: 14),
                          const SizedBox(width: 6),
                          Text(_dateController.text,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgGrey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time, color: darkBlue, size: 14),
                      const SizedBox(width: 6),
                      Text('$_selectedHH:$_selectedMM',
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(height: 16),
              _buildSectionHeader('Vital Signs'),

              // Voice input card
              GestureDetector(
                onTap: _startVoiceInput,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x2264B5F6), blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x3D1A237E), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Smart Voice Input',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: darkBlue)),
                          const SizedBox(height: 2),
                          Text('Speak naturally: "temp 98.6", "BP 120 over 80". Say "Skip" to skip.',
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF3949AB))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0x1A1A237E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.chevron_right, color: darkBlue, size: 18),
                    ),
                  ]),
                ),
              ),

              // Vital input fields
              Column(children: [
                Row(children: [
                  Expanded(child: _buildVitalField(0, _tempController, 'Temp F ${_getVitalHint('1')}', '98.6', Icons.thermostat, '°F', 'temperature')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildVitalField(1, _hrController, 'Heart Rate ${_getVitalHint('2')}', '72', Icons.monitor_heart, 'bpm', 'heartRate')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _buildVitalField(2, _sysBpController, 'Sys BP ${_getVitalHint('4')}', '120', Icons.arrow_upward, 'mmHg', 'systolicBp')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildVitalField(3, _diaBpController, 'Dia BP ${_getVitalHint('5')}', '80', Icons.arrow_downward, 'mmHg', 'diastolicBp')),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _buildVitalField(4, _rrController, 'Resp. Rate ${_getVitalHint('3')}', '18', Icons.air, '/min', 'respiratoryRate')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildVitalField(5, _spo2Controller, 'SpO2 ${_getVitalHint('13')}', '98', Icons.water_drop, '%', 'spo2')),
                ]),
                const SizedBox(height: 8),
                _buildVitalField(6, _rbsController, 'RBS ${_getVitalHint('6')}', '100', Icons.bloodtype, 'mg/dL', 'rbs'),
              ]),

              // AI Suggestions panel toggle
              if (_aiSuggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _showAiPanel = !_showAiPanel),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Row(children: [
                      Icon(Icons.auto_awesome, color: Colors.indigo.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('AI Clinical Suggestions (${_aiSuggestions.length})',
                            style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.indigo.shade800)),
                      ),
                      Icon(_showAiPanel ? Icons.expand_less : Icons.expand_more,
                          color: Colors.indigo.shade700),
                    ]),
                  ),
                ),
                if (_showAiPanel)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _aiSuggestions
                          .map((s) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(s, style: GoogleFonts.poppins(fontSize: 12, height: 1.4)),
                              ))
                          .toList(),
                    ),
                  ),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),

        if (_showVoiceOverlay) _buildVoiceOverlay(),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            ),
          ),

        // AI Chat FAB
        Positioned(
          right: 16,
          bottom: 70,
          child: FloatingActionButton(
            heroTag: 'ai_chat',
            mini: true,
            backgroundColor: Colors.indigo,
            onPressed: () => setState(() => _showAiChat = !_showAiChat),
            child: Icon(_showAiChat ? Icons.close : Icons.smart_toy, color: Colors.white, size: 22),
          ),
        ),

        // AI Chat panel
        if (_showAiChat) _buildAiChatPanel(),

        // Save button
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -3))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSaveVitals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Text('Save Vitals',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiHealthCard() {
    final color = AiVitalsService.healthScoreColor(_healthScore);
    final label = AiVitalsService.healthScoreLabel(_healthScore);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 3),
          ),
          child: Center(
            child: Text('$_healthScore',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Health Score',
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
            Text(label,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            Text('Based on ${_currentVitalsMap().length} vital(s)',
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500)),
          ]),
        ),
        Icon(Icons.auto_awesome, color: color, size: 28),
      ]),
    );
  }

  Widget _buildVitalField(
    int index,
    TextEditingController controller,
    String label,
    String hint,
    IconData icon,
    String suffix,
    String fieldName,
  ) {
    final isCurrent = index == _currentFieldIndex;
    final severity = _fieldSeverity[fieldName];
    Color? borderColor;
    if (severity == 'critical') {
      borderColor = Colors.red;
    } else if (severity == 'caution') {
      borderColor = Colors.orange;
    } else if (isCurrent) {
      borderColor = darkBlue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
          ),
          if (severity != null && severity != 'normal')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AiVitalsService.severityColor(severity).withOpacity(0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(severity.toUpperCase(),
                  style: GoogleFonts.poppins(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: AiVitalsService.severityColor(severity))),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isCurrent ? darkBlue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: bgGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor ?? (Colors.grey.shade200),
              width: (isCurrent || severity == 'critical' || severity == 'caution') ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            enabled: !_isLoading,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: darkBlue, size: 16),
              suffixText: suffix,
              suffixStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade500),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              isDense: true,
            ),
            onChanged: (v) => _validateManualInput(fieldName, v),
          ),
        ),
        if (_fieldErrors[fieldName] != null)
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 4),
            child: Text(_fieldErrors[fieldName]!,
                style: const TextStyle(color: Colors.red, fontSize: 9)),
          ),
      ],
    );
  }

  Widget _buildAiChatPanel() {
    return Positioned(
      right: 12,
      bottom: 130,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.82,
          height: 340,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade100),
          ),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.indigo.shade700,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: Row(children: [
                const Icon(Icons.smart_toy, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('AI Vitals Assistant',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _showAiChat = false),
                  child: const Icon(Icons.close, color: Colors.white70, size: 20),
                ),
              ]),
            ),
            Expanded(
              child: _aiChatMessages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Ask me anything about the vitals.\nTry: "health score", "suggestions", "any abnormal?"',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _aiChatMessages.length,
                      itemBuilder: (_, i) {
                        final m = _aiChatMessages[i];
                        final isUser = m['role'] == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.65),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.indigo.shade100 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(m['text']!,
                                style: GoogleFonts.poppins(fontSize: 12, height: 1.35)),
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _aiChatController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Ask AI...',
                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _sendAiChat(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.indigo.shade700, size: 20),
                  onPressed: _sendAiChat,
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildVoiceOverlay() {
    final steps = _safeVoiceSteps;
    final stepCount = steps.isEmpty ? 1 : steps.length;
    final stepLabel = (_currentVoiceStep < steps.length) ? steps[_currentVoiceStep] : 'Vital';

    return Positioned.fill(
      child: Container(
        color: const Color(0xCC000000),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxHeight: 500, minHeight: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Voice Input',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Step ${_currentVoiceStep + 1} of $stepCount',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: _hideVoiceOverlay,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    LinearProgressIndicator(
                      value: (_currentVoiceStep + 1) / stepCount,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.blue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text(
                          '${((_currentVoiceStep + 1) / stepCount * 100).toInt()}%',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                    ]),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(stepLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(_voiceInstruction,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _voiceInstruction.contains('Listening')
                              ? Colors.green
                              : _voiceInstruction.contains('Could not understand')
                                  ? Colors.red
                                  : Colors.grey.shade700)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 80 : 60,
                    height: _isListening ? 80 : 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
                      border: Border.all(
                        color: _isListening ? Colors.blue : Colors.grey.shade300,
                        width: _isListening ? 3 : 2,
                      ),
                    ),
                    child: Center(
                      child: _isProcessingVoice
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
                          : Icon(Icons.mic,
                              size: _isListening ? 32 : 28,
                              color: _isListening ? Colors.blue : Colors.grey.shade600),
                    ),
                  ),
                ),
                if (_recognizedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(_recognizedText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black87, fontStyle: FontStyle.italic)),
                    ),
                  ),
                if (_voiceCollectedValues.containsKey(_currentVoiceStep))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text('Value: ${_voiceCollectedValues[_currentVoiceStep]}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade800)),
                      ]),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    Text('Example:',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(_getExampleHint(_currentVoiceStep),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.blue, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text('Or say "Skip" to skip this field',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentVoiceStep > 0 && !_isProcessingVoice
                              ? _moveToPreviousVoiceStep
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(
                              color: _currentVoiceStep > 0 && !_isProcessingVoice
                                  ? const Color(0xFF1A237E)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text('Previous',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _currentVoiceStep > 0 && !_isProcessingVoice
                                      ? const Color(0xFF1A237E)
                                      : Colors.grey.shade400)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isProcessingVoice ? null : _skipCurrentField,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: Colors.orange),
                          ),
                          child: Text('Skip',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.orange)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessingVoice
                            ? null
                            : () {
                                if (_voiceCollectedValues.containsKey(_currentVoiceStep)) {
                                  if (_currentVoiceStep < stepCount - 1) {
                                    _moveToNextVoiceStep();
                                  } else {
                                    _completeVoiceInput();
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _voiceCollectedValues.containsKey(_currentVoiceStep)
                              ? (_currentVoiceStep < stepCount - 1 ? Colors.blue : Colors.green)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isProcessingVoice
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : Text(
                                _voiceCollectedValues.containsKey(_currentVoiceStep)
                                    ? (_currentVoiceStep < stepCount - 1
                                        ? 'Next Field'
                                        : 'Finish & Save')
                                    : 'Speak Now',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  String _getExampleHint(int stepIndex) {
    switch (stepIndex) {
      case 0: return '"98.6" or "temp ninety eight point six"';
      case 1: return '"72" or "heart rate seventy two"';
      case 2: return '"120" or "bp one twenty"';
      case 3: return '"80" or "eighty"';
      case 4: return '"18" or "eighteen"';
      case 5: return '"98" or "spo2 ninety eight"';
      case 6: return '"100" or "sugar one hundred"';
      default: return 'Say the number clearly';
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(title,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// INTAKE ASSESSMENT TAB (kept same structure, voice fixed)
// ═══════════════════════════════════════════════════════════════════════════════

class IntakeAssessmentTab extends StatefulWidget {
  final Patient patient;
  const IntakeAssessmentTab({super.key, required this.patient});

  @override
  State<IntakeAssessmentTab> createState() => _IntakeAssessmentTabState();
}

class _IntakeAssessmentTabState extends State<IntakeAssessmentTab> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fluidController = TextEditingController();
  final TextEditingController _tpnController = TextEditingController();
  final TextEditingController _bloodFilterController = TextEditingController();
  final TextEditingController _feedController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _urineController = TextEditingController();

  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _currentFieldIndex = 0;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';

  bool _showVoiceOverlay = false;
  String _voiceInstruction = 'Please speak Fluid value';
  int _currentVoiceStep = 0;
  List<String> _voiceSteps = [];
  final Map<int, String> _voiceCollectedValues = {};
  bool _isProcessingVoice = false;
  bool _isVoiceInputComplete = false;

  final List<Map<String, dynamic>> _intakePatterns = [
    {'label': 'Fluid', 'controllerIndex': 0, 'hint': '0', 'range': '0-0', 'fieldName': 'fluid'},
    {'label': 'TPN', 'controllerIndex': 1, 'hint': '0', 'range': '0-0', 'fieldName': 'tpn'},
    {'label': 'Blood/PVE 40 H Filter', 'controllerIndex': 2, 'hint': '0', 'range': '0-0', 'fieldName': 'bloodFilter'},
    {'label': 'Feed', 'controllerIndex': 3, 'hint': '0', 'range': '0-0', 'fieldName': 'feed'},
    {'label': 'Medication', 'controllerIndex': 4, 'hint': '0', 'range': '0-0', 'fieldName': 'medication'},
    {'label': 'Urine', 'controllerIndex': 5, 'hint': '0', 'range': '0-0', 'fieldName': 'urine'},
  ];

  static const Color darkBlue = Color(0xFF1A237E);
  final Color bgGrey = const Color(0xFFF5F7FA);
  String _selectedHH = '13';
  String _selectedMM = '24';
  bool _isLoading = false;
  String? _errorMessage;
  final IpdService _ipdService = IpdService();

  TextEditingController _intakeCtrlFor(int index) {
    switch (index) {
      case 0: return _fluidController;
      case 1: return _tpnController;
      case 2: return _bloodFilterController;
      case 3: return _feedController;
      case 4: return _medicationController;
      case 5: return _urineController;
      default: return _fluidController;
    }
  }

  List<String> get _safeIntakeVoiceSteps {
    if (_voiceSteps.isNotEmpty) return _voiceSteps;
    return _intakePatterns.map((v) => v['label'] as String).toList();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('dd-MM-yyyy').format(now);
    _selectedHH = DateFormat('HH').format(now);
    _selectedMM = DateFormat('mm').format(now);

    // Controllers via _intakeCtrlFor only — do not store in maps (hot-reload safe)
    _voiceSteps = _intakePatterns.map((v) => v['label'] as String).toList();
    _initSpeech();

    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) setState(() => _currentFieldIndex = i);
      });
    }
  }

  @override
  void dispose() {
    for (var n in _focusNodes) n.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _isListening = false);
            if (_showVoiceOverlay && !_isProcessingVoice && !_isVoiceInputComplete && mounted) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_showVoiceOverlay && !_isVoiceInputComplete && mounted && !_isListening) {
                  _startVoiceListening();
                }
              });
            }
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isListening = false);
          _retrySpeechListening();
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
  }

  void _retrySpeechListening() {
    if (_showVoiceOverlay && !_isVoiceInputComplete && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_showVoiceOverlay && !_isVoiceInputComplete && mounted) _startVoiceListening();
      });
    }
  }

  void _startVoiceInput() async {
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Speech recognition is not available on this device'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ));
      }
      return;
    }
    bool hasPerm = await _speech.hasPermission;
    if (!hasPerm) {
      bool initialized = await _speech.initialize();
      if (!initialized) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please enable microphone permission from settings'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ));
        }
        return;
      }
    }
    _startVoiceSequence();
  }

  void _startVoiceSequence() {
    setState(() {
      _showVoiceOverlay = true;
      _currentVoiceStep = 0;
      _voiceCollectedValues.clear();
      _isProcessingVoice = false;
      _isVoiceInputComplete = false;
      _voiceInstruction = 'Please speak ${_voiceSteps[_currentVoiceStep]} or say "Skip"';
      _recognizedText = '';
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _showVoiceOverlay) _startVoiceListening();
    });
  }

  void _hideVoiceOverlay() {
    setState(() {
      _showVoiceOverlay = false;
      _isListening = false;
      _isProcessingVoice = false;
      _isVoiceInputComplete = false;
    });
    _speech.stop();
  }

  Future<void> _startVoiceListening() async {
    if (_isListening || _isProcessingVoice || _isVoiceInputComplete) return;
    if (_speech.isListening) {
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 300));
    }
    setState(() {
      _isListening = true;
      _recognizedText = '';
      _voiceInstruction = 'Listening... Speak ${_voiceSteps[_currentVoiceStep]} or say "Skip"';
    });
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() => _recognizedText = result.recognizedWords);
          if (result.finalResult) _processVoiceInputForCurrentStep(result.recognizedWords);
        },
        listenFor: const Duration(seconds: 15),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
      );
    } catch (e) {
      if (mounted) setState(() => _isListening = false);
      _retrySpeechListening();
    }
  }

  void _processVoiceInputForCurrentStep(String text) {
    if (text.isEmpty || _isProcessingVoice) return;
    setState(() {
      _isProcessingVoice = true;
      _isListening = false;
    });
    if (SmartVoiceParser.isSkip(text)) {
      _skipCurrentField();
      return;
    }
    final value = SmartVoiceParser.extractNumber(text);
    if (value != null) {
      _voiceCollectedValues[_currentVoiceStep] = value;
      _updateFieldWithValue(_currentVoiceStep, value);
      _showVoiceStepSuccess(value);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _showVoiceOverlay) _moveToNextVoiceStep();
      });
    } else {
      setState(() {
        _voiceInstruction =
            'Could not understand. Please say ${_voiceSteps[_currentVoiceStep]} or "Skip". Example: "100"';
        _recognizedText = '';
        _isProcessingVoice = false;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _showVoiceOverlay) _startVoiceListening();
      });
    }
  }

  void _skipCurrentField() {
    _showSkipSuccess();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _showVoiceOverlay) _moveToNextVoiceStep();
    });
  }

  void _showSkipSuccess() {
    final steps = _safeIntakeVoiceSteps;
    final current = (_currentVoiceStep < steps.length) ? steps[_currentVoiceStep] : 'Field';
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$current skipped'),
      backgroundColor: Colors.orange,
      duration: const Duration(seconds: 1),
    ));
    setState(() => _voiceInstruction = '$current skipped. Moving to next...');
  }

  void _updateFieldWithValue(int stepIndex, String value) {
    if (stepIndex < 0 || stepIndex > 5) return;
    final controller = _intakeCtrlFor(stepIndex);
    if (mounted) setState(() => controller.text = value);
  }

  void _showVoiceStepSuccess(String value) {
    final steps = _safeIntakeVoiceSteps;
    if (_currentVoiceStep >= steps.length) return;
    final current = steps[_currentVoiceStep];
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$current: $value recorded'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 1),
    ));
  }

  void _moveToNextVoiceStep() {
    final steps = _safeIntakeVoiceSteps;
    if (_currentVoiceStep < steps.length - 1) {
      setState(() {
        _currentVoiceStep++;
        _isProcessingVoice = false;
        _recognizedText = '';
        _voiceInstruction = 'Please speak ${steps[_currentVoiceStep]} or say "Skip"';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _showVoiceOverlay) _startVoiceListening();
      });
    } else {
      _completeVoiceInput();
    }
  }

  void _moveToPreviousVoiceStep() {
    final steps = _safeIntakeVoiceSteps;
    if (_currentVoiceStep > 0) {
      final clearIndex = _currentVoiceStep;
      setState(() {
        _currentVoiceStep--;
        _isProcessingVoice = false;
        _recognizedText = '';
        _voiceInstruction = 'Please speak ${steps[_currentVoiceStep]} or say "Skip"';
      });
      _voiceCollectedValues.remove(clearIndex);
      if (clearIndex >= 0 && clearIndex <= 5) {
        final controller = _intakeCtrlFor(clearIndex);
        if (mounted) setState(() => controller.text = '');
      }
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _showVoiceOverlay) _startVoiceListening();
      });
    }
  }

  void _completeVoiceInput() {
    setState(() {
      _isVoiceInputComplete = true;
      _voiceInstruction = 'Voice input complete!';
      _isListening = false;
    });
    _speech.stop();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _showVoiceInputComplete();
    });
  }

  void _showVoiceInputComplete() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: Text('Voice Input Complete!',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: darkBlue, fontSize: 16)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Successfully recorded ${_voiceCollectedValues.length} intake values:',
                  style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              ..._voiceCollectedValues.entries.map((e) {
                final name = _voiceSteps[e.key];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text('$name: ${e.value}', style: GoogleFonts.poppins(fontSize: 12))),
                  ]),
                );
              }),
              const SizedBox(height: 8),
              Text('Tap "Edit Values" to edit manually or "OK" to continue.',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hideVoiceOverlay();
            },
            child: Text('Edit Values', style: GoogleFonts.poppins(color: darkBlue, fontSize: 13)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hideVoiceOverlay();
            },
            child: Text('OK', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Future<void> _onSaveAssessment() async {
    setState(() => _errorMessage = null);
    if (_dateController.text.isEmpty) {
      setState(() => _errorMessage = 'Please select a date');
      return;
    }
    bool allEmpty = _fluidController.text.isEmpty &&
        _tpnController.text.isEmpty &&
        _bloodFilterController.text.isEmpty &&
        _feedController.text.isEmpty &&
        _medicationController.text.isEmpty &&
        _urineController.text.isEmpty;
    if (allEmpty) {
      setState(() => _errorMessage = 'Please enter at least one intake value');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Intake Assessment saved successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error saving assessment: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getExampleHint(int stepIndex) {
    switch (stepIndex) {
      case 0: return '"100"';
      case 1: return '"50"';
      case 2: return '"200"';
      case 3: return '"150"';
      case 4: return '"30"';
      case 5: return '"300"';
      default: return 'Say the number clearly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 11))),
                  ]),
                ),
              _buildSectionHeader('Date & Time'),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (ctx, child) => Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(primary: darkBlue),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null && mounted) {
                                setState(() =>
                                    _dateController.text = DateFormat('dd-MM-yyyy').format(picked));
                              }
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: bgGrey,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(children: [
                          const Icon(Icons.calendar_month, color: darkBlue, size: 14),
                          const SizedBox(width: 6),
                          Text(_dateController.text,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgGrey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time, color: darkBlue, size: 14),
                      const SizedBox(width: 6),
                      Text('$_selectedHH:$_selectedMM',
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Intake / Output Measurements'),
              GestureDetector(
                onTap: _startVoiceInput,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                    boxShadow: const [
                      BoxShadow(color: Color(0x2264B5F6), blurRadius: 6, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkBlue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Color(0x3D1A237E), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Step-by-Step Voice Input',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w600, color: darkBlue)),
                          const SizedBox(height: 2),
                          Text('Speak each value one by one. Say "Skip" to skip a field.',
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF3949AB))),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0x1A1A237E),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.chevron_right, color: darkBlue, size: 18),
                    ),
                  ]),
                ),
              ),
              Column(children: [
                Row(children: [
                  Expanded(
                      child: _buildIntakeInput(
                          controller: _fluidController,
                          label: 'Fluid',
                          hint: '0',
                          range: '0-0',
                          icon: Icons.water_drop,
                          focusNode: _focusNodes[0],
                          fieldIndex: 0)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildIntakeInput(
                          controller: _tpnController,
                          label: 'TPN',
                          hint: '0',
                          range: '0-0',
                          icon: Icons.medical_services,
                          focusNode: _focusNodes[1],
                          fieldIndex: 1)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _buildIntakeInput(
                          controller: _bloodFilterController,
                          label: 'Blood/PVE 40 H Filter',
                          hint: '0',
                          range: '0-0',
                          icon: Icons.bloodtype,
                          focusNode: _focusNodes[2],
                          fieldIndex: 2)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildIntakeInput(
                          controller: _feedController,
                          label: 'Feed',
                          hint: '0',
                          range: '0-0',
                          icon: Icons.restaurant,
                          focusNode: _focusNodes[3],
                          fieldIndex: 3)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: _buildIntakeInput(
                          controller: _medicationController,
                          label: 'Medication',
                          hint: '0',
                          range: '0-0',
                          icon: Icons.medication,
                          focusNode: _focusNodes[4],
                          fieldIndex: 4)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _buildIntakeInput(
                          controller: _urineController,
                          label: 'Urine',
                          hint: '0',
                          range: '0-0',
                          icon: Icons.wc,
                          focusNode: _focusNodes[5],
                          fieldIndex: 5)),
                ]),
              ]),
              const SizedBox(height: 60),
            ],
          ),
        ),
        if (_showVoiceOverlay) _buildVoiceOverlay(),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -3))
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSaveAssessment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : Text('Save Assessment',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceOverlay() {
    return Positioned.fill(
      child: Container(
        color: const Color(0xCC000000),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxHeight: 500, minHeight: 420),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x66000000), blurRadius: 20, spreadRadius: 2),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A237E),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Voice Input',
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text('Step ${_currentVoiceStep + 1} of ${_voiceSteps.length}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white.withOpacity(0.8))),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: _hideVoiceOverlay,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    LinearProgressIndicator(
                      value: (_currentVoiceStep + 1) / _voiceSteps.length,
                      backgroundColor: Colors.grey.shade200,
                      color: Colors.blue,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text(
                          '${((_currentVoiceStep + 1) / _voiceSteps.length * 100).toInt()}%',
                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                    ]),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(_voiceSteps[_currentVoiceStep],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A237E))),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(_voiceInstruction,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _voiceInstruction.contains('Listening')
                              ? Colors.green
                              : _voiceInstruction.contains('Could not understand')
                                  ? Colors.red
                                  : Colors.grey.shade700)),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 80 : 60,
                    height: _isListening ? 80 : 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
                      border: Border.all(
                        color: _isListening ? Colors.blue : Colors.grey.shade300,
                        width: _isListening ? 3 : 2,
                      ),
                    ),
                    child: Center(
                      child: _isProcessingVoice
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue)))
                          : Icon(Icons.mic,
                              size: _isListening ? 32 : 28,
                              color: _isListening ? Colors.blue : Colors.grey.shade600),
                    ),
                  ),
                ),
                if (_recognizedText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(_recognizedText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.black87, fontStyle: FontStyle.italic)),
                    ),
                  ),
                if (_voiceCollectedValues.containsKey(_currentVoiceStep))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text('Value: ${_voiceCollectedValues[_currentVoiceStep]}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade800)),
                      ]),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(children: [
                    Text('Example:',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text(_getExampleHint(_currentVoiceStep),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.blue, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 4),
                    Text('Or say "Skip" to skip this field',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange)),
                  ]),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentVoiceStep > 0 && !_isProcessingVoice
                              ? _moveToPreviousVoiceStep
                              : null,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: BorderSide(
                              color: _currentVoiceStep > 0 && !_isProcessingVoice
                                  ? const Color(0xFF1A237E)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text('Previous',
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: _currentVoiceStep > 0 && !_isProcessingVoice
                                      ? const Color(0xFF1A237E)
                                      : Colors.grey.shade400)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isProcessingVoice ? null : _skipCurrentField,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: Colors.orange),
                          ),
                          child: Text('Skip',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, fontWeight: FontWeight.w500, color: Colors.orange)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessingVoice
                            ? null
                            : () {
                                if (_voiceCollectedValues.containsKey(_currentVoiceStep)) {
                                  if (_currentVoiceStep < _voiceSteps.length - 1) {
                                    _moveToNextVoiceStep();
                                  } else {
                                    _completeVoiceInput();
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _voiceCollectedValues.containsKey(_currentVoiceStep)
                              ? (_currentVoiceStep < _voiceSteps.length - 1 ? Colors.blue : Colors.green)
                              : Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isProcessingVoice
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : Text(
                                _voiceCollectedValues.containsKey(_currentVoiceStep)
                                    ? (_currentVoiceStep < _voiceSteps.length - 1
                                        ? 'Next Field'
                                        : 'Finish & Save')
                                    : 'Speak Now',
                                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(title,
          style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
    );
  }

  Widget _buildIntakeInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String range,
    required IconData icon,
    FocusNode? focusNode,
    int? fieldIndex,
  }) {
    final isCurrent = fieldIndex == _currentFieldIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade500)),
          ),
          if (fieldIndex != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isCurrent ? darkBlue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text('${fieldIndex + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: isCurrent ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold)),
            ),
        ]),
        const SizedBox(height: 2),
        Text('Range: $range', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade400)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: bgGrey,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isCurrent ? darkBlue : Colors.grey.shade200,
              width: isCurrent ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            enabled: !_isLoading,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: darkBlue, size: 16),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}