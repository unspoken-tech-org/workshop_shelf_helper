import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/categories/categories_list_screen.dart';
import 'package:workshop_shelf_helper/screens/components/components_list_screen.dart';
import 'package:workshop_shelf_helper/screens/import/import_screen.dart';
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
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.onPrimaryFixed),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/images/logo.png', width: 100, height: 100),
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
            leading: Icon(Icons.home, color: Theme.of(context).colorScheme.onSecondaryContainer),
            title: Text('Home',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading:
                Icon(Icons.category, color: Theme.of(context).colorScheme.onSecondaryContainer),
            title: Text('Categorias',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
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
            leading:
                Icon(Icons.inventory, color: Theme.of(context).colorScheme.onSecondaryContainer),
            title: Text('Componentes',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
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
            leading:
                Icon(Icons.assessment, color: Theme.of(context).colorScheme.onSecondaryContainer),
            title: Text('Relatórios',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
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
          ListTile(
            leading: Icon(Icons.import_export,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
            title: Text('Importar Dados',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
                      ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
                      ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                    ],
                    child: const ImportScreen(),
                  ),
                ),
              ).then((_) {
                context.read<ReportProvider>().loadDashboardData();
              });
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.system_update,
                color: Theme.of(context).colorScheme.onSecondaryContainer),
            title: Text('Verificar Atualizações',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer)),
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
      builder: (context) => const Center(
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
