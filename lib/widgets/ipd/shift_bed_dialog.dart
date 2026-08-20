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
            final id = w['id']?.toString();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wards: $e')),
        );
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
      if (mounted) {
        setState(() {
          final seenIds = <String>{};
          _availableBeds = beds.where((b) {
            final id = b['id']?.toString();
            if (id == null || id.isEmpty) return false;
            return seenIds.add(id);
          }).toList();
          
          // If the previously selected bed is no longer in the list, reset it
          if (_selectedBedId != null && !seenIds.contains(_selectedBedId)) {
            _selectedBedId = null;
            _selectedBedName = null;
          }
          
          _isLoadingBeds = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBeds = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load beds: $e')),
        );
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
      final shiftingTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      
      final result = await _ipdService.shiftPatientBed(
        patientId: widget.patient.patientId.toString(),
        admissionId: widget.patient.admissionId,
        wardId: _selectedWardId!,
        wardName: _selectedWardName!,
        bedId: _selectedBedId!,
        bedName: _selectedBedName!,
        shiftingTime: shiftingTime,
        branchId: '1', // default to 1, or get from session
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
            SnackBar(content: Text(result['message'] ?? 'Failed to shift patient')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isShifting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
                  Text('Patient: ${widget.patient.patientname}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Current Bed: ${widget.patient.bedname}',
                      style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Target Ward',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            _isLoadingWards
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                    ),
                    hint: const Text('Select Ward', style: TextStyle(fontSize: 13)),
                    value: _selectedWardId,
                    items: _wards.map((ward) {
                      return DropdownMenuItem<String>(
                        value: ward['id']?.toString(),
                        child: Text(ward['wardname']?.toString() ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWardId = value;
                        final selectedWard = _wards.firstWhere((w) => w['id']?.toString() == value);
                        _selectedWardName = selectedWard['wardname']?.toString();
                      });
                      if (value != null) {
                        _fetchAvailableBeds(value);
                      }
                    },
                  ),
            const SizedBox(height: 20),
            Text(
              'Select Available Bed',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            const SizedBox(height: 6),
            _isLoadingBeds
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      isDense: true,
                    ),
                    hint: const Text('Select Bed', style: TextStyle(fontSize: 13)),
                    value: _selectedBedId,
                    items: _availableBeds.map((bed) {
                      return DropdownMenuItem<String>(
                        value: bed['id']?.toString(),
                        child: Text(bed['bedName']?.toString() ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: _selectedWardId == null
                        ? null
                        : (value) {
                            setState(() {
                              _selectedBedId = value;
                              final selectedBed = _availableBeds.firstWhere((b) => b['id']?.toString() == value);
                              _selectedBedName = selectedBed['bedName']?.toString();
                            });
                          },
                  ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _smsOnBedChange,
                  onChanged: (val) => setState(() => _smsOnBedChange = val ?? false),
                ),
                Text('Send SMS Alert', style: GoogleFonts.inter()),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _whatsappOnBedChange,
                  onChanged: (val) => setState(() => _whatsappOnBedChange = val ?? false),
                ),
                Text('Send WhatsApp Alert', style: GoogleFonts.inter()),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _isShifting ? null : _shiftPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isShifting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'Shift Patient',
                        style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
