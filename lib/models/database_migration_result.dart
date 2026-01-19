/// Resultado da migração de banco de dados
class DatabaseMigrationResult {
  final bool success;
  final String oldPath;
  final String newPath;
  final int databaseSize;
  final Duration duration;
  final String? error;
  final String? backupPath;

  DatabaseMigrationResult({
    required this.success,
    required this.oldPath,
    required this.newPath,
    required this.databaseSize,
    required this.duration,
    this.error,
    this.backupPath,
  });

  /// Retorna true se houve erro durante a migração
  bool get hadError => error != null;
}
