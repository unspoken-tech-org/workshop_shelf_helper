import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'interfaces/i_database.dart';
import 'migrations/migration_runner.dart';
import 'seeders/seeder_runner.dart';

import '../utils/path_helper.dart';

class DatabaseHelper implements IDatabase {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _ffiInitialized = false;
  static String? _overridePath; // Para testes

  final MigrationRunner _migrationRunner = MigrationRunner();
  final SeederRunner _seederRunner = SeederRunner();

  DatabaseHelper._init();

  /// Permite sobrescrever o caminho do banco (usado em testes)
  static void setOverridePath(String? path) {
    _overridePath = path;
    _database = null;
  }

  @override
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    String path;
    if (_overridePath != null) {
      path = _overridePath!;
    } else {
      path = await PathHelper.getDatabasePath();
    }
    
    _database = await _initDB(path);
    return _database!;
  }

  Future<Database> _initDB(String path) async {
    if (!_ffiInitialized && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _ffiInitialized = true;
    }

    return await openDatabase(
      path,
      version: _migrationRunner.latestVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _migrationRunner.onCreate(db, version);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _migrationRunner.onUpgrade(db, oldVersion, newVersion);
  }

  Future<void> seedDatabase() async {
    final db = await database;
    await _seederRunner.seedAll(db);
  }

  Future<void> resetWithMockData() async {
    final db = await database;
    await _seederRunner.resetAndSeed(db);
  }

  /// Verifica se o banco de dados está em local readonly (Program Files)
  Future<bool> detectReadOnlyLocation() async {
    final path = await getCurrentDatabasePath();
    return PathHelper.isReadOnlyLocation(path);
  }

  /// Retorna o caminho atual do banco de dados
  Future<String> getCurrentDatabasePath() async {
    if (_overridePath != null) return _overridePath!;
    
    // Se não houver override, o path padrão é o do executável (onde o bug ocorre)
    // OU o path do LOCALAPPDATA se já tiver sido inicializado.
    // Para fins de detecção de migração, queremos saber onde ele estaria por padrão.
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return join(exeDir, 'workshop_shelf_helper.db');
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

