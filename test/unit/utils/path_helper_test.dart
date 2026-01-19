import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:workshop_shelf_helper/utils/path_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('path_helper_test');
    
    // Mock path_provider
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationSupportDirectory':
          return p.join(tempDir.path, 'app_support');
        case 'getApplicationDocumentsDirectory':
          return p.join(tempDir.path, 'documents');
        case 'getTemporaryDirectory':
          return p.join(tempDir.path, 'temp');
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

  group('PathHelper', () {
    test('getDatabasePath deve retornar caminho no subdiretório databases', () async {
      final dbPath = await PathHelper.getDatabasePath();
      
      expect(dbPath, contains('app_support'));
      expect(dbPath, contains('databases'));
      expect(p.basename(dbPath), equals('workshop_shelf_helper.db'));
      
      // Verifica se o diretório foi criado
      final dbDir = Directory(p.dirname(dbPath));
      expect(await dbDir.exists(), isTrue);
    });

    test('hasWritePermission deve retornar true para diretório gravável', () async {
      final writableDir = Directory(p.join(tempDir.path, 'writable'));
      await writableDir.create();
      
      final hasPermission = await PathHelper.hasWritePermission(writableDir.path);
      expect(hasPermission, isTrue);
    });

    test('isReadOnlyLocation deve identificar Program Files como readonly', () {
      expect(PathHelper.isReadOnlyLocation('C:\\Program Files\\App\\db.db'), isTrue);
      expect(PathHelper.isReadOnlyLocation('C:\\Program Files (x86)\\App\\db.db'), isTrue);
      expect(PathHelper.isReadOnlyLocation('D:\\Data\\App\\db.db'), isFalse);
      expect(PathHelper.isReadOnlyLocation('C:\\Users\\Name\\AppData\\Local\\App\\db.db'), isFalse);
    });

    test('getWritableDirectory deve retornar o primeiro diretório disponível', () async {
      final dir = await PathHelper.getWritableDirectory();
      expect(dir.path, contains('app_support'));
      expect(await PathHelper.hasWritePermission(dir.path), isTrue);
    });
  });
}
