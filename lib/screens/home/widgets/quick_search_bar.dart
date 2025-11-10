import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/providers/report_provider.dart';
import 'package:workshop_shelf_helper/screens/components/components_list_screen.dart';

class QuickSearchBar extends StatefulWidget {
  const QuickSearchBar({super.key});

  @override
  State<QuickSearchBar> createState() => _QuickSearchBarState();
}

class _QuickSearchBarState extends State<QuickSearchBar> {
  final _searchController = TextEditingController();
  bool _hasSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasSearch = _searchController.text.isNotEmpty;
    });
  }

  void _handleSearch(BuildContext context) {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) return;

    context.read<ComponentProvider>().filterComponents(searchTerm: searchTerm);

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
              child: ComponentsListScreen(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '🔍 Buscar por modelo ou localização...',
            border: InputBorder.none,
            hoverColor: Colors.transparent,
            fillColor: Colors.grey[50],
            suffixIcon:
                _hasSearch
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _hasSearch = false;
                        setState(() {});
                      },
                    )
                    : IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _handleSearch(context),
                    ),
          ),

          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _handleSearch(context),
        ),
      ),
    );
  }
}
