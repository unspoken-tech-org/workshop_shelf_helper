import 'package:flutter/material.dart';
import 'package:workshop_shelf_helper/models/import_result.dart';
import 'package:intl/intl.dart';

class ImportPreviewTable extends StatelessWidget {
  final List<ImportPreviewData> previewData;

  const ImportPreviewTable({super.key, required this.previewData});

  @override
  Widget build(BuildContext context) {
    if (previewData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Nenhum dado válido encontrado no arquivo',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
            border: TableBorder.all(color: Colors.grey.shade300),
            columnSpacing: 16,
            horizontalMargin: 12,
            columns: const [
              DataColumn(label: Text('Modelo', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Categoria', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Qtd', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Localização', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Polaridade', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                label: Text('Encapsulamento', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(label: Text('Custo Unit.', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Valor Total', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows:
                previewData.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data.model)),
                      DataCell(Text(data.category)),
                      DataCell(Text(data.quantity.toString())),
                      DataCell(Text(data.location)),
                      DataCell(Text(data.polarity ?? '-')),
                      DataCell(Text(data.package ?? '-')),
                      DataCell(Text(currencyFormat.format(data.unitCost))),
                      DataCell(Text(currencyFormat.format(data.quantity * data.unitCost))),
                    ],
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }
}
