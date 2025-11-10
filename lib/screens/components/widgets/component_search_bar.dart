import 'package:flutter/material.dart';

class ComponentSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ComponentSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<ComponentSearchBar> createState() => _ComponentSearchBarState();
}

class _ComponentSearchBarState extends State<ComponentSearchBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.controller,
        decoration: InputDecoration(
          hintText: 'Buscar por modelo ou localização...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              widget.controller.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: widget.onClear)
                  : null,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
