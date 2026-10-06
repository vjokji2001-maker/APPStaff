import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/api/ipd_service.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:intl/intl.dart';

class ShiftBedDialog extends StatefulWidget {
  final Patient patient;
  final VoidCallback onShiftComplete;

  const ShiftBedDialog({
    super.key,
    required this.patient,
    required this.onShiftComplete,
  });

  @override
  State<ShiftBedDialog> createState() => _ShiftBedDialogState();
}

class _ShiftBedDialogState extends State<ShiftBedDialog> {
  final IpdService _ipdService = IpdService();
  bool _isLoadingWards = true;
  bool _isLoadingBeds = false;
  bool _isShifting = false;

  List<dynamic> _wards = [];
  List<dynamic> _availableBeds = [];

  String? _selectedWardId;
  String? _selectedWardName;
  String? _selectedBedId;
  String? _selectedBedName;

  bool _smsOnBedChange = false;
  bool _whatsappOnBedChange = false;

  String? _idOf(dynamic item, {required bool bed}) {
    if (item is! Map) return null;
    final value = bed
        ? (item['bedid'] ??
              item['bedId'] ??
              item['bed_id'] ??
              item['bedno'] ??
              item['bedNo'] ??
              item['id'])
        : (item['id'] ?? item['wardid'] ?? item['wardId'] ?? item['ward_id']);
    return value?.toString();
  }

  String _nameOf(dynamic item, {required bool bed}) {
    if (item is! Map) return 'Unknown';
    return (bed
                ? (item['bedName'] ??
                      item['bedname'] ??
                      item['bed_name'] ??
                      item['bedNo'] ??
                      item['bedno'] ??
                      item['name'])
                : (item['wardname'] ??
                      item['wardName'] ??
                      item['ward_name'] ??
                      item['name']))
            ?.toString() ??
        'Unknown';
  }

  @override
  void initState() {
    super.initState();
    _fetchWards();
  }

  Future<void> _fetchWards() async {
    setState(() => _isLoadingWards = true);
    try {
      final wards = await _ipdService.fetchBranchWardList();
      if (mounted) {
        setState(() {
          final seenIds = <String>{};
          _wards = wards.where((w) {
            final id = _idOf(w, bed: false);
            if (id == null || id.isEmpty) return false;
            return seenIds.add(id);
          }).toList();

          // If the previously selected ward is no longer in the list, reset it
          if (_selectedWardId != null && !seenIds.contains(_selectedWardId)) {
            _selectedWardId = null;
            _selectedWardName = null;
          }

          _isLoadingWards = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingWards = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load wards: $e')));
      }
    }
  }

  Future<void> _fetchAvailableBeds(String wardId) async {
    setState(() {
      _isLoadingBeds = true;
      _selectedBedId = null;
      _selectedBedName = null;
      _availableBeds = [];
    });

    try {
      final beds = await _ipdService.fetchAvailableBedsInWard(wardId: wardId);

      debugPrint('========== AVAILABLE BEDS ==========');
      debugPrint('Ward ID: $wardId');
      debugPrint('Beds count: ${beds.length}');
      debugPrint('Beds response: $beds');

      if (!mounted) return;

      final seenIds = <String>{};

      final validBeds = <dynamic>[];

      for (final bed in beds) {
        debugPrint('RAW BED: $bed');

        final bedId = _idOf(bed, bed: true);
        final bedName = _nameOf(bed, bed: true);

        debugPrint('BED ID: $bedId');
        debugPrint('BED NAME: $bedName');

        if (bedId != null && bedId.isNotEmpty) {
          if (seenIds.add(bedId)) {
            validBeds.add(bed);
          }
        }
      }

      setState(() {
        _availableBeds = validBeds;
        _isLoadingBeds = false;
      });

      debugPrint('VALID AVAILABLE BEDS: ${_availableBeds.length}');
    } catch (e, stackTrace) {
      debugPrint('ERROR LOADING BEDS: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        setState(() {
          _isLoadingBeds = false;
          _availableBeds = [];
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load beds: $e')));
      }
    }
  }

  Future<void> _shiftPatient() async {
    if (_selectedWardId == null || _selectedBedId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a ward and a bed')),
      );
      return;
    }

    setState(() => _isShifting = true);

    try {
      final shiftingTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(DateTime.now());

      final result = await _ipdService.shiftPatientBed(
        patientId: widget.patient.patientId.toString(),
        admissionId: widget.patient.admissionId,
        wardId: _selectedWardId!,
        wardName: _selectedWardName!,
        bedId: _selectedBedId!,
        bedName: _selectedBedName!,
        shiftingTime: shiftingTime,
        branchId: '1',
        patientName: widget.patient.patientname,
        smsOnBedChange: _smsOnBedChange,
        whatsappOnBedChange: _whatsappOnBedChange,
      );

      if (mounted) {
        setState(() => _isShifting = false);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Patient shifted successfully!')),
          );
          widget.onShiftComplete();
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to shift patient'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isShifting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Shift Patient',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A237E),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Patient: ${widget.patient.patientname}',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Current Bed: ${widget.patient.bedname}',
                    style: GoogleFonts.inter(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Target Ward',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 6),
            _isLoadingWards
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    hint: const Text(
                      'Select Ward',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: _selectedWardId,
                    items: _wards.map((ward) {
                      return DropdownMenuItem<String>(
                        value: _idOf(ward, bed: false),
                        child: Text(
                          _nameOf(ward, bed: false),
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWardId = value;
                        final selectedWard = _wards.firstWhere(
                          (w) => _idOf(w, bed: false) == value,
                        );
                        _selectedWardName = _nameOf(selectedWard, bed: false);
                      });
                      if (value != null) {
                        _fetchAvailableBeds(value);
                      }
                    },
                  ),
            const SizedBox(height: 20),

            Text(
              'Select Available Bed',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),

            const SizedBox(height: 6),

            _isLoadingBeds
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _availableBeds.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'No available beds found for this ward.',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    hint: const Text(
                      'Select Bed',
                      style: TextStyle(fontSize: 13),
                    ),
                    value: _selectedBedId,
                    items: _availableBeds.map((bed) {
                      final bedId = _idOf(bed, bed: true);
                      final bedName = _nameOf(bed, bed: true);

                      return DropdownMenuItem<String>(
                        value: bedId,
                        child: Text(
                          bedName,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      final selectedBed = _availableBeds.firstWhere(
                        (b) => _idOf(b, bed: true) == value,
                      );

                      setState(() {
                        _selectedBedId = value;
                        _selectedBedName = _nameOf(selectedBed, bed: true);
                      });

                      debugPrint('Selected Bed ID: $_selectedBedId');
                      debugPrint('Selected Bed Name: $_selectedBedName');
                    },
                  ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                'Send SMS alert',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              value: _smsOnBedChange,
              activeColor: const Color(0xFF1A237E),
              onChanged: _isShifting
                  ? null
                  : (value) => setState(() => _smsOnBedChange = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(
                'Send WhatsApp alert',
                style: GoogleFonts.inter(fontSize: 13),
              ),
              value: _whatsappOnBedChange,
              activeColor: const Color(0xFF1A237E),
              onChanged: _isShifting
                  ? null
                  : (value) => setState(() => _whatsappOnBedChange = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isShifting ||
                        _selectedWardId == null ||
                        _selectedBedId == null
                    ? null
                    : _shiftPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isShifting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.swap_horiz),
                label: Text(_isShifting ? 'Shifting...' : 'Shift Patient'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
