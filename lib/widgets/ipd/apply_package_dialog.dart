import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:staff_mate/services/package_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyPackageDialog extends StatefulWidget {
  final Patient patient;

  const ApplyPackageDialog({super.key, required this.patient});

  @override
  State<ApplyPackageDialog> createState() => _ApplyPackageDialogState();
}

class _ApplyPackageDialogState extends State<ApplyPackageDialog> {
  final PackageService _packageService = PackageService();
  bool _isLoading = true;
  bool _isApplying = false;

  List<dynamic> _parentPackages = [];
  List<dynamic> _childPackages = [];

  String? _selectedParentPackageId;
  String? _selectedChildPackageId;
  double _packageAmount = 0.0;
  int _validity = 0;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    setState(() => _isLoading = true);

    try {
      final existingPackage = await _packageService.checkPackageExists(
        int.tryParse(widget.patient.admissionId) ?? 0,
      );

      final parentList = await _packageService.fetchPackageListIpd();

      if (mounted) {
        setState(() {
          _parentPackages = parentList;
          _isLoading = false;
        });

        if (existingPackage['success'] &&
            existingPackage['data'] != null &&
            existingPackage['data'].isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Note: This patient already has an active package.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading packages: $e')));
      }
    }
  }

  Future<void> _fetchChildPackages(String parentId) async {
    setState(() {
      _selectedChildPackageId = null;
      _childPackages = [];
      _packageAmount = 0.0;
      _validity = 0;
    });

    final childList = await _packageService.fetchPackageChildList(parentId);
    if (mounted) {
      setState(() {
        _childPackages = childList;
      });
    }
  }

  Future<void> _applyPackage() async {
    if (_selectedParentPackageId == null || _selectedChildPackageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a parent and a child package.'),
        ),
      );
      return;
    }

    setState(() => _isApplying = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = int.tryParse(prefs.getString('userId') ?? '0') ?? 0;

      final result = await _packageService.applyPackage(
        admissionId: int.tryParse(widget.patient.admissionId) ?? 0,
        packageId: int.parse(_selectedParentPackageId!),
        packageAmount: _packageAmount,
        validity: _validity,
        childPackageId: int.parse(_selectedChildPackageId!),
        createdBy: userId,
      );

      if (mounted) {
        setState(() => _isApplying = false);
        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Package applied successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to apply package'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isApplying = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error applying package: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Apply Package',
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

              // Patient Info Card
              Container(
                width: double.infinity,
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
                      'Admn No: ${widget.patient.ipdNo}',
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form content
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                Text(
                  'Parent Package',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
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
                    'Select Parent Package',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _selectedParentPackageId,
                  items: _parentPackages.map((pkg) {
                    return DropdownMenuItem<String>(
                      value: pkg['id']?.toString(),
                      child: Text(
                        pkg['packageName']?.toString() ?? 'Unknown',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedParentPackageId = value;
                    });
                    if (value != null) {
                      _fetchChildPackages(value);
                    }
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Child Package',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
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
                    'Select Sub Package',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _selectedChildPackageId,
                  items: _childPackages.map((childPkg) {
                    return DropdownMenuItem<String>(
                      value: childPkg['id']?.toString(),
                      child: Text(
                        childPkg['packageName']?.toString() ?? 'Unknown',
                        style: const TextStyle(fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: _selectedParentPackageId == null
                      ? null
                      : (value) {
                          setState(() {
                            _selectedChildPackageId = value;
                            final selectedChild = _childPackages.firstWhere(
                              (p) => p['id']?.toString() == value,
                            );
                            _packageAmount =
                                double.tryParse(
                                  selectedChild['amount']?.toString() ?? '0',
                                ) ??
                                0.0;
                            _validity =
                                int.tryParse(
                                  selectedChild['validityDays']?.toString() ??
                                      '0',
                                ) ??
                                0;
                          });
                        },
                ),

                if (_selectedChildPackageId != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount: \$$_packageAmount',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                        Text(
                          'Validity: $_validity Days',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _isApplying ? null : _applyPackage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A237E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isApplying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Apply Package',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
