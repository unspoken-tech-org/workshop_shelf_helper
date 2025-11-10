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
  String? _error;

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
  String? get error => _error;

  void loadTotalStockValue() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getTotalStockValue()
        .then((value) {
          _totalStockValue = value;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar valor total do estoque: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  void loadStatistics() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getStatistics()
        .then((statisticsData) {
          _statistics = statisticsData;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar estatísticas: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  void loadStockByCategory() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getStockByCategory()
        .then((stock) {
          _stockByCategory = stock;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar estoque por categoria: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  void loadAllReports() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getTotalStockValue()
        .then((value) {
          _totalStockValue = value;
          return _repository.getStatistics();
        })
        .then((statisticsData) {
          _statistics = statisticsData;
          return _repository.getStockByCategory();
        })
        .then((stock) {
          _stockByCategory = stock;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar relatórios: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  void loadDashboardData() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _repository
        .getStatistics()
        .then((statisticsData) {
          _statistics = statisticsData;
          return _repository.getLowStockComponents(10); // threshold = 10 (RN015)
        })
        .then((lowStock) {
          _lowStockComponents = lowStock;
          return _repository.getOutOfStockComponents();
        })
        .then((outOfStock) {
          _outOfStockComponents = outOfStock;
          return _repository.getTopCategoriesByValue(3);
        })
        .then((topCategories) {
          _topCategoriesByValue = topCategories;
          _isLoading = false;
          notifyListeners();
        })
        .catchError((e) {
          _error = 'Erro ao carregar dados do dashboard: $e';
          _isLoading = false;
          notifyListeners();
        });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
