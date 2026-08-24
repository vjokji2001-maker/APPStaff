import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../theme/hr_theme.dart';

class FaceAttendanceErrorView extends StatefulWidget {
  final String rawError;
  final VoidCallback onRetry;

  const FaceAttendanceErrorView({
    super.key,
    required this.rawError,
    required this.onRetry,
  });

  @override
  State<FaceAttendanceErrorView> createState() => _FaceAttendanceErrorViewState();
}

class _FaceAttendanceErrorViewState extends State<FaceAttendanceErrorView> {
  bool _isExpanded = false;
  late final Map<String, String> _parsedError;

  @override
  void initState() {
    super.initState();
    _parsedError = _parseErrorMessage(widget.rawError);
  }

  Map<String, String> _parseErrorMessage(String errorString) {
    try {
      // Find the JSON substring if any
      final start = errorString.indexOf('{');
      final end = errorString.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final jsonStr = errorString.substring(start, end + 1);
        final data = json.decode(jsonStr);
        if (data is Map<String, dynamic>) {
          final message = data['message'] ?? data['error']?['message'] ?? 'Unknown Server Error';
          String details = '';
          if (data['error'] != null && data['error'] is Map) {
            details = data['error']['cause'] ?? data['error']['message'] ?? '';
          }
          if (details.isEmpty) {
            details = data['cause'] ?? '';
          }
          return {
            'message': message.toString(),
            'details': details.isNotEmpty ? details.toString() : jsonStr,
            'type': 'API_ERROR'
          };
        }
      }
    } catch (_) {
      // Fallback
    }

    // Clean up typical exception prefixes
    var cleanMsg = errorString;
    cleanMsg = cleanMsg.replaceAll(RegExp(r'^Exception:\s*'), '');
    cleanMsg = cleanMsg.replaceAll(RegExp(r'Exception:\s*'), '');
    return {
      'message': cleanMsg,
      'details': errorString,
      'type': 'GENERIC'
    };
  }

  void _copyToClipboard() {
    final copyText = '--- Staff Mate Attendance Error Log ---\n'
        'Message: ${_parsedError['message']}\n'
        'Details: ${_parsedError['details']}\n'
        'Raw: ${widget.rawError}';
        
    Clipboard.setData(ClipboardData(text: copyText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'Error details copied to clipboard!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = _parsedError['message'] ?? 'Failed to record attendance';
    final details = _parsedError['details'] ?? '';
    final isJpaError = details.contains('JPA') || details.contains('EntityManager') || widget.rawError.contains('EntityManager');
    final isFaceMismatch = message.toLowerCase().contains('face');
    final isLocationError = message.toLowerCase().contains('location') || details.toLowerCase().contains('location');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Pulsing / Styled Red Error Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red.shade100, width: 4),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 54,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          Text(
            'Verification Failed',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: HRTheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          
          // Cleaned-up primary error message
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 24),

          // User-friendly contextual tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange.shade800,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isLocationError
                        ? 'Your device\'s location services or permissions are disabled. Please enable them in your device settings to proceed with attendance.'
                        : isJpaError
                            ? 'This is a server-side database issue. Please copy the technical details below and share it with your administrator/IT support.'
                            : isFaceMismatch
                                ? 'The system was unable to verify your face. Please ensure you are standing in a well-lit area, looking straight at the camera, and not wearing sunglasses or masks.'
                                : 'An unexpected verification error occurred. Please verify your internet connection and try again.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Technical Details Container
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.code_rounded, color: Colors.grey.shade600, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Technical Logs',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  const Divider(height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (details.isNotEmpty) ...[
                          Text(
                            'Cause:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            details,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'Full Raw Response:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.rawError,
                            style: GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: Colors.green.shade400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Copy Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: _copyToClipboard,
                            icon: const Icon(Icons.copy, size: 16),
                            label: Text(
                              'Copy Logs',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: HRTheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Primary and Secondary Buttons
          if (isLocationError) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                icon: const Icon(Icons.settings),
                label: Text(
                  'Open Settings',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HRTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Retry Punch',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
