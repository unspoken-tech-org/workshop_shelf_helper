import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workshop_shelf_helper/database/database_helper.dart';
import 'package:workshop_shelf_helper/services/database_migration_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('integration_migration_test');
    
    // Mock path_provider para apontar para nossa pasta temporária
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationSupportDirectory':
          return p.join(tempDir.path, 'local_app_data');
        default:
          return null;
      }
    });
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    DatabaseHelper.setOverridePath(null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('Deve realizar o fluxo completo de migração quando detectado local readonly', () async {
    // 1. Simular banco em "Program Files" (usando overridePath para apontar para nossa pasta de teste)
    final fakeProgramFiles = await Directory(p.join(tempDir.path, 'Program Files', 'App')).create(recursive: true);
    final oldDbPath = p.join(fakeProgramFiles.path, 'workshop_shelf_helper.db');
    
    // Criar banco original com dados e versão correta
    final db = await databaseFactoryFfi.openDatabase(
      oldDbPath,
      options: OpenDatabaseOptions(version: 1)
    );
    await db.execute('CREATE TABLE components (id INTEGER PRIMARY KEY, model TEXT)');
    await db.insert('components', {'id': 1, 'model': 'Resistor 10k'});
    await db.close();

    // Configurar o helper para pensar que o banco atual é esse no Program Files fake
    // Para isso, precisamos que isReadOnlyLocation retorne true.
    // O path contém "Program Files", então deve funcionar.
    DatabaseHelper.setOverridePath(oldDbPath);
    
    final migrationService = DatabaseMigrationService();
    
    // 2. Verificar se migração é necessária
    final isNeeded = await migrationService.checkMigrationNeeded();
    expect(isNeeded, isTrue, reason: 'Deveria detectar que o banco está em local readonly');

    // 3. Executar migração
    final result = await migrationService.migrateDatabase();
    expect(result.success, isTrue);
    expect(result.newPath, contains('local_app_data'));
    
    // 4. Verificar se os dados estão no novo local
    DatabaseHelper.setOverridePath(result.newPath);
    final newDb = await DatabaseHelper.instance.database;
    final rows = await newDb.query('components');
    expect(rows.length, 1);
    expect(rows.first['model'], 'Resistor 10k');
    
    // 5. Verificar se o banco original ainda existe (não deletamos se for Program Files por segurança/permissão)
    expect(File(oldDbPath).existsSync(), isTrue);
  });
}
