import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class ErrorMessageWidget extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const ErrorMessageWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final friendlyMessage = _getFriendlyMessage(error);
    final icon = _getErrorIcon(error);
    final color = _getErrorColor(error);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: color.withValues(alpha: 13),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: color.withValues(alpha: 51)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ocorreu um problema',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              friendlyMessage,
              style: const TextStyle(fontSize: 14),
            ),
            if (kDebugMode && stackTrace != null) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                title: const Text('Detalhes técnicos', style: TextStyle(fontSize: 12)),
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        '$error\n$stackTrace',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getFriendlyMessage(dynamic error) {
    final rawMessage = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    final message = rawMessage.toLowerCase();

    if (error is FileSystemException) {
      if (error.osError?.errorCode == 5) {
        return 'Sem permissão para acessar o arquivo. Verifique se o aplicativo pode escrever no local selecionado.';
      } else if (error.osError?.errorCode == 32) {
        return 'O arquivo está aberto em outro programa. Feche-o e tente novamente.';
      }
      return 'Não foi possível acessar o arquivo selecionado.';
    }

    if (error is DatabaseException || message.contains('readonly')) {
      return 'O banco de dados está em modo somente leitura. Feche e reabra o aplicativo para migrar.';
    }

    if (message.contains('unique constraint')) {
      return 'Alguns dados já existem no sistema e não podem ser duplicados.';
    }

    if (message.contains('failed to decode data using encoding utf-8')) {
      return 'Não foi possível ler o arquivo. Salve o CSV em UTF-8 e tente novamente.';
    }

    if (message.contains('coluna obrigatoria') && message.contains('categoria')) {
      return 'O CSV precisa da coluna "Categoria" no cabeçalho. Verifique o template e tente novamente.';
    }

    if (message.contains('coluna obrigatoria') && message.contains('localizacao')) {
      return 'O CSV precisa da coluna "Localização" ou "Caixa". Ajuste o cabeçalho e tente novamente.';
    }

    if (message.contains('custo unitario') || message.contains('custo total')) {
      return 'Inclua a coluna "Custo Unitário" ou "Custo Total" no arquivo antes de importar.';
    }

    if (message.contains('encontramos problemas no arquivo')) {
      return rawMessage;
    }

    if (error is FormatException) {
      return 'O formato do arquivo é inválido. Verifique se o CSV segue o modelo esperado.';
    }

    return rawMessage;
  }

  IconData _getErrorIcon(dynamic error) {
    if (error is FileSystemException) return Icons.folder_off;
    if (error is DatabaseException) return Icons.storage;
    return Icons.error_outline;
  }

  Color _getErrorColor(dynamic error) {
    if (error is FileSystemException) return Colors.orange;
    if (error is DatabaseException) return Colors.red;
    return Colors.redAccent;
  }
}
