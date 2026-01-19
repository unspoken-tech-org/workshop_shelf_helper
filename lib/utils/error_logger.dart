import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ErrorLogger {
  static Future<void> log(dynamic error, [StackTrace? stackTrace]) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final logDir = Directory(p.join(directory.path, 'logs'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final logFile = File(p.join(logDir.path, 'import_errors_$dateStr.log'));
      
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] ERROR: $error\n${stackTrace != null ? "STACKTRACE: $stackTrace\n" : ""}\n';
      
      await logFile.writeAsString(
        logEntry,
        mode: FileMode.append,
      );
    } catch (e) {
      print('Erro ao logar erro: $e');
    }
  }
}
