import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/categories/categories_list_screen.dart';
import 'package:workshop_shelf_helper/screens/components/components_list_screen.dart';
import 'package:workshop_shelf_helper/screens/reports/reports_screen.dart';
import 'package:workshop_shelf_helper/services/update_service.dart';
import 'package:workshop_shelf_helper/widgets/update_dialog.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.inventory_2, size: 48, color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(height: 8),
                Text(
                  'Organizador de Oficina',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categorias'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Componentes'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text('Relatórios'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
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
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Atualizar Dados'),
            onTap: () {
              Navigator.pop(context);
              context.read<ReportProvider>().loadDashboardData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.system_update),
            title: const Text('Verificar Atualizações'),
            onTap: () {
              Navigator.pop(context);
              _checkForUpdates(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    final updateService = UpdateService();

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
                    Text('Verificando atualizações...'),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      final updateInfo = await updateService.checkForUpdates();

      if (context.mounted) {
        Navigator.of(context).pop();

        if (updateInfo != null) {
          await UpdateDialog.show(context, updateInfo, updateService);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível verificar atualizações'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao verificar atualizações: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
