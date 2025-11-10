import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Interface para abstração do acesso ao banco de dados
abstract class IDatabase {
  /// Retorna a instância do banco de dados
  Future<Database> get database;

  /// Fecha a conexão com o banco de dados
  Future<void> close();
}
