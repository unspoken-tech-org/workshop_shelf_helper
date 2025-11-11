import 'package:flutter/foundation.dart';
import 'package:workshop_shelf_helper/database/interfaces/i_report_repository.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';
import 'package:workshop_shelf_helper/models/component_alert.dart';
import 'package:workshop_shelf_helper/models/category_stock.dart';

class ReportProvider with ChangeNotifier {
  final IReportRepository _repository;

  double _totalStockValue = 0.0;
  Statistics? _statistics;
  List<CategoryStock> _stockByCategory = [];
  List<ComponentAlert> _lowStockComponents = [];
  List<ComponentAlert> _outOfStockComponents = [];
  List<CategoryStock> _topCategoriesByValue = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMoreLowStockItems = true;

  ReportProvider({required IReportRepository repository}) : _repository = repository;

  double get totalStockValue => _totalStockValue;
  Statistics? get statistics => _statistics;
  List<CategoryStock> get stockByCategory => _stockByCategory;
  List<ComponentAlert> get lowStockComponents => _lowStockComponents;
  int get lowStockCount => _lowStockComponents.length;
  List<ComponentAlert> get outOfStockComponents => _outOfStockComponents;
  int get outOfStockCount => _outOfStockComponents.length;
  List<CategoryStock> get topCategoriesByValue => _topCategoriesByValue;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreLowStockItems => _hasMoreLowStockItems;
  String? get error => _error;

  void loadTotalStockValue() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _totalStockValue = await _repository.getTotalStockValue();
    } catch (e) {
      _error = 'Erro ao carregar valor total do estoque: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _statistics = await _repository.getStatistics();
    } catch (e) {
      _error = 'Erro ao carregar estatísticas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadStockByCategory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stockByCategory = await _repository.getStockByCategory();
    } catch (e) {
      _error = 'Erro ao carregar estoque por categoria: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _totalStockValue = await _repository.getTotalStockValue();
      _statistics = await _repository.getStatistics();
      _stockByCategory = await _repository.getStockByCategory();
    } catch (e) {
      _error = 'Erro ao carregar relatórios: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadDashboardData() async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMoreLowStockItems = true;
    notifyListeners();

    try {
      _statistics = await _repository.getStatistics();
      _lowStockComponents = await _repository.getLowStockComponentsPaginated(10, 0, _pageSize);
      _hasMoreLowStockItems = _lowStockComponents.length == _pageSize;
      _outOfStockComponents = await _repository.getOutOfStockComponents();
      _topCategoriesByValue = await _repository.getTopCategoriesByValue(3);
    } catch (e) {
      _error = 'Erro ao carregar dados do dashboard: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreLowStockComponents() async {
    if (_isLoadingMore || !_hasMoreLowStockItems) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final offset = _currentPage * _pageSize;
      final newComponents = await _repository.getLowStockComponentsPaginated(10, offset, _pageSize);

      _lowStockComponents.addAll(newComponents);
      _hasMoreLowStockItems = newComponents.length == _pageSize;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar mais componentes: $e';
      _isLoadingMore = false;
      _currentPage--;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
