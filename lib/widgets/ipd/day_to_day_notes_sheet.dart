import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:staff_mate/api/ipd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DayToDayNotesSheet extends StatefulWidget {
  final Patient patient;

  const DayToDayNotesSheet({super.key, required this.patient});

  @override
  State<DayToDayNotesSheet> createState() => _DayToDayNotesSheetState();
}

class _DayToDayNotesSheetState extends State<DayToDayNotesSheet> {
  final IpdService _ipdService = IpdService();
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _notesList = [];

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    setState(() => _isLoading = true);
    try {
      final admissionDate = widget.patient.admissionDate.isNotEmpty
          ? widget.patient.admissionDate
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      final result = await _ipdService.fetchDayToDayNotes(
        ipdid: widget.patient.admissionId,
        admissiondate: admissionDate,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success']) {
            _notesList = result['data'] ?? [];
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to load notes'),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading notes: $e')));
      }
    }
  }

  Future<void> _saveNote() async {
    final noteText = _notesController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a note.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '0';

      final admissionDate = widget.patient.admissionDate.isNotEmpty
          ? widget.patient.admissionDate
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Typically 'day' is calculated based on admission date. Defaulting to 1.
      final int day = 1;

      final result = await _ipdService.saveDayToDayNote(
        ipdid: widget.patient.admissionId,
        admissiondate: admissionDate,
        notes: noteText,
        day: day,
        id: 0, // 0 for new note
        createdByUserId: userId,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (result['success']) {
          _notesController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully!')),
          );
          _fetchNotes(); // Refresh notes list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to save note')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(
        20,
      ).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Day to Day Notes',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A237E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Patient: ${widget.patient.patientname}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admn Date: ${widget.patient.admissionDate}',
                  style: GoogleFonts.inter(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notesList.isEmpty
                ? Center(
                    child: Text(
                      'No notes found.',
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    itemCount: _notesList.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final note = _notesList[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          note['notes']?.toString() ?? '',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        subtitle: Text(
                          'Day ${note['day']} - Date: ${note['date'] ?? 'N/A'}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter nursing note...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 50,
                width: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveNote,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: const Color(0xFF1A237E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
