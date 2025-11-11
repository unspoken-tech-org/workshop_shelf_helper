import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../utils/text_normalizer.dart';
import 'database_seeder.dart';

class ComponentSeeder implements DatabaseSeeder {
  @override
  String get name => 'ComponentSeeder';

  @override
  Future<void> seed(Database db) async {
    debugPrint('  🌱 Populating sample components...');

    final categories = await db.query('categories');
    final categoriesMap = {for (var cat in categories) cat['name'] as String: cat['id'] as int};

    final components = [
      // Transistors
      {
        'category_id': categoriesMap['Transistores'],
        'model': 'BC547',
        'quantity': 50,
        'location': 'Gaveta A1',
        'polarity': 'NPN',
        'package': 'TO-92',
        'unit_cost': 0.15,
        'notes': 'Transistor de uso geral',
      },
      {
        'category_id': categoriesMap['Transistores'],
        'model': 'BC557',
        'quantity': 30,
        'location': 'Gaveta A1',
        'polarity': 'PNP',
        'package': 'TO-92',
        'unit_cost': 0.18,
        'notes': 'Complementar do BC547',
      },
      {
        'category_id': categoriesMap['Transistores'],
        'model': '2N2222',
        'quantity': 25,
        'location': 'Gaveta A2',
        'polarity': 'NPN',
        'package': 'TO-18',
        'unit_cost': 0.30,
        'notes': 'Alta potência',
      },

      // Resistors
      {
        'category_id': categoriesMap['Resistores'],
        'model': '1KΩ 1/4W',
        'quantity': 100,
        'location': 'Gaveta B1',
        'polarity': null,
        'package': 'Axial',
        'unit_cost': 0.05,
        'notes': 'Resistor comum',
      },
      {
        'category_id': categoriesMap['Resistores'],
        'model': '10KΩ 1/4W',
        'quantity': 80,
        'location': 'Gaveta B1',
        'polarity': null,
        'package': 'Axial',
        'unit_cost': 0.05,
        'notes': 'Pull-up comum',
      },
      {
        'category_id': categoriesMap['Resistores'],
        'model': '330Ω 1/4W',
        'quantity': 60,
        'location': 'Gaveta B2',
        'polarity': null,
        'package': 'Axial',
        'unit_cost': 0.05,
        'notes': 'Para LEDs',
      },

      // Capacitors
      {
        'category_id': categoriesMap['Capacitores'],
        'model': '100uF 16V',
        'quantity': 40,
        'location': 'Gaveta C1',
        'polarity': 'Polarizado',
        'package': 'Radial',
        'unit_cost': 0.25,
        'notes': 'Eletrolítico',
      },
      {
        'category_id': categoriesMap['Capacitores'],
        'model': '100nF Cerâmico',
        'quantity': 70,
        'location': 'Gaveta C2',
        'polarity': 'Não polarizado',
        'package': 'Cerâmico',
        'unit_cost': 0.10,
        'notes': 'Desacoplamento',
      },

      // Diodes
      {
        'category_id': categoriesMap['Diodos'],
        'model': '1N4007',
        'quantity': 45,
        'location': 'Gaveta D1',
        'polarity': 'Catodo/Anodo',
        'package': 'DO-41',
        'unit_cost': 0.12,
        'notes': 'Retificador 1A',
      },
      {
        'category_id': categoriesMap['Diodos'],
        'model': 'LED Vermelho 5mm',
        'quantity': 100,
        'location': 'Gaveta D2',
        'polarity': 'Catodo/Anodo',
        'package': 'LED 5mm',
        'unit_cost': 0.20,
        'notes': 'LED indicador',
      },

      // ICs
      {
        'category_id': categoriesMap['Circuitos Integrados'],
        'model': 'NE555',
        'quantity': 15,
        'location': 'Gaveta E1',
        'polarity': null,
        'package': 'DIP-8',
        'unit_cost': 0.80,
        'notes': 'Timer clássico',
      },
      {
        'category_id': categoriesMap['Circuitos Integrados'],
        'model': 'LM358',
        'quantity': 12,
        'location': 'Gaveta E1',
        'polarity': null,
        'package': 'DIP-8',
        'unit_cost': 1.20,
        'notes': 'OpAmp duplo',
      },
      {
        'category_id': categoriesMap['Circuitos Integrados'],
        'model': 'ATmega328P',
        'quantity': 5,
        'location': 'Gaveta E2',
        'polarity': null,
        'package': 'DIP-28',
        'unit_cost': 15.00,
        'notes': 'Microcontrolador Arduino',
      },
    ];

    for (final component in components) {
      final componentData = {
        ...component,
        'model_normalized': normalizeText(component['model'] as String),
        'location_normalized': normalizeText(component['location'] as String),
      };
      await db.insert('components', componentData);
    }

    debugPrint('  ✓ ${components.length} components added');
  }
}
