
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class MedicalRecordPdfService {
  static const String _fontPath =
      'assets/fonts/Amiri-Regular.ttf';

  static Future<Uint8List> generate({
    required int patientId,
    required String patientName,
    required List<dynamic> records,
  }) async {
    final fontData = await rootBundle.load(_fontPath);
    final arabicFont = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicFont,
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Text(
            'MedChain | ${context.pageNumber} / ${context.pagesCount}',
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 9,
            ),
          ),
        ),
        build: (context) => [
          pw.Text(
            'MEDCHAIN',
            textDirection: pw.TextDirection.ltr,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Medical Records | السجلات الطبية',
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 17,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 18),
          _field(
            'Patient Name',
            'اسم المريض',
            patientName,
            arabicFont,
          ),
          _field(
            'Patient ID',
            'رقم المريض',
            patientId.toString(),
            arabicFont,
          ),
          _field(
            'Report Generated',
            'تاريخ إنشاء التقرير',
            _formatDate(DateTime.now().toIso8601String()),
            arabicFont,
          ),
          pw.Divider(thickness: 1.5),
          pw.SizedBox(height: 10),
          if (records.isEmpty)
            pw.Text(
              'No records available | لا توجد سجلات طبية',
              textDirection: pw.TextDirection.rtl,
              style: pw.TextStyle(font: arabicFont),
            ),
          ...records.map((item) {
            final record =
                Map<String, dynamic>.from(item as Map);

            final recordId =
                _value(record['RecordId']);
            final diagnosis =
                _value(record['Diagnosis']);
            final notes =
                _value(record['Notes']);
            final doctorName =
                _value(record['DoctorName']);
            final specialization =
                _value(record['Specialization']);
            final createdAt =
                _formatDate(_value(record['CreatedAt']));
            final ipfsCID =
                _value(record['IpfsCID']);
            final blockchainId =
                _value(record['BlockchainRecordId']);

            return pw.Container(
              margin: const pw.EdgeInsets.only(
                top: 12,
                bottom: 8,
              ),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(
                  color: PdfColors.grey400,
                ),
                borderRadius:
                    pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Text(
                    'Medical Record #$recordId',
                    textDirection: pw.TextDirection.ltr,
                    style: pw.TextStyle(
                      font: arabicFont,
                      fontSize: 15,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  _field(
                    'Diagnosis',
                    'التشخيص',
                    diagnosis,
                    arabicFont,
                  ),
                  _field(
                    'Doctor',
                    'الطبيب',
                    doctorName,
                    arabicFont,
                  ),
                  if (specialization.isNotEmpty)
                    _field(
                      'Specialization',
                      'التخصص',
                      specialization,
                      arabicFont,
                    ),
                  _field(
                    'Created At',
                    'تاريخ التسجيل',
                    createdAt,
                    arabicFont,
                  ),
                  if (notes.isNotEmpty)
                    _field(
                      'Medical Notes',
                      'الملاحظات الطبية',
                      notes,
                      arabicFont,
                    ),
                  if (ipfsCID.isNotEmpty)
                    _field(
                      'IPFS CID',
                      'معرّف IPFS',
                      ipfsCID,
                      arabicFont,
                    ),
                  if (blockchainId.isNotEmpty)
                    _field(
                      'Blockchain Transaction',
                      'معاملة البلوك تشين',
                      blockchainId,
                      arabicFont,
                    ),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 12),
          pw.Text(
            'Confidential Medical Information | '
            'معلومات طبية سرية',
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: arabicFont,
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _field(
    String englishLabel,
    String arabicLabel,
    String value,
    pw.Font font,
  ) {
    final hasArabic =
        RegExp(r'[\u0600-\u06FF]').hasMatch(value);

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 9),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.stretch,
        children: [
          pw.Text(
            englishLabel,
            textDirection: pw.TextDirection.ltr,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey700,
            ),
          ),
          pw.Text(
            arabicLabel,
            textDirection: pw.TextDirection.rtl,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value.isEmpty ? '-' : value,
            textDirection: hasArabic
                ? pw.TextDirection.rtl
                : pw.TextDirection.ltr,
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  static String _value(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String _formatDate(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final local = date.toLocal();

    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}
