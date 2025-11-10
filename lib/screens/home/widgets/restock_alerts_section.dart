import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/models/component_alert.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/reports/reports_screen.dart';

class RestockAlertsSection extends StatelessWidget {
  const RestockAlertsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '⚠️ Alertas de Reposição',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Selector<ReportProvider, List<ComponentAlert>>(
          selector: (context, provider) => provider.lowStockComponents,
          builder: (context, lowStockComponents, child) {
            if (lowStockComponents.isEmpty) {
              return Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Estoque OK! Nenhum item necessita reposição.',
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final itemsToShow = lowStockComponents.take(5).toList();
            final hasMore = lowStockComponents.length > 5;

            return Column(
              children: [
                ...itemsToShow.map(
                  (alert) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getQuantityColor(alert.quantity),
                        child: Text(
                          alert.quantity.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(alert.model, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Local: ${alert.location}'),
                          Text(
                            alert.categoryName,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.warning, color: _getQuantityColor(alert.quantity)),
                    ),
                  ),
                ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider.value(
                                      value: context.read<CategoryProvider>(),
                                    ),
                                    ChangeNotifierProvider.value(
                                      value: context.read<ComponentProvider>(),
                                    ),
                                    ChangeNotifierProvider.value(
                                      value: context.read<ReportProvider>(),
                                    ),
                                  ],
                                  child: const ReportsScreen(),
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: Text('Ver todos (${lowStockComponents.length} itens)'),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Color _getQuantityColor(int quantity) {
    if (quantity <= 3) {
      return Colors.red;
    } else if (quantity < 10) {
      return Colors.orange;
    }
    return Colors.green;
  }
}
