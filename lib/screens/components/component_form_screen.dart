import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workshop_shelf_helper/providers/category_provider.dart';
import 'package:workshop_shelf_helper/models/category.dart';
import 'package:workshop_shelf_helper/models/component.dart';
import 'package:workshop_shelf_helper/providers/component_provider.dart';

class ComponentFormScreen extends StatefulWidget {
  final Component? component;

  const ComponentFormScreen({super.key, this.component});

  @override
  State<ComponentFormScreen> createState() => _ComponentFormScreenState();
}

class _ComponentFormScreenState extends State<ComponentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();
  final _polarityController = TextEditingController();
  final _packageController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  int? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });

    if (widget.component != null) {
      _modelController.text = widget.component!.model;
      _quantityController.text = widget.component!.quantity.toString();
      _locationController.text = widget.component!.location;
      _polarityController.text = widget.component!.polarity ?? '';
      _packageController.text = widget.component!.package ?? '';
      _costController.text = widget.component!.unitCost.toStringAsFixed(2);
      _notesController.text = widget.component!.notes ?? '';
      _selectedCategory = widget.component!.categoryId;
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _polarityController.dispose();
    _packageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.component != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Componente' : 'Novo Componente'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações Básicas',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Selector<CategoryProvider, List<Category>>(
                        selector: (context, provider) => provider.categories,
                        builder: (context, categories, child) {
                          return DropdownButtonFormField<int>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: 'Categoria *',
                              prefixIcon: Icon(Icons.category),
                            ),
                            items:
                                categories.map((cat) {
                                  return DropdownMenuItem(value: cat.id, child: Text(cat.name));
                                }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategory = value);
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor, selecione uma categoria';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _modelController,
                        decoration: const InputDecoration(
                          labelText: 'Modelo *',
                          hintText: 'Ex: BC547',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor, informe o modelo';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantidade *',
                                hintText: '0',
                                prefixIcon: Icon(Icons.format_list_numbered),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe a quantidade';
                                }
                                final quantity = int.tryParse(value);
                                if (quantity == null || quantity < 0) {
                                  return 'Quantidade inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Localização *',
                                hintText: 'Ex: cx01',
                                prefixIcon: Icon(Icons.place),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Informe a localização';
                                }
                                return null;
                              },
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Especificações Técnicas',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _polarityController,
                        decoration: const InputDecoration(
                          labelText: 'Polaridade (opcional)',
                          hintText: 'Ex: NPN, PNP',
                          prefixIcon: Icon(Icons.power),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _packageController,
                        decoration: const InputDecoration(
                          labelText: 'Encapsulamento (opcional)',
                          hintText: 'Ex: TO-92',
                          prefixIcon: Icon(Icons.settings),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações Financeiras',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Custo Unitário (R\$) *',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe o custo unitário';
                          }
                          final cost = double.tryParse(value);
                          if (cost == null || cost < 0) {
                            return 'Custo inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_quantityController.text.isNotEmpty && _costController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Valor Total:',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'R\$ ${_calculateTotalValue()}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Observações',
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Observação (opcional)',
                          hintText: 'Adicione informações adicionais',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                        : Text(
                          isEditing ? 'Atualizar Componente' : 'Cadastrar Componente',
                          style: const TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateTotalValue() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final cost = double.tryParse(_costController.text) ?? 0.0;
    final total = quantity * cost;
    return total.toStringAsFixed(2);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final component = Component(
      id: widget.component?.id,
      categoryId: _selectedCategory!,
      categoryName: '',
      model: _modelController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      location: _locationController.text.trim(),
      polarity: _polarityController.text.trim().isEmpty ? null : _polarityController.text.trim(),
      package: _packageController.text.trim().isEmpty ? null : _packageController.text.trim(),
      unitCost: double.parse(_costController.text.trim()),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    bool success;
    if (widget.component == null) {
      success = await context.read<ComponentProvider>().addComponent(component);
    } else {
      success = await context.read<ComponentProvider>().updateComponent(component);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.component == null
                  ? 'Componente cadastrado com sucesso!'
                  : 'Componente atualizado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.component == null
                  ? 'Erro ao cadastrar componente'
                  : 'Erro ao atualizar componente',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
