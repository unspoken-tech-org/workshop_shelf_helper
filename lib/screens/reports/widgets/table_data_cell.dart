import 'package:flutter/material.dart';

class TableDataCell extends StatelessWidget {
  final String text;
  final bool centered;

  const TableDataCell({super.key, required this.text, this.centered = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: centered ? TextAlign.center : TextAlign.left,
      ),
    );
  }
}
