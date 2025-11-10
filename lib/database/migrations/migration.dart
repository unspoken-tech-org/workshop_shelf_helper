import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class Migration {
  int get version;

  Future<void> up(Database db);
}
