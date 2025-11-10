import 'package:flutter/material.dart';

class ExportOptionsSection extends StatelessWidget {
  final VoidCallback onExportCSV;
  final VoidCallback onExportPDF;
  final VoidCallback onShowLowStock;

  const ExportOptionsSection({
    super.key,
    required this.onExportCSV,
    required this.onExportPDF,
    required this.onShowLowStock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.table_chart, color: Colors.green),
            ),
            title: const Text('Exportar para CSV'),
            subtitle: const Text('Exportar lista completa de componentes'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onExportCSV,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.red),
            ),
            title: const Text('Exportar para PDF'),
            subtitle: const Text('Gerar relatório completo em PDF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onExportPDF,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.orange),
            ),
            title: const Text('Componentes com Baixo Estoque'),
            subtitle: const Text('Ver itens com quantidade menor que 10'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onShowLowStock,
          ),
        ),
      ],
    );
  }
}
