import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/models/component_alert.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/components/component_form_screen.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/component_alert_card.dart';
import 'package:workshop_shelf_helper/screens/home/widgets/no_replenishment_card.dart';

class RestockAlertsSection extends StatefulWidget {
  const RestockAlertsSection({super.key});

  @override
  State<RestockAlertsSection> createState() => _RestockAlertsSectionState();
}

class _RestockAlertsSectionState extends State<RestockAlertsSection> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<ReportProvider>();
      if (!provider.isLoadingMore && provider.hasMoreLowStockItems) {
        provider.loadMoreLowStockComponents();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        Text(
          '⚠️ Alertas de Reposição',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Selector<
          ReportProvider,
          ({List<ComponentAlert> components, bool isLoadingMore, bool hasMore})
        >(
          selector:
              (context, provider) => (
                components: provider.lowStockComponents,
                isLoadingMore: provider.isLoadingMore,
                hasMore: provider.hasMoreLowStockItems,
              ),
          builder: (context, data, child) {
            if (data.components.isEmpty && !data.isLoadingMore) {
              return const NoReplenishmentCard();
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: data.components.length + (data.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= data.components.length) {
                    return const SizedBox(
                      width: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final component = data.components[index];

                  return SizedBox(
                    width: 200,
                    height: 200,
                    child: ComponentAlertCard(
                      alert: component,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider.value(
                                      value: context.read<ComponentProvider>(),
                                    ),
                                    ChangeNotifierProvider.value(
                                      value: context.read<CategoryProvider>(),
                                    ),
                                    ChangeNotifierProvider.value(
                                      value: context.read<ReportProvider>(),
                                    ),
                                  ],
                                  child: ComponentFormScreen(componentId: component.id),
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
