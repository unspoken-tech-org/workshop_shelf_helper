import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:workshop_shelf_helper/models/category.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'package:workshop_shelf_helper/models/import_result.dart';
import 'package:workshop_shelf_helper/utils/text_normalizer.dart';
import 'package:workshop_shelf_helper/database/interfaces/i_category_repository.dart';
import 'package:workshop_shelf_helper/database/interfaces/i_component_repository.dart';

class ImportService {
  final ICategoryRepository _categoryRepository;
  final IComponentRepository _componentRepository;

  ImportService({
    required ICategoryRepository categoryRepository,
    required IComponentRepository componentRepository,
  }) : _categoryRepository = categoryRepository,
       _componentRepository = componentRepository;

  /// Parse o arquivo CSV e retorna lista de dados para preview
  Future<List<ImportPreviewData>> parseCSVForPreview(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString(encoding: utf8);

    final rows = const CsvToListConverter().convert(contents);

    if (rows.isEmpty) {
      throw Exception('Arquivo CSV vazio');
    }

    // Primeira linha contém cabeçalhos
    final headers = rows[0].map((h) => normalizeText(h.toString())).toList();

    // Validar colunas obrigatórias
    _validateHeaders(headers);

    final previewData = <ImportPreviewData>[];

    // Processar linhas de dados (pular cabeçalho)
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || _isRowEmpty(row)) continue;

      try {
        final data = _parseRowToPreview(headers, row);
        previewData.add(data);
      } catch (e) {
        // Ignorar linhas com erro no preview
        continue;
      }
    }

    return previewData;
  }

  /// Importa os componentes do arquivo CSV
  Future<ImportResult> importFromCSV(String filePath) async {
    final file = File(filePath);
    final contents = await file.readAsString(encoding: utf8);

    final rows = const CsvToListConverter().convert(contents);

    if (rows.isEmpty) {
      throw Exception('Arquivo CSV vazio');
    }

    final headers = rows[0].map((h) => normalizeText(h.toString())).toList();
    _validateHeaders(headers);

    // Carregar categorias e componentes existentes
    final existingCategories = await _categoryRepository.getAll();
    final existingComponents = await _componentRepository.getAll();

    // Maps para busca rápida
    final categoryMap = <String, Category>{};
    for (var cat in existingCategories) {
      categoryMap[normalizeText(cat.name)] = cat;
    }

    final componentMap = <String, Component>{};
    for (var comp in existingComponents) {
      final key = _makeComponentKey(comp.model, comp.categoryName, comp.location);
      componentMap[key] = comp;
    }

    final errors = <ImportError>[];
    final warnings = <ImportWarning>[];
    final categoriesCreated = <String>[];
    int successCount = 0;
    int updatedCount = 0;

    // Processar cada linha
    for (var i = 1; i < rows.length; i++) {
      final lineNumber = i + 1;
      final row = rows[i];

      if (row.isEmpty || _isRowEmpty(row)) continue;

      try {
        // Extrair dados da linha
        final rowData = _parseRow(headers, row);

        // Validar dados obrigatórios
        final validationError = _validateRowData(rowData);
        if (validationError != null) {
          errors.add(ImportError(lineNumber: lineNumber, message: validationError));
          continue;
        }

        // Garantir que categoria existe
        final categoryName = rowData['category'] as String;
        final categoryDescription = rowData['categoryDescription'] as String?;
        final categoryNormalized = normalizeText(categoryName);

        Category category;
        if (!categoryMap.containsKey(categoryNormalized)) {
          // Criar nova categoria
          category = Category(name: categoryName, description: categoryDescription);
          final categoryId = await _categoryRepository.create(category);
          category.id = categoryId;
          categoryMap[categoryNormalized] = category;
          categoriesCreated.add(categoryName);
          warnings.add(
            ImportWarning(
              lineNumber: lineNumber,
              message: 'Categoria "$categoryName" criada automaticamente',
            ),
          );
        } else {
          category = categoryMap[categoryNormalized]!;
        }

        // Calcular custo unitário
        final quantity = rowData['quantity'] as int;
        double unitCost = rowData['unitCost'] as double? ?? 0.0;
        final totalValue = rowData['totalValue'] as double?;

        if (unitCost == 0.0 && totalValue != null && totalValue > 0.0 && quantity > 0) {
          unitCost = totalValue / quantity;
        }

        // Verificar se componente já existe (modelo + categoria + localização)
        final model = rowData['model'] as String;
        final location = rowData['location'] as String;
        final componentKey = _makeComponentKey(model, category.name, location);

        if (componentMap.containsKey(componentKey)) {
          // Componente duplicado - somar quantidades e recalcular custo médio ponderado
          final existing = componentMap[componentKey]!;
          final newQuantity = existing.quantity + quantity;
          final newUnitCost =
              ((existing.quantity * existing.unitCost) + (quantity * unitCost)) / newQuantity;

          final updatedComponent = existing.copyWith(
            quantity: newQuantity,
            unitCost: newUnitCost,
            polarity: rowData['polarity'] as String? ?? existing.polarity,
            package: rowData['package'] as String? ?? existing.package,
            notes: rowData['notes'] as String? ?? existing.notes,
          );

          await _componentRepository.update(updatedComponent);
          componentMap[componentKey] = updatedComponent;
          updatedCount++;

          warnings.add(
            ImportWarning(
              lineNumber: lineNumber,
              message:
                  'Componente "$model" já existe - quantidade somada (${existing.quantity} + $quantity = $newQuantity)',
            ),
          );
        } else {
          // Criar novo componente
          final component = Component(
            categoryId: category.id!,
            categoryName: category.name,
            model: model,
            quantity: quantity,
            location: location,
            polarity: rowData['polarity'] as String?,
            package: rowData['package'] as String?,
            unitCost: unitCost,
            notes: rowData['notes'] as String?,
          );

          final componentId = await _componentRepository.create(component);
          component.id = componentId;
          componentMap[componentKey] = component;
          successCount++;
        }
      } catch (e) {
        errors.add(ImportError(lineNumber: lineNumber, message: 'Erro ao processar linha: $e'));
      }
    }

    return ImportResult(
      totalLines: rows.length - 1, // Excluir cabeçalho
      successCount: successCount,
      errorCount: errors.length,
      updatedCount: updatedCount,
      categoriesCreated: categoriesCreated,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Gera arquivo CSV template para download
  Future<String> generateTemplate(String filePath) async {
    List<List<dynamic>> rows = [];

    // Cabeçalho
    rows.add([
      'Modelo',
      'Categoria',
      'Descrição Categoria',
      'Polaridade',
      'Encapsulamento',
      'Quantidade',
      'Localização',
      'Custo Unitário',
      'Custo Total',
      'Observação',
    ]);

    // Exemplos
    rows.add([
      'BC547',
      'Transistores',
      'Transistores bipolares',
      'NPN',
      'TO-92',
      100,
      'CX01',
      0.50,
      '',
      '',
    ]);
    rows.add(['10K', 'Resistores', 'Resistores 1/4W', '', '', 200, 'CX02', 0.10, '', '']);
    rows.add(['LM358', 'Circuitos Integrados', 'Op-Amps', '', 'DIP-8', 50, 'CX03', '', 75.00, '']);
    rows.add(['1N4148', 'Diodos', 'Diodos de sinal', '', 'DO-35', 150, 'CX04', 0.15, '', '']);
    rows.add([
      '100uF',
      'Capacitores',
      'Capacitores eletrolíticos',
      '',
      'Radial',
      80,
      'CX05',
      0.30,
      '',
      '',
    ]);

    String csv = const ListToCsvConverter().convert(rows);

    final file = File(filePath);
    await file.writeAsString(csv, encoding: utf8);

    return filePath;
  }

  // ========== Métodos Auxiliares ==========

  void _validateHeaders(List<String> headers) {
    final requiredColumns = ['modelo', 'categoria', 'quantidade'];

    for (var col in requiredColumns) {
      if (!headers.contains(col)) {
        throw Exception('Coluna obrigatória "$col" não encontrada no CSV');
      }
    }

    // Validar que existe coluna de localização (aceita 'localizacao' ou 'caixa' para compatibilidade)
    if (!headers.contains('localizacao') && !headers.contains('caixa')) {
      throw Exception('Coluna obrigatória "Localização" ou "Caixa" não encontrada no CSV');
    }

    // Validar que existe pelo menos uma coluna de custo
    if (!headers.contains('custo unitario') && !headers.contains('custo total')) {
      throw Exception('É necessário ter pelo menos uma coluna: "Custo Unitário" ou "Custo Total"');
    }
  }

  bool _isRowEmpty(List<dynamic> row) {
    return row.every((cell) => cell == null || cell.toString().trim().isEmpty);
  }

  ImportPreviewData _parseRowToPreview(List<String> headers, List<dynamic> row) {
    final rowMap = _parseRow(headers, row);

    return ImportPreviewData(
      model: rowMap['model'] as String,
      category: rowMap['category'] as String,
      categoryDescription: rowMap['categoryDescription'] as String?,
      polarity: rowMap['polarity'] as String?,
      package: rowMap['package'] as String?,
      quantity: rowMap['quantity'] as int,
      location: rowMap['location'] as String,
      unitCost: _calculateUnitCost(rowMap),
      notes: rowMap['notes'] as String?,
    );
  }

  Map<String, dynamic> _parseRow(List<String> headers, List<dynamic> row) {
    final result = <String, dynamic>{};

    for (var i = 0; i < headers.length && i < row.length; i++) {
      final header = headers[i];
      final value = row[i]?.toString().trim() ?? '';

      switch (header) {
        case 'modelo':
          result['model'] = value;
          break;
        case 'categoria':
          result['category'] = value;
          break;
        case 'descricao categoria':
          result['categoryDescription'] = value.isEmpty ? null : value;
          break;
        case 'polaridade':
          result['polarity'] = value.isEmpty ? null : value;
          break;
        case 'encapsulamento':
          result['package'] = value.isEmpty ? null : value;
          break;
        case 'quantidade':
          result['quantity'] = value.isEmpty ? 0 : int.tryParse(value) ?? 0;
          break;
        case 'caixa':
        case 'localizacao':
          result['location'] = value;
          break;
        case 'custo unitario':
          result['unitCost'] = value.isEmpty ? null : double.tryParse(value.replaceAll(',', '.'));
          break;
        case 'custo total':
          result['totalValue'] = value.isEmpty ? null : double.tryParse(value.replaceAll(',', '.'));
          break;
        case 'observacao':
        case 'observacoes':
        case 'notas':
          result['notes'] = value.isEmpty ? null : value;
          break;
      }
    }

    return result;
  }

  double _calculateUnitCost(Map<String, dynamic> rowData) {
    final quantity = rowData['quantity'] as int;
    double unitCost = rowData['unitCost'] as double? ?? 0.0;
    final totalValue = rowData['totalValue'] as double?;

    if (unitCost == 0.0 && totalValue != null && totalValue > 0.0 && quantity > 0) {
      unitCost = totalValue / quantity;
    }

    return unitCost;
  }

  String? _validateRowData(Map<String, dynamic> rowData) {
    if ((rowData['model'] as String?)?.isEmpty ?? true) {
      return 'Campo "Modelo" é obrigatório';
    }
    if ((rowData['category'] as String?)?.isEmpty ?? true) {
      return 'Campo "Categoria" é obrigatório';
    }
    if ((rowData['quantity'] as int?) == null || (rowData['quantity'] as int) < 0) {
      return 'Campo "Quantidade" inválido';
    }
    if ((rowData['location'] as String?)?.isEmpty ?? true) {
      return 'Campo "Caixa" (localização) é obrigatório';
    }

    final unitCost = rowData['unitCost'] as double?;
    final totalValue = rowData['totalValue'] as double?;

    if ((unitCost == null || unitCost == 0.0) && (totalValue == null || totalValue == 0.0)) {
      return 'É necessário informar "Custo Unitário" ou "Custo Total"';
    }

    return null;
  }

  String _makeComponentKey(String model, String categoryName, String location) {
    return '${normalizeText(model)}_${normalizeText(categoryName)}_${normalizeText(location)}';
  }
}
