import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/csv_validation_result.dart';
import '../utils/text_normalizer.dart';

class CsvValidator {
  /// Valida o arquivo CSV antes da importação
  Future<CsvValidationResult> validate(File csvFile) async {
    final errors = <String>[];
    final warnings = <String>[];
    int rowCount = 0;
    List<String> headers = [];
    String encoding = 'utf-8';

    try {
      // 1. Detectar encoding e ler conteúdo
      // Simplificado: tenta UTF-8, se falhar tenta Latin1
      List<int> bytes = await csvFile.readAsBytes();
      String contents;
      try {
        contents = utf8.decode(bytes);
        encoding = 'utf-8';
      } catch (e) {
        contents = latin1.decode(bytes);
        encoding = 'iso-8859-1 (latin1)';
        warnings.add('Arquivo não está em UTF-8. Usando $encoding.');
      }

      // 2. Converter CSV para lista
      final rows = const CsvToListConverter().convert(contents);
      if (rows.isEmpty) {
        return CsvValidationResult(
          isValid: false,
          errors: ['O arquivo CSV está vazio.'],
          warnings: warnings,
          rowCount: 0,
          headers: [],
          encoding: encoding,
        );
      }

      // 3. Validar Headers
      headers = rows[0].map((h) => normalizeText(h.toString())).toList();
      final requiredColumns = ['modelo', 'categoria', 'quantidade'];
      for (var col in requiredColumns) {
        if (!headers.contains(col)) {
          errors.add('Coluna obrigatória "$col" não encontrada.');
        }
      }

      if (!headers.contains('localizacao') && !headers.contains('caixa')) {
        errors.add('Coluna de localização ("caixa" ou "localizacao") não encontrada.');
      }

      // 4. Validar amostra (10 linhas)
      rowCount = rows.length - 1;
      final sampleCount = rowCount > 10 ? 10 : rowCount;
      for (var i = 1; i <= sampleCount; i++) {
        final row = rows[i];
        final lineNumber = i + 1;
        
        if (row.isEmpty || _isRowEmpty(row)) continue;

        if (row.length < headers.length) {
          warnings.add('Linha $lineNumber tem menos colunas que o cabeçalho.');
        }

        // Validação básica de tipos na amostra
        final modelIdx = _getIdx(headers, ['modelo']);
        final qtyIdx = _getIdx(headers, ['quantidade']);

        if (modelIdx != -1 && (row[modelIdx]?.toString().isEmpty ?? true)) {
          errors.add('Linha $lineNumber: Modelo não pode ser vazio.');
        }

        if (qtyIdx != -1) {
          final qtyStr = row[qtyIdx]?.toString() ?? '';
          if (qtyStr.isNotEmpty && int.tryParse(qtyStr) == null) {
            errors.add('Linha $lineNumber: Quantidade "$qtyStr" não é um número válido.');
          }
        }
      }

      return CsvValidationResult(
        isValid: errors.isEmpty,
        errors: errors,
        warnings: warnings,
        rowCount: rowCount,
        headers: headers,
        encoding: encoding,
      );
    } catch (e) {
      return CsvValidationResult(
        isValid: false,
        errors: ['Erro inesperado ao validar CSV: $e'],
        warnings: warnings,
        rowCount: 0,
        headers: [],
        encoding: encoding,
      );
    }
  }

  bool _isRowEmpty(List<dynamic> row) {
    return row.every((cell) => cell == null || cell.toString().trim().isEmpty);
  }

  int _getIdx(List<String> headers, List<String> candidates) {
    for (var cand in candidates) {
      final idx = headers.indexOf(normalizeText(cand));
      if (idx != -1) return idx;
    }
    return -1;
  }
}
