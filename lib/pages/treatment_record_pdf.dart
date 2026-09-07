import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:staff_mate/models/patient.dart';
import 'package:intl/intl.dart';

class TreatmentRecordPdfPreview extends StatelessWidget {
  final Patient patient;
  final List<List<String>> medicinesList;
  final List<List<String>> nursingCareList;
  final List<Map<String, dynamic>> investigationsData;
  final List<Map<String, dynamic>> vitalsData;
  final List<List<String>> dayToDayNotesList;
  final String fromDate;
  final String toDate;

  const TreatmentRecordPdfPreview({
    Key? key,
    required this.patient,
    required this.medicinesList,
    required this.nursingCareList,
    required this.investigationsData,
    required this.vitalsData,
    required this.dayToDayNotesList,
    required this.fromDate,
    required this.toDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Print Preview"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format, "Treatment Record"),
        allowPrinting: true,
        allowSharing: true, // Allows saving/downloading
        canChangeOrientation: false,
        canChangePageFormat: false,
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    // Grouping Vitals Data
    List<String> timeHeaders = vitalsData
        .map((e) => (e['time'] ?? '').toString())
        .toSet()
        .toList();
    Map<String, List<String>> vitalMap = {};
    for (var vital in vitalsData) {
      String vName = vital['name'] ?? 'Unknown';
      String vTime = vital['time'] ?? '';
      String vValue = vital['value'] ?? '-';
      if (!vitalMap.containsKey(vName)) {
        vitalMap[vName] = List.filled(timeHeaders.length, '-');
      }
      int tIndex = timeHeaders.indexOf(vTime);
      if (tIndex != -1) {
        vitalMap[vName]![tIndex] = vValue;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 20),
            
            if (medicinesList.isNotEmpty) ...[
              _buildSectionTitle("Medicine Care"),
              _buildTable(["Medicine", "Barcode ID", "Dosages", "Status"], medicinesList),
              pw.SizedBox(height: 20),
            ],

            if (nursingCareList.isNotEmpty) ...[
              _buildSectionTitle("Nursing Care"),
              _buildTable(["Task", "Category", "Times", "Status"], nursingCareList),
              pw.SizedBox(height: 20),
            ],

            if (investigationsData.isNotEmpty) ...[
              _buildSectionTitle("Investigations"),
              _buildInvestigationsTable(),
              pw.SizedBox(height: 20),
            ],

            if (vitalsData.isNotEmpty) ...[
              _buildSectionTitle("Vitals"),
              _buildVitalsTable(timeHeaders, vitalMap),
              pw.SizedBox(height: 20),
            ],

            if (dayToDayNotesList.isNotEmpty) ...[
              _buildSectionTitle("Day to Day Notes"),
              _buildTable(["Date", "Note", "By"], dayToDayNotesList),
              pw.SizedBox(height: 20),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Center(
          child: pw.Text("TREATMENT RECORD", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Name: ${patient.patientname}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text("UHID: ${patient.ipdNo}"),
                  pw.Text("Date Filter: $fromDate to $toDate"),
                ]
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text("Ward/Bed: ${patient.ward}/${patient.bedname}"),
                  pw.Text("Age/Gender: ${patient.age} / ${patient.gender}"),
                  pw.Text("Date: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
                ]
              )
            ]
          )
        )
      ]
    );
  }

  pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 5),
      child: pw.Text(
        title.toUpperCase(),
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
      ),
    );
  }

  pw.Widget _buildTable(List<String> headers, List<List<String>> data) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.all(5),
    );
  }

  pw.Widget _buildInvestigationsTable() {
    List<List<String>> tableData = investigationsData.map((inv) {
      return [
        (inv['test_name'] ?? inv['testName'] ?? "Unknown Test").toString(),
        (inv['category'] ?? "Test").toString(),
        (inv['formatedDate'] ?? inv['status'] ?? "-").toString()
      ];
    }).toList();
    
    return _buildTable(["Test Name", "Category", "Status/Date"], tableData);
  }

  pw.Widget _buildVitalsTable(List<String> timeHeaders, Map<String, List<String>> vitalMap) {
    List<String> headers = ["Vital Name", ...timeHeaders];
    List<List<String>> data = vitalMap.entries.map((e) {
      return [e.key, ...e.value];
    }).toList();
    return _buildTable(headers, data);
  }
}
