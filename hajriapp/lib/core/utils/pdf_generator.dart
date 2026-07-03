import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/reports/models/monthly_summary.dart';
import '../../features/workers/models/worker.dart';

class PdfGenerator {
  static Future<Uint8List> generateMonthlyReport({
    required String title,
    required String projectName,
    required String monthYear,
    required List<MonthlySummary> summaries,
    required List<Worker> workers,
  }) async {
    final pdf = pw.Document();

    // Load Gujarati Font for PDF
    final font = await PdfGoogleFonts.notoSansGujaratiRegular();
    final fallbackFont = await PdfGoogleFonts.notoSansRegular();

    final headers = [
      'No.',
      'Worker Name',
      'Rate',
      'P',
      'H',
      'A',
      'OT',
      'Gross',
      'Advance',
      'Paid',
      'Balance',
    ];

    final tableData = <List<String>>[];
    double totalGross = 0;
    double totalAdvance = 0;
    double totalPaid = 0;
    double totalBalance = 0;

    for (int i = 0; i < summaries.length; i++) {
      final summary = summaries[i];
      final worker = workers.firstWhere(
        (w) => w.id == summary.workerId,
        orElse: () => Worker(
          id: '',
          contractorId: '',
          fullName: 'Unknown',
          dailyWage: 0,
          joiningDate: '',
        ),
      );

      totalGross += summary.grossAmount;
      totalAdvance += summary.advance;
      totalPaid += summary.paid;
      totalBalance += summary.balance;

      tableData.add([
        '${i + 1}',
        worker.fullName,
        '₹${worker.dailyWage.toStringAsFixed(0)}',
        summary.presentDays.toStringAsFixed(0),
        summary.halfDays.toStringAsFixed(0),
        summary.absentDays.toStringAsFixed(0),
        '${summary.overtimeHours.toStringAsFixed(0)}h',
        '₹${summary.grossAmount.toStringAsFixed(0)}',
        '₹${summary.advance.toStringAsFixed(0)}',
        '₹${summary.paid.toStringAsFixed(0)}',
        '₹${summary.balance.toStringAsFixed(0)}',
      ]);
    }

    // Add totals row
    tableData.add([
      '',
      'TOTALS',
      '',
      '',
      '',
      '',
      '',
      '₹${totalGross.toStringAsFixed(0)}',
      '₹${totalAdvance.toStringAsFixed(0)}',
      '₹${totalPaid.toStringAsFixed(0)}',
      '₹${totalBalance.toStringAsFixed(0)}',
    ]);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme:
            pw.ThemeData.withFont(
              base: font,
              bold: font,
              italic: font,
              boldItalic: font,
            ).copyWith(
              defaultTextStyle: pw.TextStyle(fontFallback: [fallbackFont]),
            ),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Project: $projectName',
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Text(
                  monthYear,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: tableData,
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            cellAlignment: pw.Alignment.center,
            cellAlignments: {
              1: pw.Alignment.centerLeft, // Align worker name to left
            },
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generatePayslip({
    required String projectName,
    required String monthYear,
    required MonthlySummary summary,
    required Worker worker,
  }) async {
    final pdf = pw.Document();

    // Load Gujarati Font for PDF
    final font = await PdfGoogleFonts.notoSansGujaratiRegular();
    final fallbackFont = await PdfGoogleFonts.notoSansRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme:
            pw.ThemeData.withFont(
              base: font,
              bold: font,
              italic: font,
              boldItalic: font,
            ).copyWith(
              defaultTextStyle: pw.TextStyle(fontFallback: [fallbackFont]),
            ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'PAYSLIP (પગાર સ્લિપ)',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 32),

              // Worker & Project Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Worker Name: ${worker.fullName}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'Daily Wage: ₹${worker.dailyWage.toStringAsFixed(0)}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Project: $projectName',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Month: $monthYear',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 24),

              // Attendance Summary
              pw.Text(
                'Attendance Details',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Present Days (હાજર): ${summary.presentDays}'),
                  pw.Text('Half Days (અડધો દિવસ): ${summary.halfDays}'),
                  pw.Text('Absent Days (ગેરહાજર): ${summary.absentDays}'),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Text('Overtime Hours (ઓવરટાઇમ): ${summary.overtimeHours}h'),
              pw.SizedBox(height: 24),
              pw.Divider(color: PdfColors.grey400),
              pw.SizedBox(height: 24),

              // Financial Summary
              pw.Text(
                'Payment Details',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Gross Wages (કુલ પગાર):',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Text(
                    '₹${summary.grossAmount.toStringAsFixed(0)}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Advance Taken (એડવાન્સ લીધેલ):',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.red800,
                    ),
                  ),
                  pw.Text(
                    '- ₹${summary.advance.toStringAsFixed(0)}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.red800,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Salary Paid (પગાર ચૂકવ્યો):',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.green800,
                    ),
                  ),
                  pw.Text(
                    '- ₹${summary.paid.toStringAsFixed(0)}',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.green800,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey800),
              pw.SizedBox(height: 8),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'NET BALANCE DUE (બાકી રકમ):',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '₹${summary.balance.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    children: [
                      pw.SizedBox(
                        width: 150,
                        child: pw.Divider(color: PdfColors.black),
                      ),
                      pw.Text('Worker Signature (સહી)'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.SizedBox(
                        width: 150,
                        child: pw.Divider(color: PdfColors.black),
                      ),
                      pw.Text('Contractor Signature (સહી)'),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
