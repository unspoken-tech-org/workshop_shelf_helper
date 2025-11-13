import 'package:flutter/material.dart';
import 'package:workshop_shelf_helper/models/import_result.dart';

class ImportResultDialog extends StatelessWidget {
  final ImportResult result;
  final VoidCallback? onConfirm;

  const ImportResultDialog({
    super.key,
    required this.result,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    String title;

    if (result.wasExecuted) {
      icon = result.isSuccess ? Icons.check_circle : Icons.warning;
      iconColor = result.isSuccess ? Colors.green : Colors.orange;
      title = 'Resultado da Importação';
    } else if (result.hasErrors) {
      icon = Icons.error;
      iconColor = Colors.red;
      title = 'Erros Encontrados';
    } else {
      icon = Icons.info;
      iconColor = Colors.blue;
      title = 'Validação Concluída';
    }

    return AlertDialog(
      title: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!result.wasExecuted && result.hasErrors) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A importação foi bloqueada devido a erros encontrados. Corrija os problemas no arquivo CSV e tente novamente.',
                          style: TextStyle(
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (!result.wasExecuted && !result.hasErrors) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.blue.shade700, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Nenhum erro encontrado! Clique em "Finalizar Importação" para salvar os dados no sistema.',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              _buildStatisticsSection(),
              if (result.categoriesCreated.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildCategoriesCreatedSection(),
              ],
              if (result.hasWarnings) ...[const SizedBox(height: 24), _buildWarningsSection()],
              if (result.hasErrors) ...[const SizedBox(height: 24), _buildErrorsSection()],
            ],
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (result.wasExecuted) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ];
    } else if (result.hasErrors) {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
          child: const Text('Abortar'),
        ),
      ];
    } else {
      return [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          icon: const Icon(Icons.check),
          label: const Text('Finalizar Importação'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ];
    }
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estatísticas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildStatRow('Total de linhas processadas', result.totalLines.toString()),
          _buildStatRow('Componentes criados', result.successCount.toString(), Colors.green),
          _buildStatRow('Componentes atualizados', result.updatedCount.toString(), Colors.blue),
          if (result.errorCount > 0)
            _buildStatRow('Erros', result.errorCount.toString(), Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesCreatedSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Categorias Criadas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.categoriesCreated.map(
            (cat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 8),
                  const SizedBox(width: 8),
                  Text(cat),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Avisos (${result.warnings.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.warnings.take(10).map(
                (warning) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Linha ${warning.lineNumber}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(warning.message)),
                    ],
                  ),
                ),
              ),
          if (result.warnings.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... e mais ${result.warnings.length - 10} avisos',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.orange.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Erros (${result.errors.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...result.errors.take(10).map(
                (error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Linha ${error.lineNumber}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error.message)),
                    ],
                  ),
                ),
              ),
          if (result.errors.length > 10)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '... e mais ${result.errors.length - 10} erros',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }
}
