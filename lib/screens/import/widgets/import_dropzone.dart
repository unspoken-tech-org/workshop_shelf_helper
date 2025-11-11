import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';

class ImportDropzone extends StatefulWidget {
  final Function(String filePath) onFileSelected;

  const ImportDropzone({super.key, required this.onFileSelected});

  @override
  State<ImportDropzone> createState() => _ImportDropzoneState();
}

class _ImportDropzoneState extends State<ImportDropzone> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragEntered: (details) {
        setState(() {
          _isDragging = true;
        });
      },
      onDragExited: (details) {
        setState(() {
          _isDragging = false;
        });
      },
      onDragDone: (details) async {
        setState(() {
          _isDragging = false;
        });

        if (details.files.isNotEmpty) {
          final file = details.files.first;
          if (file.path.toLowerCase().endsWith('.csv')) {
            widget.onFileSelected(file.path);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Por favor, selecione um arquivo CSV'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragging ? Colors.blue : Colors.grey.shade400,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: _isDragging ? Colors.blue.shade50 : Colors.grey.shade100,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isDragging ? Icons.file_download : Icons.cloud_upload_outlined,
                size: 64,
                color: _isDragging ? Colors.blue : Colors.grey.shade600,
              ),
              const SizedBox(height: 16),
              Text(
                _isDragging ? 'Solte o arquivo aqui' : 'Arraste e solte o arquivo CSV aqui',
                style: TextStyle(
                  fontSize: 16,
                  color: _isDragging ? Colors.blue : Colors.grey.shade700,
                  fontWeight: _isDragging ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 8),
              if (!_isDragging)
                Text('ou', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}
