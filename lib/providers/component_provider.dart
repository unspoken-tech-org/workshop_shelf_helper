import 'package:flutter/foundation.dart';
import 'package:workshop_shelf_helper/database/interfaces/i_component_repository.dart';
import 'package:workshop_shelf_helper/models/component.dart';

class ComponentProvider with ChangeNotifier {
  final IComponentRepository _repository;
  List<Component> _components = [];
  List<Component> _filteredComponents = [];
  bool _isLoading = false;
  String? _error;

  String _searchTerm = '';
  int? _categoryFilter;
  double? _minCostFilter;
  double? _maxCostFilter;
  String _orderBy = 'model ASC';

  ComponentProvider({required IComponentRepository repository}) : _repository = repository;

  List<Component> get components => _filteredComponents;
  List<Component> get allComponents => _components;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchTerm => _searchTerm;
  int? get categoryFilter => _categoryFilter;
  String get orderBy => _orderBy;

  void loadComponents() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getAll()
        .then((components) {
          _components = components;
          return _applyFilters();
        })
        .then((_) {
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar componentes: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  Future<bool> addComponent(Component component) async {
    try {
      final id = await _repository.create(component);
      component.id = id;
      _components.add(component);
      await _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao adicionar componente: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateComponent(Component component) async {
    try {
      await _repository.update(component);
      final index = _components.indexWhere((c) => c.id == component.id);
      if (index != -1) {
        _components[index] = component;
        await _applyFilters();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar componente: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComponent(int id) async {
    try {
      await _repository.delete(id);
      _components.removeWhere((c) => c.id == id);
      await _applyFilters();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar componente: $e';
      notifyListeners();
      return false;
    }
  }

  Component? getComponentById(int id) {
    try {
      return _components.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void search(String term) {
    _searchTerm = term;
    _applyFilters()
        .then((_) {
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao buscar: $e';
          notifyListeners();
        });
  }

  void filterByCategory(int? categoryId) {
    _categoryFilter = categoryId;
    _applyFilters()
        .then((_) {
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao filtrar: $e';
          notifyListeners();
        });
  }

  void filterByPrice(double? minCost, double? maxCost) {
    _minCostFilter = minCost;
    _maxCostFilter = maxCost;
    _applyFilters()
        .then((_) {
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao filtrar por preço: $e';
          notifyListeners();
        });
  }

  void sortBy(String orderBy) {
    _orderBy = orderBy;
    _applyFilters()
        .then((_) {
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao ordenar: $e';
          notifyListeners();
        });
  }

  void clearFilters() {
    _searchTerm = '';
    _categoryFilter = null;
    _minCostFilter = null;
    _maxCostFilter = null;
    _orderBy = 'model ASC';
    _applyFilters()
        .then((_) {
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao limpar filtros: $e';
          notifyListeners();
        });
  }

  Future<void> _applyFilters() async {
    try {
      _filteredComponents = await _repository.search(
        searchTerm: _searchTerm.isEmpty ? null : _searchTerm,
        categoryId: _categoryFilter,
        minCost: _minCostFilter,
        maxCost: _maxCostFilter,
        orderBy: _orderBy,
      );
    } catch (e) {
      _error = 'Erro ao aplicar filtros: $e';
      _filteredComponents = [];
    }
  }

  Future<List<Component>> getComponentsByCategory(int categoryId) async {
    try {
      return await _repository.getByCategory(categoryId);
    } catch (e) {
      _error = 'Erro ao buscar componentes da categoria: $e';
      return [];
    }
  }

  Future<List<Component>> getLowStockComponents(int threshold) async {
    try {
      return await _repository.getLowStock(threshold);
    } catch (e) {
      _error = 'Erro ao buscar componentes com baixo estoque: $e';
      return [];
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
