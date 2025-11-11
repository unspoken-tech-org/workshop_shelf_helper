import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/database/database_helper.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/categories/categories_list_screen.dart';
import 'package:workshop_shelf_helper/screens/components/components_list_screen.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/action_button.dart';
import 'package:workshop_shelf_helper/screens/reports/reports_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ActionButton(
          title: 'Gerenciar Categorias',
          icon: Icons.category,
          color: Colors.blue,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
                          ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
                          ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                        ],
                        child: const CategoriesListScreen(),
                      ),
                ),
              ).then((_) => context.read<ReportProvider>().loadDashboardData()),
        ),
        const SizedBox(height: 12),
        ActionButton(
          title: 'Gerenciar Componentes',
          icon: Icons.inventory,
          color: Colors.green,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
                          ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
                          ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                        ],
                        child: const ComponentsListScreen(),
                      ),
                ),
              ).then((_) => context.read<ReportProvider>().loadDashboardData()),
        ),
        const SizedBox(height: 12),
        ActionButton(
          title: 'Ver Relatórios',
          icon: Icons.assessment,
          color: Colors.purple,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
                          ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
                          ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                        ],
                        child: const ReportsScreen(),
                      ),
                ),
              ).then((_) => context.read<ReportProvider>().loadDashboardData()),
        ),
        // Debug button - only shows in debug mode
        if (kDebugMode) ...[
          const SizedBox(height: 12),
          ActionButton(
            title: '🔧 Resetar com Dados Mock',
            icon: Icons.refresh,
            color: Colors.orange,
            onTap: () {
              resetWithMockData(context);
            },
          ),
        ],
      ],
    );
  }
}

Future<void> resetWithMockData(BuildContext context) async {
  // Show confirmation dialog
  final confirmed = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('⚠️ Confirmar Ação'),
          content: const Text(
            'Esta ação irá APAGAR TODOS OS DADOS do banco e '
            'repopular com dados de exemplo.\n\n'
            'Deseja continuar?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        ),
  );

  if (confirmed != true) return;

  try {
    // Show loading
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Resetando banco de dados...'),
                    ],
                  ),
                ),
              ),
            ),
      );
    }

    // Reset database with mock data
    await DatabaseHelper.instance.resetWithMockData();

    // Reload data
    if (context.mounted) {
      context.read<ReportProvider>().loadDashboardData();
    }

    // Close loading
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Show success
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Banco resetado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  } catch (e) {
    // Close loading if open
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao resetar banco: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
