import 'package:flutter/foundation.dart' hide Category;
import 'package:workshop_shelf_helper/database/interfaces/i_category_repository.dart';
import 'package:workshop_shelf_helper/models/category.dart';

class CategoryProvider with ChangeNotifier {
  final ICategoryRepository _repository;
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  CategoryProvider({required ICategoryRepository repository}) : _repository = repository;

  List<Category> get categories => _categories;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ICategoryRepository get repository => _repository;

  void loadCategories() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getAll()
        .then((categories) {
          _categories = categories;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar categorias: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  Future<bool> addCategory(Category category) async {
    try {
      final id = await _repository.create(category);
      category.id = id;
      _categories.add(category);
      _categories.sort((a, b) => a.name.compareTo(b.name));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao adicionar categoria: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await _repository.update(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        _categories.sort((a, b) => a.name.compareTo(b.name));
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar categoria: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      await _repository.delete(id);
      _categories.removeWhere((c) => c.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao deletar categoria: $e';
      notifyListeners();
      return false;
    }
  }

  void getCategoryById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedCategory = await _repository.getById(id);
    } catch (e) {
      _error = 'Erro ao carregar categoria: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
