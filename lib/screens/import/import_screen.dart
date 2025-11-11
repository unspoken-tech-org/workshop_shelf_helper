import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:workshop_shelf_helper/services/import_service.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';
import 'package:workshop_shelf_helper/models/import_result.dart';
import 'package:workshop_shelf_helper/screens/import/widgets/import_dropzone.dart';
import 'package:workshop_shelf_helper/screens/import/widgets/import_preview_table.dart';
import 'package:workshop_shelf_helper/screens/import/widgets/import_result_dialog.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String? _selectedFilePath;
  List<ImportPreviewData>? _previewData;
  bool _isLoading = false;
  String? _error;

  late final ImportService _importService;

  @override
  void initState() {
    super.initState();
    final categoryProvider = context.read<CategoryProvider>();
    final componentProvider = context.read<ComponentProvider>();

    _importService = ImportService(
      categoryRepository: categoryProvider.repository,
      componentRepository: componentProvider.repository,
    );
  }

  Future<void> _handleFileSelection(String filePath) async {
    setState(() {
      _selectedFilePath = filePath;
      _previewData = null;
      _error = null;
      _isLoading = true;
    });

    try {
      final preview = await _importService.parseCSVForPreview(filePath);
      setState(() {
        _previewData = preview;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao ler arquivo: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      dialogTitle: 'Selecione um arquivo CSV',
    );

    if (result != null && result.files.single.path != null) {
      await _handleFileSelection(result.files.single.path!);
    }
  }

  Future<void> _performImport() async {
    if (_selectedFilePath == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _importService.importFromCSV(_selectedFilePath!);

      // Recarregar dados dos providers
      if (mounted) {
        context.read<CategoryProvider>().loadCategories();
        context.read<ComponentProvider>().init();
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Mostrar dialog com resultado
        await showDialog(
          context: context,
          builder: (context) => ImportResultDialog(result: result),
        );

        // Se importação teve sucesso, limpar tela
        if (result.isSuccess) {
          setState(() {
            _selectedFilePath = null;
            _previewData = null;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Erro ao importar: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadTemplate() async {
    try {
      final filePath = await FilePicker.platform.saveFile(
        dialogTitle: 'Salvar Template CSV',
        fileName: 'template_importacao.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (filePath == null) {
        // Usuário cancelou a operação
        return;
      }

      setState(() {
        _isLoading = true;
      });

      await _importService.generateTemplate(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template salvo em:\n$filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar template: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFilePath = null;
      _previewData = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importar Componentes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Baixar Template CSV',
            onPressed: _isLoading ? null : _downloadTemplate,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInstructionsCard(),
                    const SizedBox(height: 24),
                    if (_selectedFilePath == null) ...[
                      ImportDropzone(onFileSelected: _handleFileSelection),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('ou', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Selecionar Arquivo'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ] else ...[
                      _buildFileSelectedCard(),
                      const SizedBox(height: 24),
                      if (_error != null) _buildErrorCard(),
                      if (_previewData != null) ...[
                        _buildPreviewSection(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                      ],
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Instruções',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Baixe o template CSV clicando no ícone de download acima',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '2. Preencha o arquivo com os dados dos componentes',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '3. Arraste o arquivo para a área indicada ou use o botão "Selecionar Arquivo"',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '4. Revise os dados no preview e clique em "Importar"',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text('Dicas', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Categorias inexistentes serão criadas automaticamente',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Componentes duplicados (mesmo modelo + categoria + localização) terão suas quantidades somadas',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• Você pode informar "Custo Unitário" OU "Custo Total" - o outro será calculado automaticamente',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelectedCard() {
    return Card(
      elevation: 2,
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Arquivo selecionado:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_selectedFilePath!.split('/').last, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
              tooltip: 'Remover arquivo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      elevation: 2,
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(child: Text(_error!, style: TextStyle(color: Colors.red.shade900))),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Preview dos Dados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_previewData!.length} componente(s)',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ImportPreviewTable(previewData: _previewData!),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearSelection,
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _previewData != null && _previewData!.isNotEmpty ? _performImport : null,
            icon: const Icon(Icons.upload),
            label: const Text('Importar Componentes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
