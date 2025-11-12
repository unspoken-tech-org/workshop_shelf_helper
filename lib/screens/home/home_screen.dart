import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/database/database_helper.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/repositories/category_repository.dart';
import 'package:workshop_shelf_helper/repositories/component_repository.dart';
import 'package:workshop_shelf_helper/repositories/report_repository.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/action_button.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/home_drawer.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/quick_search_bar.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/restock_alerts_section.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/dashboard_summary_cards.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/top_categories_section.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/quick_actions_section.dart';
import 'package:workshop_shelf_helper/services/update_service.dart';
import 'package:workshop_shelf_helper/widgets/update_dialog.dart';

class HomeScreenMultiProvider extends StatelessWidget {
  const HomeScreenMultiProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(repository: CategoryRepository(DatabaseHelper.instance)),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ComponentProvider(repository: ComponentRepository(DatabaseHelper.instance)),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportProvider(repository: ReportRepository(DatabaseHelper.instance)),
        ),
      ],
      child: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadDashboardData();
      _checkForUpdatesOnStartup();
    });
  }

  Future<void> _checkForUpdatesOnStartup() async {
    try {
      final updateService = UpdateService();

      final updateInfo = await updateService.checkForUpdates();

      if (mounted && updateInfo != null && updateInfo.hasUpdate) {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          await UpdateDialog.show(context, updateInfo, updateService);
        }
      }
    } catch (e) {
      debugPrint('Erro ao verificar atualizações automaticamente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const HomeDrawer(),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 48, left: 8, right: 8),
            child: Selector<ReportProvider, bool>(
              selector: (context, provider) => provider.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return child!;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<ReportProvider>().loadDashboardData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const QuickSearchBar(),
                      const RestockAlertsSection(),
                      const QuickActionsSection(),
                      const DashboardSummaryCards(),
                      const TopCategoriesSection(),
                      if (kDebugMode) ...[
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
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> resetWithMockData(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
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
    if (context.mounted) {
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
                  Text('Resetando banco de dados...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await DatabaseHelper.instance.resetWithMockData();

    if (context.mounted) {
      context.read<ReportProvider>().loadDashboardData();
    }

    if (context.mounted) {
      Navigator.pop(context);
    }

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
    if (context.mounted) {
      Navigator.pop(context);
    }

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
