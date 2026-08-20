import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:staff_mate/api/ipd_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DayToDayNotesDialog extends StatefulWidget {
  final Patient patient;

  const DayToDayNotesDialog({super.key, required this.patient});

  @override
  State<DayToDayNotesDialog> createState() => _DayToDayNotesDialogState();
}

class _DayToDayNotesDialogState extends State<DayToDayNotesDialog> {
  final IpdService _ipdService = IpdService();
  final TextEditingController _notesController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  List<dynamic> _notesList = [];

  // For editing
  int _editingNoteId = 0;
  int _editingNoteDay = 1;

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
            // Sort by date descending if possible, assuming API doesn't guarantee order
            _notesList.sort((a, b) {
              final idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
              final idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
              return idB.compareTo(idA); // Descending ID
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'] ?? 'Failed to load notes')),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notes: $e')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    final noteText = _notesController.text.trim();
    if (noteText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '0';

      final admissionDate = widget.patient.admissionDate.isNotEmpty 
          ? widget.patient.admissionDate 
          : DateFormat('yyyy-MM-dd').format(DateTime.now());
          
      // If editing, use the existing note's day, otherwise calculate
      int dayToUse = _editingNoteDay;
      if (_editingNoteId == 0) {
        // Calculate day based on admission date
        try {
          DateTime admnDate = DateFormat('yyyy-MM-dd').parse(admissionDate.substring(0, 10));
          dayToUse = DateTime.now().difference(admnDate).inDays + 1;
        } catch (_) {
          dayToUse = 1;
        }
      }

      final result = await _ipdService.saveDayToDayNote(
        ipdid: widget.patient.admissionId,
        admissiondate: admissionDate,
        notes: noteText,
        day: dayToUse,
        id: _editingNoteId, 
        createdByUserId: userId,
        status: 1, // 1 = New, 0 = Read
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (result['success']) {
          _notesController.clear();
          setState(() {
            _editingNoteId = 0;
            _editingNoteDay = 1;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note saved successfully!')),
          );
          _fetchNotes(); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Failed to save note')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    }
  }

  Future<void> _updateNoteStatus(Map<String, dynamic> note) async {
    // Only update if it's 'New' (status == 1 or true)
    final status = note['status']?.toString();
    if (status != '1' && status != 'true') return;

    // Optimistically update UI
    setState(() {
      note['status'] = 0;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '0';

      await _ipdService.saveDayToDayNote(
        ipdid: note['ipdid']?.toString() ?? widget.patient.admissionId,
        admissiondate: note['admissiondate']?.toString() ?? widget.patient.admissionDate,
        notes: note['notes']?.toString() ?? '',
        day: int.tryParse(note['day']?.toString() ?? '1') ?? 1,
        id: int.tryParse(note['id']?.toString() ?? '0') ?? 0,
        createdByUserId: note['createdByUserId']?.toString() ?? userId,
        status: 0, // Mark as read
      );
    } catch (e) {
      // Revert if failed
      setState(() {
        note['status'] = 1;
      });
      debugPrint('Failed to update status: $e');
    }
  }

  void _editNote(Map<String, dynamic> note) {
    setState(() {
      _editingNoteId = int.tryParse(note['id']?.toString() ?? '0') ?? 0;
      _editingNoteDay = int.tryParse(note['day']?.toString() ?? '1') ?? 1;
      _notesController.text = note['notes']?.toString() ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingNoteId = 0;
      _editingNoteDay = 1;
      _notesController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Current Day Calculation
    int currentDay = 1;
    if (widget.patient.admissionDate.isNotEmpty) {
      try {
        DateTime admnDate = DateFormat('yyyy-MM-dd').parse(widget.patient.admissionDate.substring(0, 10));
        currentDay = DateTime.now().difference(admnDate).inDays + 1;
      } catch (_) {}
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _editingNoteId > 0 ? 'Edit Day To Day Notes' : 'Add Day To Day Notes',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),
            
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Area
                    Text(
                      'ENTER NOTES FOR ( DAY : $currentDay )',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Enter Day To Day Notes',
                          hintStyle: GoogleFonts.inter(color: Colors.grey.shade500),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_editingNoteId > 0) ...[
                          TextButton(
                            onPressed: _cancelEdit,
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveNote,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E88E5), // Blue like web app, or green 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: _isSaving 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade100),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Text('Day', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800))),
                          Expanded(flex: 3, child: Text('Date', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800))),
                          Expanded(flex: 5, child: Text('Notes', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800))),
                          Expanded(flex: 1, child: Text('Actions', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800))),
                        ],
                      ),
                    ),
                    
                    // Table Body
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.blue.shade100),
                            right: BorderSide(color: Colors.blue.shade100),
                            bottom: BorderSide(color: Colors.blue.shade100),
                          ),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                        ),
                        child: _isLoading 
                            ? const Center(child: CircularProgressIndicator())
                            : _notesList.isEmpty
                                ? Center(child: Text('No notes found.', style: GoogleFonts.inter(color: Colors.grey)))
                                : ListView.separated(
                                    itemCount: _notesList.length,
                                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
                                    itemBuilder: (context, index) {
                                      final note = _notesList[index];
                                      final day = note['day']?.toString() ?? '1';
                                      final dateStr = note['date']?.toString() ?? 'N/A';
                                      final byUser = note['createdByName']?.toString() ?? note['createdByUserId']?.toString() ?? 'N/A';
                                      final noteText = note['notes']?.toString() ?? '';
                                      
                                      final status = note['status']?.toString();
                                      final isNew = status == '1' || status == 'true';
                                      
                                      return InkWell(
                                        onTap: () => _updateNoteStatus(note),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Day
                                              Expanded(
                                                flex: 1, 
                                                child: Text('Day\n$day', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade800)),
                                              ),
                                              
                                              // Date & Status
                                              Expanded(
                                                flex: 3, 
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(dateStr, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500)),
                                                    const SizedBox(height: 4),
                                                    Text('By $byUser', style: GoogleFonts.inter(fontSize: 11, color: Colors.blue.shade400)),
                                                    const SizedBox(height: 6),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: isNew ? Colors.red.shade50 : Colors.green.shade50,
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        isNew ? 'New' : 'Read',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10, 
                                                          fontWeight: FontWeight.w600,
                                                          color: isNew ? Colors.red.shade700 : Colors.green.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              
                                              // Notes
                                              Expanded(
                                                flex: 5, 
                                                child: Text(noteText, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade800)),
                                              ),
                                              
                                              // Actions
                                              Expanded(
                                                flex: 1, 
                                                child: Center(
                                                  child: IconButton(
                                                    icon: const Icon(Icons.edit_square, color: Colors.blue, size: 18),
                                                    onPressed: () => _editNote(note),
                                                    constraints: const BoxConstraints(),
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
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
}
