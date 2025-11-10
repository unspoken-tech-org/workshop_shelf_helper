import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';
import 'package:workshop_shelf_helper/models/category_stock.dart';
import 'package:workshop_shelf_helper/services/export_service.dart';
import 'widgets/general_summary_card.dart';
import 'widgets/stock_by_category_table.dart';
import 'widgets/export_options_section.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _exportService = ExportService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadAllReports();
    });
  }

  void _loadReports() {
    context.read<ReportProvider>().loadAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Selector<ReportProvider, bool>(
        selector: (context, provider) => provider.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return child!;
        },
        child: RefreshIndicator(
          onRefresh: () async => _loadReports(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumo Geral',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Selector<ReportProvider, Statistics?>(
                  selector: (context, provider) => provider.statistics,
                  builder: (context, statistics, child) {
                    return GeneralSummaryCard(
                      statistics: statistics,
                      currencyFormat: _currencyFormat,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Estoque por Categoria',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Selector<ReportProvider, List<CategoryStock>>(
                  selector: (context, provider) => provider.stockByCategory,
                  builder: (context, stockByCategory, child) {
                    return StockByCategoryTable(
                      stockByCategory: stockByCategory,
                      currencyFormat: _currencyFormat,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Exportar Dados',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ExportOptionsSection(
                  onExportCSV: () => _exportCSV(),
                  onExportPDF: () => _exportPDF(),
                  onShowLowStock: () => _showLowStock(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportCSV() async {
    try {
      final componentProvider = context.read<ComponentProvider>();
      final categoryProvider = context.read<CategoryProvider>();

      final components = componentProvider.components;
      final categories = categoryProvider.categories;

      final filePath = await _exportService.exportToCSV(components, categories);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV exportado com sucesso!\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar CSV: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportPDF() async {
    try {
      final componentProvider = context.read<ComponentProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final reportProvider = context.read<ReportProvider>();

      final components = componentProvider.components;
      final categories = categoryProvider.categories;
      final statistics = reportProvider.statistics;

      if (statistics == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhuma estatística disponível para exportar'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final filePath = await _exportService.exportToPDF(components, categories, {
        'totalCategories': statistics.totalCategories,
        'totalComponents': statistics.totalComponents,
        'totalValue': statistics.totalValue,
        'totalStockItems': statistics.totalStockItems,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF exportado com sucesso!\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showLowStock() async {
    try {
      final componentProvider = context.read<ComponentProvider>();
      final components = componentProvider.components.where((c) => c.quantity <= 10).toList();

      if (!mounted) return;

      if (components.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhum componente com baixo estoque!'),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Componentes com Baixo Estoque'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: components.length,
                  itemBuilder: (context, index) {
                    final comp = components[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange,
                        child: Text(comp.quantity.toString()),
                      ),
                      title: Text(comp.model),
                      subtitle: Text('Local: ${comp.location}'),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar')),
              ],
            ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao buscar componentes: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
