import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_helper.dart';
import '../models/database_migration_result.dart';
import '../utils/path_helper.dart';
import '../utils/migration_logger.dart';


/// Serviço responsável por migrar o banco de dados de locais protegidos
/// para locais com permissão de escrita (%LOCALAPPDATA%)
class DatabaseMigrationService {
  static bool _ffiInitialized = false;

  final DatabaseHelper _dbHelper;

  DatabaseMigrationService({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  /// Verifica se a migração é necessária
  /// Retorna true se o banco estiver em Program Files e ainda não existir no destino
  Future<bool> checkMigrationNeeded() async {
    final currentPath = await _dbHelper.getCurrentDatabasePath();
    final isReadOnly = PathHelper.isReadOnlyLocation(currentPath);
    
    if (!isReadOnly) return false;

    final targetPath = await PathHelper.getDatabasePath();
    final targetFile = File(targetPath);
    
    final needed = !await targetFile.exists();
    if (needed) {
      await MigrationLogger.log('Migração necessária detectada. Origem: $currentPath, Destino: $targetPath');
    }
    return needed;
  }

  /// Executa a migração do banco de dados
  Future<DatabaseMigrationResult> migrateDatabase() async {
    final startTime = DateTime.now();
    final oldPath = await _dbHelper.getCurrentDatabasePath();
    final newPath = await PathHelper.getDatabasePath();
    String? backupPath;
    int databaseSize = 0;

    await MigrationLogger.log('Iniciando migração de $oldPath para $newPath');

    try {
      final oldFile = File(oldPath);
      if (!await oldFile.exists()) {
        await MigrationLogger.log('ERRO: Banco de dados de origem não encontrado');
        return DatabaseMigrationResult(
          success: false,
          oldPath: oldPath,
          newPath: newPath,
          databaseSize: 0,
          duration: DateTime.now().difference(startTime),
          error: 'Banco de dados de origem não encontrado',
        );
      }

      databaseSize = await oldFile.length();

      // 1. Fechar conexão se estiver aberta
      await MigrationLogger.log('Fechando conexão com o banco...');
      await _dbHelper.close();

      // 2. Verificar integridade da origem (opcional mas recomendado)
      await MigrationLogger.log('Verificando integridade da origem...');
      final isOriginalHealthy = await _checkDatabaseIntegrity(oldPath);
      if (!isOriginalHealthy) {
         await MigrationLogger.log('ERRO: Banco de origem corrompido');
         return DatabaseMigrationResult(
          success: false,
          oldPath: oldPath,
          newPath: newPath,
          databaseSize: databaseSize,
          duration: DateTime.now().difference(startTime),
          error: 'Banco de dados de origem parece estar corrompido',
        );
      }

      // 3. Criar backup no diretório de destino (onde temos permissão)
      backupPath = '$newPath.backup_${DateTime.now().millisecondsSinceEpoch}';
      await MigrationLogger.log('Criando backup em $backupPath');
      await oldFile.copy(backupPath);

      // 4. Copiar para o destino final
      await MigrationLogger.log('Copiando arquivo para $newPath');
      await oldFile.copy(newPath);

      // 5. Verificar integridade da cópia
      await MigrationLogger.log('Verificando integridade da cópia...');
      final isCopyHealthy = await _checkDatabaseIntegrity(newPath);
      if (!isCopyHealthy) {
        await MigrationLogger.log('ERRO: Falha na integridade da cópia. Iniciando rollback.');
        await _rollback(newPath, backupPath);
        return DatabaseMigrationResult(
          success: false,
          oldPath: oldPath,
          newPath: newPath,
          databaseSize: databaseSize,
          duration: DateTime.now().difference(startTime),
          error: 'Falha na verificação de integridade da cópia',
          backupPath: backupPath,
        );
      }

      // 6. Comparar tamanhos
      final newFile = File(newPath);
      if (await newFile.length() != databaseSize) {
        await MigrationLogger.log('ERRO: Tamanho do banco migrado difere do original. Iniciando rollback.');
        await _rollback(newPath, backupPath);
         return DatabaseMigrationResult(
          success: false,
          oldPath: oldPath,
          newPath: newPath,
          databaseSize: databaseSize,
          duration: DateTime.now().difference(startTime),
          error: 'Tamanho do banco migrado difere do original',
          backupPath: backupPath,
        );
      }

      // 7. Deletar backup após sucesso
      final bkpFile = File(backupPath);
      if (await bkpFile.exists()) {
        await bkpFile.delete();
      }

      await MigrationLogger.log('Migração concluída com sucesso em ${DateTime.now().difference(startTime).inMilliseconds}ms');

      return DatabaseMigrationResult(
        success: true,
        oldPath: oldPath,
        newPath: newPath,
        databaseSize: databaseSize,
        duration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      await MigrationLogger.log('ERRO FATAL: $e');
      if (backupPath != null) await _rollback(newPath, backupPath);
      return DatabaseMigrationResult(
        success: false,
        oldPath: oldPath,
        newPath: newPath,
        databaseSize: databaseSize,
        duration: DateTime.now().difference(startTime),
        error: e.toString(),
      );
    }
  }

  void _ensureFfiInitialized() {
    if (!_ffiInitialized && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiInitialized = true;
    }
  }

  /// Verifica a integridade do banco usando PRAGMA integrity_check
  Future<bool> _checkDatabaseIntegrity(String dbPath) async {
    Database? tempDb;
    try {
      _ensureFfiInitialized();
      tempDb = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(readOnly: true),
      );
      
      final result = await tempDb.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first['integrity_check'] == 'ok';
    } catch (e) {
      debugPrint('Erro ao verificar integridade: $e');
      return false;
    } finally {
      await tempDb?.close();
    }
  }

  /// Restaura o estado anterior em caso de falha
  Future<void> _rollback(String targetPath, String? backupPath) async {
    try {
      final targetFile = File(targetPath);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      
      if (backupPath != null) {
        final bkpFile = File(backupPath);
        if (await bkpFile.exists()) {
          // Se falhou no meio, tentamos deixar o destino limpo.
          // O original em Program Files permanece intacto.
          await bkpFile.delete();
        }
      }
    } catch (e) {
      debugPrint('Erro no rollback: $e');
    }
  }
}
