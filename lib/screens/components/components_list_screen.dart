import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:workshop_shelf_helper/models/component_filter.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'component_form_screen.dart';
import 'package:workshop_shelf_helper/widgets/confirm_dialog.dart';
import 'widgets/component_search_bar.dart';
import 'widgets/component_filters.dart';
import 'widgets/component_card.dart';

class ComponentsListScreen extends StatefulWidget {
  const ComponentsListScreen({super.key});

  @override
  State<ComponentsListScreen> createState() => _ComponentsListScreenState();
}

class _ComponentsListScreenState extends State<ComponentsListScreen> {
  final _searchController = TextEditingController();
  late ComponentProvider _componentProvider;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _componentProvider = context.read<ComponentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _componentProvider.init();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Componentes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ComponentSearchBar(
            controller: _searchController,
            onChanged: (value) => _componentProvider.filterComponents(searchTerm: value),
            onClear: () {
              _searchController.clear();
              _componentProvider.filterComponents(searchTerm: '');
            },
          ),
          if (_showFilters) ComponentFilters(searchController: _searchController),
          Expanded(
            child: Selector<
              ComponentProvider,
              ({bool isLoading, String? error, List<Component> components, ComponentFilter filter})
            >(
              selector:
                  (context, provider) => (
                    isLoading: provider.isLoading,
                    error: provider.error,
                    components: provider.components,
                    filter: provider.filter,
                  ),
              builder: (context, state, child) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _componentProvider.filterComponents,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.components.isEmpty) {
                  final hasFilters =
                      state.filter.searchTerm != null || state.filter.categoryId != null;

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          hasFilters
                              ? 'Nenhum componente encontrado'
                              : 'Nenhum componente cadastrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasFilters
                              ? 'Tente ajustar os filtros'
                              : 'Toque no botão + para adicionar',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _componentProvider.filterComponents(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.components.length,
                    itemBuilder: (context, index) {
                      final component = state.components[index];
                      return ComponentCard(
                        component: component,
                        categoryName: component.categoryName,
                        currencyFormat: _currencyFormat,
                        onEdit: () => _navigateToForm(context, component: component),
                        onDelete: () => _confirmDeletion(context, component),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context, {Component? component}) async {
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
              child: ComponentFormScreen(componentId: component?.id),
            ),
      ),
    ).then((_) => _componentProvider.filterComponents());
  }

  Future<void> _confirmDeletion(BuildContext context, Component component) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: 'Excluir Componente',
            content: 'Tem certeza que deseja excluir o componente "${component.model}"?',
            confirmText: 'Excluir',
            cancelText: 'Cancelar',
          ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<ComponentProvider>().deleteComponent(component.id!);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Componente excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao excluir componente'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
