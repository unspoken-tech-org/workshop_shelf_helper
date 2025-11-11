import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/categories/categories_list_screen.dart';
import 'package:workshop_shelf_helper/screens/components/components_list_screen.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/grid_action_button.dart';
import 'package:workshop_shelf_helper/screens/reports/reports_screen.dart';

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          spacing: 12,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: GridActionButton(
                title: 'Categorias',
                icon: Icons.category,
                color: Colors.blue,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider.value(
                                  value: context.read<CategoryProvider>(),
                                ),
                                ChangeNotifierProvider.value(
                                  value: context.read<ComponentProvider>(),
                                ),
                                ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                              ],
                              child: const CategoriesListScreen(),
                            ),
                      ),
                    ).then((_) => context.read<ReportProvider>().loadDashboardData()),
              ),
            ),
            SizedBox(
              width: 140,
              height: 140,
              child: GridActionButton(
                title: 'Componentes',
                icon: Icons.inventory,
                color: Colors.green,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider.value(
                                  value: context.read<CategoryProvider>(),
                                ),
                                ChangeNotifierProvider.value(
                                  value: context.read<ComponentProvider>(),
                                ),
                                ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                              ],
                              child: const ComponentsListScreen(),
                            ),
                      ),
                    ).then((_) => context.read<ReportProvider>().loadDashboardData()),
              ),
            ),
            SizedBox(
              width: 140,
              height: 140,
              child: GridActionButton(
                title: 'Relatórios',
                icon: Icons.assessment,
                color: Colors.purple,
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider.value(
                                  value: context.read<CategoryProvider>(),
                                ),
                                ChangeNotifierProvider.value(
                                  value: context.read<ComponentProvider>(),
                                ),
                                ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
                              ],
                              child: const ReportsScreen(),
                            ),
                      ),
                    ).then((_) => context.read<ReportProvider>().loadDashboardData()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
