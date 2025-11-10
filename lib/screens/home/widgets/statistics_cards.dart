import 'package:flutter/material.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/stat_card.dart';

class StatisticsCards extends StatelessWidget {
  final Statistics? statistics;

  const StatisticsCards({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics == null) {
      return const Center(child: Text('Nenhuma estatística disponível'));
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Categorias',
          value: statistics!.totalCategories.toString(),
          icon: Icons.category,
          color: Colors.blue,
        ),
        StatCard(
          title: 'Componentes',
          value: statistics!.totalComponents.toString(),
          icon: Icons.inventory,
          color: Colors.green,
        ),
        StatCard(
          title: 'Itens em Estoque',
          value: statistics!.totalStockItems.toString(),
          icon: Icons.storage,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Valor Total',
          value: 'R\$ ${statistics!.totalValue.toStringAsFixed(2)}',
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
      ],
    );
  }
}
