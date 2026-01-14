import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_shelf_helper/widgets/error_message_widget.dart';

void main() {
  testWidgets('ErrorMessageWidget deve exibir mensagem amigável para FileSystemException', (WidgetTester tester) async {
    const error = FileSystemException('Access Denied', '', OSError('Access Denied', 5));
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessageWidget(error: error),
        ),
      ),
    );

    expect(find.text('Ocorreu um problema'), findsOneWidget);
    expect(find.textContaining('Sem permissão para acessar o arquivo'), findsOneWidget);
    expect(find.byIcon(Icons.folder_off), findsOneWidget);
  });

  testWidgets('ErrorMessageWidget deve exibir botão de tentar novamente quando onRetry é fornecido', (WidgetTester tester) async {
    bool retryCalled = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorMessageWidget(
            error: 'Erro generico',
            onRetry: () => retryCalled = true,
          ),
        ),
      ),
    );

    final retryButton = find.text('Tentar novamente');
    expect(retryButton, findsOneWidget);
    
    await tester.tap(retryButton);
    expect(retryCalled, isTrue);
  });
}
