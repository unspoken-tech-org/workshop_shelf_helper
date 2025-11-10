import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/extensions/double_extensions.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/dashboard_card.dart';

class DashboardSummaryCards extends StatelessWidget {
  const DashboardSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumo Geral',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Selector<
          ReportProvider,
          ({Statistics? statistics, int lowStockCount, int outOfStockCount})
        >(
          selector:
              (context, provider) => (
                statistics: provider.statistics,
                lowStockCount: provider.lowStockCount,
                outOfStockCount: provider.outOfStockCount,
              ),
          builder: (context, data, child) {
            final statistics = data.statistics;

            if (statistics == null) {
              return const Center(child: Text('Nenhuma estatística disponível'));
            }

            return GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                DashboardCard(
                  title: 'Valor Total',
                  value: statistics.totalValue.toCurrency(),
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                DashboardCard(
                  title: 'Itens em Estoque',
                  value: statistics.totalStockItems.toString(),
                  icon: Icons.inventory,
                  color: Colors.blue,
                ),
                DashboardCard(
                  title: 'Esgotados',
                  value: data.outOfStockCount.toString(),
                  icon: Icons.block,
                  color: Colors.red,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
