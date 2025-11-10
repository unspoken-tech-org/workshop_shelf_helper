import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/database/database_helper.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/repositories/category_repository.dart';
import 'package:workshop_shelf_helper/repositories/component_repository.dart';
import 'package:workshop_shelf_helper/repositories/report_repository.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/home_drawer.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/quick_actions_section.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/statistics_cards.dart';

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
          create:
              (_) => ComponentProvider(repository: ComponentRepository(DatabaseHelper.instance)),
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
  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadStatistics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizador de Oficina'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      drawer: const HomeDrawer(),
      body: Selector<ReportProvider, bool>(
        selector: (context, provider) => provider.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return child!;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ReportProvider>().loadStatistics();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Selector<ReportProvider, Statistics?>(
                  selector: (context, provider) => provider.statistics,
                  builder: (context, statistics, child) {
                    return StatisticsCards(statistics: statistics);
                  },
                ),
                const SizedBox(height: 24),
                const QuickActionsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
