import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:staff_mate/api/ipd_service.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:staff_mate/services/speech_service.dart';

class VitalsEntrySheet extends StatefulWidget {
  final Patient patient;
  const VitalsEntrySheet({super.key, required this.patient});

  @override
  State<VitalsEntrySheet> createState() => _VitalsEntrySheetState();
}

class _VitalsEntrySheetState extends State<VitalsEntrySheet> {
  final TextEditingController _tempController = TextEditingController();
  final TextEditingController _hrController = TextEditingController();
  final TextEditingController _rrController = TextEditingController();
  final TextEditingController _sysBpController = TextEditingController();
  final TextEditingController _diaBpController = TextEditingController();
  final TextEditingController _rbsController = TextEditingController();
  final TextEditingController _spo2Controller = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String _selectedHH = '00';
  String _selectedMM = '00';

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _vitalsMasterData = [];
  final IpdService _ipdService = IpdService();

  final List<String> _hours = List.generate(
    24,
    (i) => i.toString().padLeft(2, '0'),
  );
  final List<String> _minutes = List.generate(
    60,
    (i) => i.toString().padLeft(2, '0'),
  );

  static const Color darkBlue = Color(0xFF1A237E);
  final Color bgGrey = const Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(now);
    _selectedHH = now.hour.toString().padLeft(2, '0');
    _selectedMM = now.minute.toString().padLeft(2, '0');

    _loadVitalsMasterData();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await SpeechService.instance.init();
    if (mounted) setState(() {});
  }

  void _toggleListening() async {
    if (SpeechService.instance.isListening) {
      await SpeechService.instance.stop();
      if (mounted) setState(() {});
    } else {
      await SpeechService.instance.startListening(
        onPartial: (text) {
          // You can show live text here if you want
        },
        onFinal: (text) {
          if (mounted) {
            setState(() {
              _processSpeechText(text);
            });
          }
        },
      );
      if (mounted) setState(() {});
    }
  }

  void _processSpeechText(String text) {
    debugPrint('Speech recognized: $text');
    final t = text.toLowerCase();

    // Helper to extract number
    String? extractNumber(RegExp regex) {
      final match = regex.firstMatch(t);
      if (match != null && match.groupCount >= 2) {
        return match.group(2);
      }
      return null;
    }

    final temp = extractNumber(RegExp(r'(temp|temperature)\s*(\d+\.?\d*)'));
    if (temp != null) _tempController.text = temp;

    final hr = extractNumber(RegExp(r'(heart rate|hr|pulse)\s*(\d+)'));
    if (hr != null) _hrController.text = hr;

    final rr = extractNumber(RegExp(r'(resp|respiratory rate|rr)\s*(\d+)'));
    if (rr != null) _rrController.text = rr;

    final spo2 = extractNumber(RegExp(r'(spo2|oxygen|o2|sp o2)\s*(\d+)'));
    if (spo2 != null) _spo2Controller.text = spo2;

    final rbs = extractNumber(RegExp(r'(rbs|sugar|glucose)\s*(\d+)'));
    if (rbs != null) _rbsController.text = rbs;

    // BP handling (e.g. "bp 120 by 80" or "blood pressure 120 over 80")
    final bpMatch = RegExp(
      r'(bp|blood pressure)\s*(\d+)\s*(by|over|/)\s*(\d+)',
    ).firstMatch(t);
    if (bpMatch != null) {
      _sysBpController.text = bpMatch.group(2)!;
      _diaBpController.text = bpMatch.group(4)!;
    } else {
      final sys = extractNumber(RegExp(r'(sys|systolic)\s*(\d+)'));
      if (sys != null) _sysBpController.text = sys;

      final dia = extractNumber(RegExp(r'(dia|diastolic)\s*(\d+)'));
      if (dia != null) _diaBpController.text = dia;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vitals auto-filled from voice!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
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
        final List<dynamic> masterData = response['data'] ?? [];

        _vitalsMasterData = masterData.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            return <String, dynamic>{};
          }
        }).toList();
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load vitals data';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading vitals data: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getVitalHint(String vitalId) {
    if (_vitalsMasterData.isEmpty) {
      return '(0-0)';
    }

    try {
      for (var vital in _vitalsMasterData) {
        final id = vital['id']?.toString() ?? '';
        if (id == vitalId) {
          final min = vital['min_value_f']?.toString() ?? '0';
          final max = vital['max_value_f']?.toString() ?? '0';
          return '($min-$max)';
        }
      }
    } catch (e) {
      debugPrint('Error getting vital hint: $e');
    }

    return '(0-0)';
  }

  Future<void> _onSaveVitals() async {
    setState(() {
      _errorMessage = null;
    });

    if (_dateController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a date';
      });
      return;
    }

    String admissionId = widget.patient.admissionId?.toString() ?? '';

    if (admissionId.isEmpty || admissionId == '0') {
      final prefs = await SharedPreferences.getInstance();
      admissionId = prefs.getString('admissionid') ?? '';
    }

    if (admissionId.isEmpty || admissionId == '0') {
      setState(() {
        _errorMessage =
            'Valid Admission ID not found. Please refresh patient data.';
      });
      return;
    }

    String patientId =
        widget.patient.patientid?.toString() ??
        widget.patient.clientId?.toString() ??
        '';

    if (patientId.isEmpty || patientId == '0') {
      setState(() {
        _errorMessage = 'Patient ID not found in patient data.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Vitals saved successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          Navigator.pop(context);
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to save vitals.';
          if (response['error'] != null) {
            _errorMessage = '${_errorMessage}\nAPI Error: ${response['error']}';
          }
        });
      }
    } catch (e, stackTrace) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _prepareVitalEntries() {
    final entries = <Map<String, dynamic>>[];

    if (_tempController.text.isNotEmpty) {
      entries.add({'vitalMasterId': 1, 'finding': _tempController.text});
    }
    if (_hrController.text.isNotEmpty) {
      entries.add({'vitalMasterId': 2, 'finding': _hrController.text});
    }
    if (_rrController.text.isNotEmpty) {
      entries.add({'vitalMasterId': 3, 'finding': _rrController.text});
    }
    if (_sysBpController.text.isNotEmpty) {
      entries.add({'vitalMasterId': 4, 'finding': _sysBpController.text});
    }
    if (_diaBpController.text.isNotEmpty) {
      entries.add({'vitalMasterId': 5, 'finding': _diaBpController.text});
    }
    if (_rbsController.text.isNotEmpty) {
      entries.add({'vitalMasterId': 6, 'finding': _rbsController.text});
    }
    if (_spo2Controller.text.isNotEmpty) {
      entries.add({'vitalMasterId': 13, 'finding': _spo2Controller.text});
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Capture Vitals",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkBlue,
                            ),
                          ),
                          Text(
                            "${widget.patient.patientname} | IPD: ${widget.patient.ipdNo}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Colors.grey[200]
                              : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.close,
                          color: _isLoading ? Colors.grey[400] : Colors.black54,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: Colors.red[50],
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("Date & Time"),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () async {
                                      DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                        builder: (context, child) {
                                          return Theme(
                                            data: ThemeData.light().copyWith(
                                              colorScheme:
                                                  const ColorScheme.light(
                                                    primary: darkBlue,
                                                  ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );
                                      if (picked != null && mounted) {
                                        setState(() {
                                          _dateController.text = DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(picked);
                                        });
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: bgGrey,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: darkBlue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _dateController.text,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.edit,
                                      color: Colors.grey[400],
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildTimeDropdown(
                                    label: "Hour",
                                    value: _selectedHH,
                                    items: _hours,
                                    onChanged: (value) {
                                      if (!_isLoading && value != null) {
                                        setState(() => _selectedHH = value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  ":",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildTimeDropdown(
                                    label: "Minute",
                                    value: _selectedMM,
                                    items: _minutes,
                                    onChanged: (value) {
                                      if (!_isLoading && value != null) {
                                        setState(() => _selectedMM = value);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader("Vital Signs"),
                          if (SpeechService.instance.isAvailable)
                            GestureDetector(
                              onTap: _toggleListening,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: SpeechService.instance.isListening
                                      ? Colors.red
                                      : darkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    if (SpeechService.instance.isListening)
                                      BoxShadow(
                                        color: Colors.red.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      SpeechService.instance.isListening
                                          ? Icons.mic
                                          : Icons.mic_none,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      SpeechService.instance.isListening
                                          ? 'Listening...'
                                          : 'Voice Auto-Fill',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: _buildModernInput(
                              controller: _tempController,
                              label: "Temp F ${_getVitalHint('1')}",
                              hint: "98.6",
                              icon: Icons.thermostat,
                              suffix: "°F",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernInput(
                              controller: _hrController,
                              label: "Heart Rate ${_getVitalHint('2')}",
                              hint: "72",
                              icon: Icons.monitor_heart,
                              suffix: "bpm",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _buildModernInput(
                              controller: _sysBpController,
                              label: "Sys BP ${_getVitalHint('4')}",
                              hint: "120",
                              icon: Icons.arrow_upward,
                              suffix: "mmHg",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernInput(
                              controller: _diaBpController,
                              label: "Dia BP ${_getVitalHint('5')}",
                              hint: "80",
                              icon: Icons.arrow_downward,
                              suffix: "mmHg",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: _buildModernInput(
                              controller: _rrController,
                              label: "Resp. Rate ${_getVitalHint('3')}",
                              hint: "18",
                              icon: Icons.air,
                              suffix: "/min",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildModernInput(
                              controller: _spo2Controller,
                              label: "SpO2 ${_getVitalHint('13')}",
                              hint: "98",
                              icon: Icons.water_drop,
                              suffix: "%",
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      _buildModernInput(
                        controller: _rbsController,
                        label: "RBS ${_getVitalHint('6')}",
                        hint: "100",
                        icon: Icons.bloodtype,
                        suffix: "mg/dL",
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 40),
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
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onSaveVitals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      shadowColor: darkBlue.withValues(alpha: 0.3),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            "Save Vitals",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),

          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 2),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? suffix,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: bgGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: !_isLoading,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: darkBlue.withValues(alpha: 0.7),
                size: 18,
              ),
              suffixText: suffix,
              suffixStyle: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: bgGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.grey,
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
