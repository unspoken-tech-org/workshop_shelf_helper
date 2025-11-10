import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/models/category.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';

class ComponentFilters extends StatelessWidget {
  final TextEditingController searchController;

  const ComponentFilters({super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Selector<ComponentProvider, int?>(
            selector: (context, provider) => provider.categoryFilter,
            builder: (context, categoryFilter, child) {
              return Selector<CategoryProvider, List<Category>>(
                selector: (context, provider) => provider.categories,
                builder: (context, categories, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int?>(
                          value: categoryFilter,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por categoria',
                            prefixIcon: Icon(Icons.category),
                          ),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('Todas as categorias')),
                            ...categories.map((cat) {
                              return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                            }),
                          ],
                          onChanged: (value) {
                            context.read<ComponentProvider>().filterByCategory(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear_all),
                        tooltip: 'Limpar filtros',
                        onPressed: () {
                          searchController.clear();
                          context.read<ComponentProvider>().clearFilters();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
