/// Resultado da validação de um arquivo CSV
class CsvValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final int rowCount;
  final List<String> headers;
  final String encoding;

  CsvValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.rowCount,
    required this.headers,
    required this.encoding,
  });

  /// Retorna true se há erros (bloqueia importação)
  bool get hasErrors => errors.isNotEmpty;

  /// Retorna true se há avisos (não bloqueiam importação)
  bool get hasWarnings => warnings.isNotEmpty;
}
