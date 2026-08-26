import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/report.dart';

/// Generisanje PDF izvjestaja - prodaja po danima i top korisnici.
///
/// Oba izvjestaja se mogu preuzeti i odstampati, u skladu sa uputama za
/// izradu seminarskog rada (minimalno dva izvjestaja u PDF formatu).
class PdfReportService {
  const PdfReportService._();

  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _dayMonthFormat = DateFormat('dd.MM.');
  static final _moneyFormat = NumberFormat('#,##0.00');

  static const _primaryColor = PdfColor.fromInt(0xFF1B6CA8);
  static const _successColor = PdfColor.fromInt(0xFF1E8E5A);

  static Future<Uint8List> buildSalesReport(SalesReport report, {String? resortLabel}) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _header('Izvjestaj prodaje karata'),
        footer: (context) => _footer(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          pw.Text(
            'Period: ${_dateFormat.format(report.dateFrom)} - ${_dateFormat.format(report.dateTo)}'
            '${resortLabel != null ? ' | Skijaliste: $resortLabel' : ' | Sva skijalista'}',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _summaryCard('Ukupno karata', '${report.totalTicketCount}'),
              pw.SizedBox(width: 16),
              _summaryCard('Ukupan prihod', '${_moneyFormat.format(report.totalRevenue)} KM'),
            ],
          ),
          pw.SizedBox(height: 20),
          if (report.days.isNotEmpty) ...[
            _revenueChart(report),
            pw.SizedBox(height: 20),
          ],
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.6),
            columnWidths: const {0: pw.FlexColumnWidth(2), 1: pw.FlexColumnWidth(2), 2: pw.FlexColumnWidth(2)},
            children: [
              _tableHeaderRow(['Datum', 'Broj karata', 'Prihod (KM)']),
              for (final day in report.days)
                pw.TableRow(
                  children: [
                    _cell(_dateFormat.format(day.date)),
                    _cell('${day.ticketCount}'),
                    _cell(_moneyFormat.format(day.revenue)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return document.save();
  }

  static Future<Uint8List> buildTopUsersReport(TopUsersReport report) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _header('Top ${report.top} korisnika'),
        footer: (context) => _footer(context),
        build: (context) => [
          pw.SizedBox(height: 8),
          pw.Text('Rangiranje po broju kupljenih karata i ukupnoj potrosnji.', style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 20),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.6),
            columnWidths: const {
              0: pw.FlexColumnWidth(0.6),
              1: pw.FlexColumnWidth(2.4),
              2: pw.FlexColumnWidth(2.2),
              3: pw.FlexColumnWidth(1.4),
              4: pw.FlexColumnWidth(1.6),
            },
            children: [
              _tableHeaderRow(['#', 'Ime i prezime', 'E-mail', 'Karte', 'Potrosnja (KM)']),
              for (var i = 0; i < report.users.length; i++)
                pw.TableRow(
                  children: [
                    _cell('${i + 1}'),
                    _cell(report.users[i].fullName),
                    _cell(report.users[i].email),
                    _cell('${report.users[i].ticketCount}'),
                    _cell(_moneyFormat.format(report.users[i].totalSpent)),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _header(String title) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('SkiPass', style: pw.TextStyle(fontSize: 12, color: PdfColors.blue800, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey400),
        ],
      );

  static pw.Widget _footer(pw.Context context) => pw.Column(
        children: [
          pw.Divider(color: PdfColors.grey400),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Generisano: ${_dateFormat.format(DateTime.now())}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.Text('Stranica ${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            ],
          ),
        ],
      );

  static pw.Widget _summaryCard(String label, String value) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(6)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
              pw.SizedBox(height: 4),
              pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );

  /// Grafik prodaje karata i prihoda po danima - isti podaci i skaliranje
  /// kao graf u aplikaciji (Izvjestaji ekran), samo renderovan za PDF.
  static pw.Widget _revenueChart(SalesReport report) {
    final days = report.days;
    final maxTickets = days.fold<int>(0, (max, d) => d.ticketCount > max ? d.ticketCount : max);
    final maxRevenue = days.fold<double>(0, (max, d) => d.revenue > max ? d.revenue : max);
    final revenueScale = maxRevenue == 0 ? 1.0 : (maxTickets == 0 ? 1.0 : maxTickets / maxRevenue);
    final yMax = [maxTickets.toDouble(), ...days.map((d) => d.revenue * revenueScale)].reduce((a, b) => a > b ? a : b);
    final yStep = yMax <= 0 ? 1.0 : yMax / 4;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Prodaja i prihod po danima', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.SizedBox(
          height: 220,
          child: pw.Chart(
            grid: pw.CartesianGrid(
              xAxis: pw.FixedAxis.fromStrings(
                [for (final day in days) _dayMonthFormat.format(day.date)],
                textStyle: const pw.TextStyle(fontSize: 7),
              ),
              yAxis: pw.FixedAxis(
                [for (var i = 0; i <= 4; i++) yStep * i],
                format: (v) => v.round().toString(),
                textStyle: const pw.TextStyle(fontSize: 7),
                divisions: true,
              ),
            ),
            datasets: [
              pw.LineDataSet(
                legend: 'Broj karata',
                drawPoints: false,
                isCurved: true,
                color: _primaryColor,
                data: [for (var i = 0; i < days.length; i++) pw.PointChartValue(i.toDouble(), days[i].ticketCount.toDouble())],
              ),
              pw.LineDataSet(
                legend: 'Prihod (skalirano)',
                drawPoints: false,
                isCurved: true,
                color: _successColor,
                data: [for (var i = 0; i < days.length; i++) pw.PointChartValue(i.toDouble(), days[i].revenue * revenueScale)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.TableRow _tableHeaderRow(List<String> labels) => pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.blue800),
        children: [
          for (final label in labels)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: pw.Text(label, style: pw.TextStyle(fontSize: 10, color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
            ),
        ],
      );

  static pw.Widget _cell(String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: pw.Text(value, style: const pw.TextStyle(fontSize: 9.5)),
      );
}
