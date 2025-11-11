import 'package:flutter/material.dart';
import 'package:workshop_shelf_helper/models/component_alert.dart';

class ComponentAlertCard extends StatelessWidget {
  final ComponentAlert alert;
  final VoidCallback onTap;

  const ComponentAlertCard({super.key, required this.alert, required this.onTap});

  Color _getQuantityColor(int quantity) {
    if (quantity <= 3) {
      return Colors.red;
    } else if (quantity < 10) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(right: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: _getQuantityColor(alert.quantity),
                radius: 24,
                child: Text(
                  alert.quantity.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Icon(Icons.warning, color: _getQuantityColor(alert.quantity), size: 28),
              const SizedBox(height: 8),
              Text(
                alert.model,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Local: ${alert.location}',
                style: const TextStyle(fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                alert.categoryName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
