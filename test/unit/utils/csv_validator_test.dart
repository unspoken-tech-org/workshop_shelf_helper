import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:workshop_shelf_helper/utils/csv_validator.dart';

void main() {
  late Directory tempDir;
  late CsvValidator validator;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('csv_validator_test');
    validator = CsvValidator();
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('CsvValidator deve validar CSV correto', () async {
    final csvFile = File(p.join(tempDir.path, 'valid.csv'));
    await csvFile.writeAsString('modelo,categoria,quantidade,caixa,custo_unitario\r\nBC547,Transistores,10,CX01,0.50', flush: true);
    
    final result = await validator.validate(csvFile);
    
    expect(result.isValid, isTrue, reason: 'Erros: ${result.errors}');
    expect(result.rowCount, 1);
  });

  test('CsvValidator deve detectar falta de colunas obrigatorias', () async {
    final csvFile = File(p.join(tempDir.path, 'invalid.csv'));
    await csvFile.writeAsString('modelo,quantidade\r\nBC547,10', flush: true);
    
    final result = await validator.validate(csvFile);
    
    expect(result.isValid, isFalse);
    expect(result.errors.any((e) => e.contains('categoria')), isTrue, reason: 'Deveria conter erro de categoria');
  });

  test('CsvValidator deve validar tipos de dados na amostra', () async {
    final csvFile = File(p.join(tempDir.path, 'bad_types.csv'));
    await csvFile.writeAsString('modelo,categoria,quantidade,caixa,custo_unitario\r\nBC547,Transistores,ABC,CX01,0.50', flush: true);
    
    final result = await validator.validate(csvFile);
    
    expect(result.isValid, isFalse);
    expect(result.errors.any((e) => e.contains('Quantidade "ABC"')), isTrue);
  });
}
