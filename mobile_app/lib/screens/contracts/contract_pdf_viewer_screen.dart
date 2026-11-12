import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/contract_model.dart';
import '../escrow/create_escrow_screen.dart';

class ContractPdfViewerScreen extends StatelessWidget {
  final ContractModel contract;

  const ContractPdfViewerScreen({super.key, required this.contract});

  Future<void> _exportAndPrintPdf(BuildContext context) async {
    try {
      final doc = pw.Document();

      // Load Arabic font or standard ttf font using Printing helper
      final arabicFont = await PdfGoogleFonts.cairoRegular();
      final arabicBold = await PdfGoogleFonts.cairoBold();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(
            base: arabicFont,
            bold: arabicBold,
          ),
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('منصة عقودي القانونية (Oqoody)', style: pw.TextStyle(font: arabicBold, fontSize: 16, color: PdfColors.amber800)),
                    pw.Text('وثيقة رسمية موثقة', style: pw.TextStyle(font: arabicBold, fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  contract.title,
                  style: pw.TextStyle(font: arabicBold, fontSize: 20, color: PdfColors.teal900),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'رقم التوثيق الرقمي: ${contract.id.substring(0, contract.id.length > 10 ? 10 : contract.id.length).toUpperCase()}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
              pw.Divider(thickness: 1, color: PdfColors.amber800),
              pw.SizedBox(height: 12),
              pw.Paragraph(
                text: contract.renderedContent,
                style: const pw.TextStyle(fontSize: 11, lineSpacing: 5),
              ),
              pw.SizedBox(height: 24),
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('الطرف الأول / العميل:', style: pw.TextStyle(font: arabicBold, fontSize: 11)),
                      pw.Text(contract.clientName ?? 'العميل الموثق', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  if (contract.lawyerName != null)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('المحامي المراجع:', style: pw.TextStyle(font: arabicBold, fontSize: 11)),
                        pw.Text(contract.lawyerName!, style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('خاتم التوثيق الإلكتروني', style: pw.TextStyle(font: arabicBold, fontSize: 10, color: PdfColors.amber800)),
                      pw.Text('عقودي للحلول القانونية', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: '${contract.title}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر طباعة ملف PDF: $e'),
            backgroundColor: OqoodyTheme.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy - hh:mm a', 'ar');
    final formattedDate = contract.createdAt != null ? dateFormat.format(contract.createdAt!) : 'حديثاً';

    return Scaffold(
      appBar: AppBar(
        title: const Text('معاينة العقد الموثق'),
        centerTitle: true,
        backgroundColor: OqoodyTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: OqoodyTheme.accentGold),
            tooltip: 'تصدير PDF',
            onPressed: () => _exportAndPrintPdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status & Details Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: OqoodyTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: contract.status == 'approved' || contract.status == 'completed'
                      ? OqoodyTheme.successGreen
                      : OqoodyTheme.accentGold,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    contract.status == 'approved' || contract.status == 'completed'
                        ? Icons.verified
                        : Icons.hourglass_top,
                    color: contract.status == 'approved' || contract.status == 'completed'
                        ? OqoodyTheme.successGreen
                        : OqoodyTheme.accentGold,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contract.status == 'approved' || contract.status == 'completed'
                              ? 'عقد موثق وسارٍ قانونياً'
                              : 'بانتظار مراجعة المحامي المعتمد',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'تاريخ الإصدار: $formattedDate',
                          style: const TextStyle(color: OqoodyTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      contract.contractType == 'instant' ? 'فوري' : 'مراجعة محامٍ',
                      style: const TextStyle(fontSize: 11, color: OqoodyTheme.primaryDark, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: OqoodyTheme.accentGold,
                  ),
                ],
              ),
            ),

            if (contract.lawyerNotes != null && contract.lawyerNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: OqoodyTheme.primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OqoodyTheme.accentGold.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.rate_review, color: OqoodyTheme.accentGold, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'ملاحظات المحامي المعتمد:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: OqoodyTheme.accentGold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      contract.lawyerNotes!,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Parchment Legal Contract Document Paper
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F6EE), // Parchment ivory
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC5A059), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gold Seal & Emblem
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF9E7B35), width: 2),
                      color: const Color(0xFFF1E7C4),
                    ),
                    child: const Icon(Icons.balance, color: Color(0xFF9E7B35), size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'جمهورية مصر العربية\nمنصة عقودي للتوثيق والخدمات القانونية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF333333),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 1.5,
                    width: 140,
                    color: const Color(0xFF9E7B35),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    contract.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF1B4D3E),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'كود المستند: ${contract.id}',
                    style: const TextStyle(color: Color(0xFF666666), fontSize: 11),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFD4AF37), thickness: 1),
                  const SizedBox(height: 16),

                  // Contract Content Text
                  Align(
                    alignment: Alignment.centerRight,
                    child: SelectableText(
                      contract.renderedContent,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 14,
                        height: 1.8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFFD4AF37), thickness: 1),
                  const SizedBox(height: 16),

                  // Signatures Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('الطرف الأول (العميل):', style: TextStyle(color: Color(0xFF444444), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(contract.clientName ?? 'موقع إلكترونياً', style: const TextStyle(color: Color(0xFF1B4D3E), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('جهة التوثيق:', style: TextStyle(color: Color(0xFF444444), fontSize: 12, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('منصة عقودي المعتمدة', style: TextStyle(color: Color(0xFF9E7B35), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportAndPrintPdf(context),
                    icon: const Icon(Icons.print),
                    label: const Text('طباعة وتصدير PDF'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateEscrowScreen(preselectedContract: contract),
                        ),
                      );
                    },
                    icon: const Icon(Icons.security, color: OqoodyTheme.accentGold),
                    label: const Text('ربط بوساطة Escrow', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: OqoodyTheme.accentGold),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
