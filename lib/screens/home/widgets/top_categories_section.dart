import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/models/category_stock.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';

class TopCategoriesSection extends StatelessWidget {
  const TopCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💰 Top 3 Categorias (por Valor)',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Selector<ReportProvider, List<CategoryStock>>(
          selector: (context, provider) => provider.topCategoriesByValue,
          builder: (context, topCategories, child) {
            if (topCategories.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhum componente cadastrado',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Card(
              child: Column(
                children:
                    topCategories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      final position = index + 1;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getPositionColor(position),
                          child: Text(
                            '$positionº',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        title: Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${category.componentCount} tipos • ${category.itemQuantity} itens',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        trailing: Text(
                          currencyFormat.format(category.totalValue),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getPositionColor(position),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.amber.shade700; // Ouro
      case 2:
        return Colors.grey.shade600; // Prata
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.blue;
    }
  }
}
