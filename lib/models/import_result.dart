class ImportResult {
  final int totalLines;
  final int successCount;
  final int errorCount;
  final int updatedCount;
  final List<String> categoriesCreated;
  final List<ImportError> errors;
  final List<ImportWarning> warnings;

  ImportResult({
    required this.totalLines,
    required this.successCount,
    required this.errorCount,
    required this.updatedCount,
    required this.categoriesCreated,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isSuccess => errorCount == 0;
}

class ImportError {
  final int lineNumber;
  final String message;

  ImportError({required this.lineNumber, required this.message});
}

class ImportWarning {
  final int lineNumber;
  final String message;

  ImportWarning({required this.lineNumber, required this.message});
}

class ImportPreviewData {
  final String model;
  final String category;
  final String? categoryDescription;
  final String? polarity;
  final String? package;
  final int quantity;
  final String location;
  final double unitCost;
  final String? notes;

  ImportPreviewData({
    required this.model,
    required this.category,
    this.categoryDescription,
    this.polarity,
    this.package,
    required this.quantity,
    required this.location,
    required this.unitCost,
    this.notes,
  });
}
