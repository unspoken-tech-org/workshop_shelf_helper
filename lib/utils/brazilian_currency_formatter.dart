import 'package:flutter/services.dart';

class BrazilianCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String newNumbersOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (newNumbersOnly.isEmpty) {
      return const TextEditingValue();
    }

    if (newNumbersOnly.length > 11) {
      newNumbersOnly = newNumbersOnly.substring(0, 11);
    }

    final intValue = int.parse(newNumbersOnly);

    final realValue = intValue / 100;

    final formatted = _formatCurrency(realValue);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    final integerFormatted = _addThousandsSeparator(integerPart);

    return '$integerFormatted,$decimalPart';
  }

  String _addThousandsSeparator(String value) {
    final buffer = StringBuffer();
    final length = value.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }

    return buffer.toString();
  }

  static double? parseFromBrazilianFormat(String text) {
    if (text.isEmpty) return null;

    final normalized = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  static String formatToBrazilian(double value) {
    final formatter = BrazilianCurrencyInputFormatter();
    return formatter._formatCurrency(value);
  }
}
