import 'package:flutter/foundation.dart';
import 'package:workshop_shelf_helper/database/interfaces/i_component_repository.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'package:workshop_shelf_helper/models/component_filter.dart';

class ComponentProvider with ChangeNotifier {
  final IComponentRepository _repository;
  List<Component> _filteredComponents = [];
  bool _isLoading = false;
  String? _error;

  ComponentFilter _filter = ComponentFilter();
  Component? _selectedComponent;

  ComponentProvider({required IComponentRepository repository}) : _repository = repository;

  ComponentFilter get filter => _filter;
  List<Component> get components => _filteredComponents;
  Component? get selectedComponent => _selectedComponent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  IComponentRepository get repository => _repository;

  void init() {
    _loadComponents();
  }

  void _loadComponents({bool notify = true}) async {
    _isLoading = true;
    _error = null;
    if (notify) notifyListeners();

    try {
      _filteredComponents = await _repository.search(_filter);
    } finally {
      _isLoading = false;
      if (notify) notifyListeners();
    }
  }

  void getById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedComponent = await _repository.getById(id);
    } catch (e) {
      _error = 'Erro ao carregar componente: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addComponent(Component component) async {
    try {
      final id = await _repository.create(component);
      component.id = id;
      _filteredComponents.add(component);
      return true;
    } catch (e) {
      _error = 'Erro ao adicionar componente: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateComponent(Component component) async {
    try {
      await _repository.update(component);
      final index = _filteredComponents.indexWhere((c) => c.id == component.id);
      if (index != -1) {
        _filteredComponents[index] = component;
      }
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar componente: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteComponent(int id) async {
    try {
      await _repository.delete(id);
      _filteredComponents.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      _error = 'Erro ao deletar componente: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateComponentQuantity(int componentId, int newQuantity) async {
    try {
      final component = _filteredComponents.firstWhere((c) => c.id == componentId);
      final updatedComponent = component.copyWith(quantity: newQuantity);
      await _repository.update(updatedComponent);

      final index = _filteredComponents.indexWhere((c) => c.id == componentId);
      if (index != -1) {
        _filteredComponents[index] = updatedComponent;
      }
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar quantidade: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  void filterComponents({
    String? searchTerm,
    int? categoryId,
    double? minCost,
    double? maxCost,
    String? orderBy,
  }) {
    _filter = _filter.copyWith(
      searchTerm: searchTerm,
      categoryId: categoryId,
      minCost: minCost,
      maxCost: maxCost,
      orderBy: orderBy,
    );

    _loadComponents();
  }

  Future<void> clearFilters({bool notify = true}) async {
    _filter.clear();
    _loadComponents(notify: notify);
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
