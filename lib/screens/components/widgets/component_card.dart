import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:workshop_shelf_helper/models/category.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'package:workshop_shelf_helper/screens/components/widgets/detail_row.dart';

class ComponentCard extends StatelessWidget {
  final Component component;
  final Category? category;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ComponentCard({
    super.key,
    required this.component,
    required this.category,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.memory, color: Colors.white),
        ),
        title: Text(
          component.model,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (category != null)
              Text(
                category!.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Text('Estoque: ${component.quantity} unidades'),
            Text('Local: ${component.location}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                DetailRow(label: 'Polaridade', value: component.polarity ?? 'N/A'),
                DetailRow(label: 'Encapsulamento', value: component.package ?? 'N/A'),
                DetailRow(
                  label: 'Custo Unitário',
                  value: currencyFormat.format(component.unitCost),
                ),
                DetailRow(label: 'Valor Total', value: currencyFormat.format(component.totalValue)),
                if (component.notes != null && component.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Observação:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(component.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
