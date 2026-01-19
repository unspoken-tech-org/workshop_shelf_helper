import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:workshop_shelf_helper/database/database_helper.dart';
import 'package:workshop_shelf_helper/services/database_migration_service.dart';
import 'package:flutter/services.dart';

import 'database_migration_service_test.mocks.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDatabaseHelper mockDbHelper;
  late DatabaseMigrationService migrationService;
  late Directory tempDir;
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockDbHelper = MockDatabaseHelper();
    migrationService = DatabaseMigrationService(dbHelper: mockDbHelper);
    tempDir = await Directory.systemTemp.createTemp('migration_test');

    // Mock path_provider
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
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('DatabaseMigrationService', () {
    test('checkMigrationNeeded deve retornar true se estiver em Program Files e destino não existe', () async {
      when(mockDbHelper.getCurrentDatabasePath()).thenAnswer(
        (_) async => 'C:\\Program Files\\App\\workshop_shelf_helper.db'
      );

      final needed = await migrationService.checkMigrationNeeded();
      expect(needed, isTrue);
    });

    test('checkMigrationNeeded deve retornar false se não estiver em Program Files', () async {
      when(mockDbHelper.getCurrentDatabasePath()).thenAnswer(
        (_) async => 'C:\\Users\\User\\App\\workshop_shelf_helper.db'
      );

      final needed = await migrationService.checkMigrationNeeded();
      expect(needed, isFalse);
    });

    test('migrateDatabase deve migrar com sucesso banco saudável', () async {
      // Setup banco original
      final sourceDir = await Directory(p.join(tempDir.path, 'source')).create();
      final sourcePath = p.join(sourceDir.path, 'workshop_shelf_helper.db');
      
      // Cria um banco SQLite válido na origem
      final db = await databaseFactoryFfi.openDatabase(sourcePath);
      await db.execute('CREATE TABLE test (id INTEGER PRIMARY KEY)');
      await db.insert('test', {'id': 1});
      await db.close();

      when(mockDbHelper.getCurrentDatabasePath()).thenAnswer((_) async => sourcePath);
      when(mockDbHelper.close()).thenAnswer((_) async => {});

      final result = await migrationService.migrateDatabase();

      expect(result.success, isTrue);
      expect(File(result.newPath).existsSync(), isTrue);
      
      // Verifica integridade da cópia
      final copyDb = await databaseFactoryFfi.openDatabase(result.newPath);
      final rows = await copyDb.query('test');
      expect(rows.length, 1);
      await copyDb.close();
    });
  });
}
