import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'package:workshop_shelf_helper/models/category.dart';

class ExportService {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  Future<String> exportToCSV(List<Component> components, List<Category> categories) async {
    final categoriesMap = {for (var cat in categories) cat.id: cat.name};

    List<List<dynamic>> rows = [];

    rows.add([
      'ID',
      'Categoria',
      'Modelo',
      'Quantidade',
      'Localização',
      'Polaridade',
      'Encapsulamento',
      'Custo Unitário (R\$)',
      'Valor Total (R\$)',
      'Observação',
    ]);

    for (var comp in components) {
      rows.add([
        comp.id,
        categoriesMap[comp.categoryId] ?? 'N/A',
        comp.model,
        comp.quantity,
        comp.location,
        comp.polarity ?? '',
        comp.package ?? '',
        comp.unitCost.toStringAsFixed(2),
        comp.totalValue.toStringAsFixed(2),
        comp.notes ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/componentes_$timestamp.csv';

    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  Future<String> exportToPDF(
    List<Component> components,
    List<Category> categories,
    Map<String, dynamic> statistics,
  ) async {
    final pdf = pw.Document();

    final categoriesMap = {for (var cat in categories) cat.id: cat.name};

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Relatório de Estoque',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Gerado em: ${_dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Resumo Geral',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),
              _buildPdfStatRow('Total de Categorias:', statistics['totalCategories'].toString()),
              _buildPdfStatRow('Total de Componentes:', statistics['totalComponents'].toString()),
              _buildPdfStatRow('Itens em Estoque:', statistics['totalStockItems'].toString()),
              _buildPdfStatRow(
                'Valor Total Investido:',
                _currencyFormat.format(statistics['totalValue']),
              ),
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Lista de Componentes',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),
            ],
          );
        },
      ),
    );

    final chunks = _chunkList(components, 20);

    for (var chunk in chunks) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1.5),
                4: const pw.FlexColumnWidth(1.5),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildPdfTableCell('Categoria', isHeader: true),
                    _buildPdfTableCell('Modelo', isHeader: true),
                    _buildPdfTableCell('Qtd', isHeader: true),
                    _buildPdfTableCell('Local', isHeader: true),
                    _buildPdfTableCell('Valor Total', isHeader: true),
                  ],
                ),
                // Data
                ...chunk.map((comp) {
                  return pw.TableRow(
                    children: [
                      _buildPdfTableCell(categoriesMap[comp.categoryId] ?? 'N/A'),
                      _buildPdfTableCell(comp.model),
                      _buildPdfTableCell(comp.quantity.toString()),
                      _buildPdfTableCell(comp.location),
                      _buildPdfTableCell(_currencyFormat.format(comp.totalValue)),
                    ],
                  );
                }),
              ],
            );
          },
        ),
      );
    }

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${directory.path}/relatorio_$timestamp.pdf';

    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    return filePath;
  }

  pw.Widget _buildPdfStatRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }
}
