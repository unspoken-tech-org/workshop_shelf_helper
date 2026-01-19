import 'package:flutter/material.dart';
import '../models/database_migration_result.dart';

/// Diálogo que informa o usuário sobre a necessidade de migrar o banco de dados
class MigrationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final bool isMigrating;
  final DatabaseMigrationResult? result;

  const MigrationDialog({
    super.key,
    required this.onConfirm,
    this.isMigrating = false,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isMigrating,
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.storage, color: Colors.blue),
            SizedBox(width: 10),
            Text('Otimização Necessária'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result == null && !isMigrating) ...[
              const Text(
                'Detectamos que seu banco de dados está em um local com restrições de acesso (Program Files).',
              ),
              const SizedBox(height: 10),
              const Text(
                'Para que a importação de CSV e outras funções funcionem corretamente, precisamos mover o banco de dados para sua pasta de usuário.',
              ),
              const SizedBox(height: 10),
              const Text(
                'Deseja realizar esta migração agora? Seus dados serão preservados.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ] else if (isMigrating) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Movendo banco de dados...'),
                    Text('Por favor, não feche o aplicativo.', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ] else if (result != null) ...[
              if (result!.success) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 48),
                const SizedBox(height: 16),
                const Text('Migração concluída com sucesso!'),
              ] else ...[
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text('Falha na migração: ${result!.error}'),
                const SizedBox(height: 10),
                const Text('O aplicativo continuará em modo somente leitura.'),
              ],
            ],
          ],
        ),
        actions: [
          if (!isMigrating && result == null) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Depois'),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Migrar Agora'),
            ),
          ] else if (result != null) ...[
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        ],
      ),
    );
  }
}
