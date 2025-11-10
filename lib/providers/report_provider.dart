import 'package:flutter/foundation.dart';
import 'package:workshop_shelf_helper/database/interfaces/i_report_repository.dart';
import 'package:workshop_shelf_helper/models/statistics.dart';

class ReportProvider with ChangeNotifier {
  final IReportRepository _repository;

  double _totalStockValue = 0.0;
  Statistics? _statistics;
  List<Map<String, dynamic>> _stockByCategory = [];

  bool _isLoading = false;
  String? _error;

  ReportProvider({required IReportRepository repository}) : _repository = repository;

  double get totalStockValue => _totalStockValue;
  Statistics? get statistics => _statistics;
  List<Map<String, dynamic>> get stockByCategory => _stockByCategory;
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
          _statistics = Statistics.fromMap(statisticsData);
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
          _statistics = Statistics.fromMap(statisticsData);
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
