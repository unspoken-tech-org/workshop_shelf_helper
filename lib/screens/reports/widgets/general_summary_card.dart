import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';
import 'package:workshop_shelf_helper/screens/reports/widgets/stat_row.dart';

class GeneralSummaryCard extends StatelessWidget {
  final Statistics? statistics;
  final NumberFormat currencyFormat;

  const GeneralSummaryCard({super.key, required this.statistics, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    if (statistics == null) {
      return const Center(child: Text('Nenhuma estatística disponível'));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StatRow(
              label: 'Total de Categorias',
              value: statistics!.totalCategories.toString(),
              icon: Icons.category,
              color: Colors.blue,
            ),
            const Divider(),
            StatRow(
              label: 'Total de Componentes',
              value: statistics!.totalComponents.toString(),
              icon: Icons.inventory,
              color: Colors.green,
            ),
            const Divider(),
            StatRow(
              label: 'Itens em Estoque',
              value: statistics!.totalStockItems.toString(),
              icon: Icons.storage,
              color: Colors.orange,
            ),
            const Divider(),
            StatRow(
              label: 'Valor Total Investido',
              value: currencyFormat.format(statistics!.totalValue),
              icon: Icons.attach_money,
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
