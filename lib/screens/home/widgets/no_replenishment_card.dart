import 'package:flutter/material.dart';

class NoReplenishmentCard extends StatelessWidget {
  const NoReplenishmentCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
}
