import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workshop_shelf_helper/models/category_stock.dart';
import 'package:workshop_shelf_helper/screens/reports/widgets/table_data_cell.dart';
import 'package:workshop_shelf_helper/screens/reports/widgets/table_header_cell.dart';

class StockByCategoryTable extends StatelessWidget {
  final List<CategoryStock> stockByCategory;
  final NumberFormat currencyFormat;

  const StockByCategoryTable({
    super.key,
    required this.stockByCategory,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    if (stockByCategory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text('Nenhum item em estoque', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  children: const [
                    TableHeaderCell(text: 'Categoria'),
                    TableHeaderCell(text: 'Tipos'),
                    TableHeaderCell(text: 'Itens'),
                    TableHeaderCell(text: 'Valor Total'),
                  ],
                ),
              ],
            ),
            const Divider(),
            // Data
            ...stockByCategory.map(
              (item) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1.5),
                  },
                  children: [
                    TableRow(
                      children: [
                        TableDataCell(text: item.name),
                        TableDataCell(text: item.componentCount.toString(), centered: true),
                        TableDataCell(text: item.itemQuantity.toString(), centered: true),
                        TableDataCell(text: currencyFormat.format(item.totalValue), centered: true),
                      ],
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
