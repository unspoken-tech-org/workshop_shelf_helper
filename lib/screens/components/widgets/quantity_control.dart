import 'package:flutter/material.dart';
import 'package:workshop_shelf_helper/utils/debouncer.dart';

class QuantityControl extends StatefulWidget {
  final int initialQuantity;
  final int componentId;
  final Function(int componentId, int newQuantity) onQuantityChange;

  const QuantityControl({
    super.key,
    required this.initialQuantity,
    required this.componentId,
    required this.onQuantityChange,
  });

  @override
  State<QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<QuantityControl> {
  late int _currentQuantity;
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _currentQuantity = widget.initialQuantity;
    _debouncer = Debouncer(delay: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _updateQuantity(int delta) {
    final newQuantity = _currentQuantity + delta;

    if (newQuantity < 0) return;

    setState(() {
      _currentQuantity = newQuantity;
    });

    _debouncer(() {
      widget.onQuantityChange(widget.componentId, _currentQuantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Estoque: '),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _currentQuantity > 0 ? () => _updateQuantity(-1) : null,
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        Text(
          '$_currentQuantity',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _updateQuantity(1),
          iconSize: 24,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const Text(' unidades'),
      ],
    );
  }
}
