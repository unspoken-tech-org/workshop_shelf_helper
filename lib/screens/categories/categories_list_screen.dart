import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/component_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/category.dart';
import 'category_form_screen.dart';
import '../../widgets/confirm_dialog.dart';
import 'widgets/category_card.dart';

class CategoriesListScreen extends StatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  State<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends State<CategoriesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
  }

  void _loadCategories() {
    context.read<CategoryProvider>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          Selector<CategoryProvider, ({bool isLoading, String? error, List<Category> categories})>(
            selector:
                (context, provider) => (
                  isLoading: provider.isLoading,
                  error: provider.error,
                  categories: provider.categories,
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
                        onPressed: _loadCategories,
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              if (state.categories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma categoria cadastrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no botão + para adicionar',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadCategories(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final category = state.categories[index];
                    return CategoryCard(
                      category: category,
                      onEdit: () => _navigateToForm(context, category: category),
                      onDelete: () => _confirmDeletion(context, category),
                    );
                  },
                ),
              );
            },
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _navigateToForm(BuildContext context, {Category? category}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
                ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
                ChangeNotifierProvider.value(value: context.read<ReportProvider>()),
              ],
              child: CategoryFormScreen(category: category),
            ),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _confirmDeletion(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => ConfirmDialog(
            title: 'Excluir Categoria',
            content:
                'Tem certeza que deseja excluir a categoria "${category.name}"?\n\n'
                'ATENÇÃO: Todos os componentes desta categoria também serão excluídos!',
            confirmText: 'Excluir',
            cancelText: 'Cancelar',
          ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<CategoryProvider>().deleteCategory(category.id!);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Categoria excluída com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir categoria'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
