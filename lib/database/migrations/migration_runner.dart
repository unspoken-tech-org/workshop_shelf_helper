import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'migration.dart';
import 'migration_v1.dart';

/// Coordenador de migrations do banco de dados
/// Gerencia execução de migrations na ordem correta
class MigrationRunner {
  /// Lista de todas as migrations disponíveis, ordenadas por versão
  List<Migration> get migrations => [
    MigrationV1(),
    // Adicione futuras migrations aqui:
    // MigrationV2(),
    // MigrationV3(),
  ];

  /// Executa migrations para criar o banco pela primeira vez
  Future<void> onCreate(Database db, int version) async {
    debugPrint('🔧 Executando migrations para versão $version...');

    for (final migration in migrations) {
      if (migration.version <= version) {
        debugPrint('  ✓ Executando migration v${migration.version}');
        await migration.up(db);
      }
    }

    debugPrint('✅ Migrations concluídas com sucesso!');
  }

  /// Executa migrations incrementais ao fazer upgrade do banco
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('🔄 Atualizando banco de v$oldVersion para v$newVersion...');

    for (final migration in migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        debugPrint('  ✓ Executando migration v${migration.version}');
        await migration.up(db);
      }
    }

    debugPrint('✅ Upgrade concluído com sucesso!');
  }

  /// Retorna a versão mais recente disponível
  int get latestVersion {
    if (migrations.isEmpty) return 1;
    return migrations.map((m) => m.version).max;
  }
}
