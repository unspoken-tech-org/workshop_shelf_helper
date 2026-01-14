import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MigrationLogger {
  static Future<void> log(String message) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final logDir = Directory(p.join(directory.path, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final logFile = File(p.join(logDir.path, 'migration_$dateStr.log'));
      
      final timestamp = DateTime.now().toIso8601String();
      await logFile.writeAsString(
        '[$timestamp] $message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // Silenciosamente falha se não conseguir logar
      print('Erro ao logar migração: $e');
    }
  }
}
