import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Helper para gerenciar paths do aplicativo e verificar permissões
class PathHelper {
  /// Retorna o caminho do banco de dados no local correto (%LOCALAPPDATA%)
  /// 
  /// No Windows, retorna: %LOCALAPPDATA%\Workshop Shelf Helper\databases\workshop_shelf_helper.db
  static Future<String> getDatabasePath() async {
    // getApplicationSupportDirectory() retorna %LOCALAPPDATA% no Windows
    final directory = await getApplicationSupportDirectory();
    
    // Criar subdiretório databases se necessário
    final dbDirectory = Directory(p.join(directory.path, 'databases'));
    if (!await dbDirectory.exists()) {
      await dbDirectory.create(recursive: true);
    }
    
    return p.join(dbDirectory.path, 'workshop_shelf_helper.db');
  }

  /// Verifica se um diretório tem permissões de escrita
  /// 
  /// Retorna true se conseguir escrever um arquivo temporário no diretório
  /// Detecta erro código 5 do Windows (Access Denied)
  static Future<bool> hasWritePermission(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      
      // Verifica se o diretório existe
      if (!await directory.exists()) {
        // Tenta criar o diretório
        await directory.create(recursive: true);
      }
      
      // Tenta criar um arquivo temporário para testar escrita
      final testFilePath = p.join(
        directoryPath,
        '.write_test_${DateTime.now().millisecondsSinceEpoch}',
      );
      final testFile = File(testFilePath);
      
      // Tenta escrever
      await testFile.writeAsString('test');
      
      // Se conseguiu escrever, limpa o arquivo de teste
      await testFile.delete();
      
      return true;
    } on FileSystemException catch (e) {
      // Erros específicos de permissão
      if (e.osError?.errorCode == 5) {  // ERROR_ACCESS_DENIED no Windows
        return false;
      }
      rethrow;  // Relança outros erros
    } catch (e) {
      return false;
    }
  }

  /// Retorna o primeiro diretório com permissão de escrita
  /// 
  /// Tenta em ordem: ApplicationSupport -> Documents -> Temp
  static Future<Directory> getWritableDirectory() async {
    final candidateDirs = [
      await getApplicationSupportDirectory(),  // Primeira escolha: %LOCALAPPDATA%
      await getApplicationDocumentsDirectory(), // Fallback: Documents
      await getTemporaryDirectory(),           // Último recurso: Temp
    ];
    
    for (final dir in candidateDirs) {
      if (await hasWritePermission(dir.path)) {
        return dir;
      }
    }
    
    throw Exception('Nenhum diretório com permissão de escrita encontrado');
  }

  /// Verifica se um path está em local protegido (Program Files)
  static bool isReadOnlyLocation(String path) {
    final normalizedPath = path.toLowerCase();
    return normalizedPath.contains('program files') ||
           normalizedPath.contains('program files (x86)');
  }
}
