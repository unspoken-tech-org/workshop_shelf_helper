import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class DatabaseSeeder {
  String get name;
  Future<void> seed(Database db);
}
