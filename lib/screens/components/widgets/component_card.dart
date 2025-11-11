import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/screens/components/widgets/detail_row.dart';
import 'package:workshop_shelf_helper/screens/components/widgets/quantity_control.dart';

class ComponentCard extends StatelessWidget {
  final Component component;
  final String categoryName;
  final NumberFormat currencyFormat;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ComponentCard({
    super.key,
    required this.component,
    required this.categoryName,
    required this.currencyFormat,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: const Icon(Icons.memory, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          component.model,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text('Local: ${component.location}'),
            const SizedBox(height: 4),
            QuantityControl(
              initialQuantity: component.quantity,
              componentId: component.id!,
              onQuantityChange: (componentId, newQuantity) {
                context.read<ComponentProvider>().updateComponentQuantity(componentId, newQuantity);
              },
            ),
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
