import 'package:flutter_test/flutter_test.dart';
import 'package:workshop_shelf_helper/mappers/category_mapper.dart';
import 'package:workshop_shelf_helper/mappers/component_mapper.dart';
import 'package:workshop_shelf_helper/models/category.dart';
import 'package:workshop_shelf_helper/models/component.dart';

void main() {
  group('CategoryMapper', () {
    test('should convert Category model to CategoryEntity', () {
      final category = Category(id: 1, name: 'Resistores', description: 'Resistores diversos');

      final entity = CategoryMapper.toEntity(category);

      expect(entity.id, 1);
      expect(entity.name, 'Resistores');
      expect(entity.nameNormalized, 'resistores');
      expect(entity.description, 'Resistores diversos');
    });

    test('should generate toDatabaseMap with normalized fields', () {
      final category = Category(id: 2, name: 'Capacitores', description: 'Capacitores diversos');

      final entity = CategoryMapper.toEntity(category);
      final map = entity.toDatabaseMap();

      expect(map['id'], 2);
      expect(map['name'], 'Capacitores');
      expect(map['name_normalized'], 'capacitores');
      expect(map['description'], 'Capacitores diversos');
    });
  });

  group('ComponentMapper', () {
    test('should convert Component model to ComponentEntity', () {
      final component = Component(
        id: 1,
        categoryId: 1,
        categoryName: 'Resistores',
        model: 'BC547',
        quantity: 100,
        location: 'Gaveta A1',
        polarity: 'NPN',
        package: 'TO-92',
        unitCost: 0.50,
        notes: 'Transistor comum',
      );

      final entity = ComponentMapper.toEntity(component);

      expect(entity.id, 1);
      expect(entity.categoryId, 1);
      expect(entity.model, 'BC547');
      expect(entity.modelNormalized, 'bc547');
      expect(entity.quantity, 100);
      expect(entity.location, 'Gaveta A1');
      expect(entity.locationNormalized, 'gaveta a1');
      expect(entity.polarity, 'NPN');
      expect(entity.package, 'TO-92');
      expect(entity.unitCost, 0.50);
      expect(entity.notes, 'Transistor comum');
    });

    test('should generate toDatabaseMap with normalized fields', () {
      final component = Component(
        id: 2,
        categoryId: 2,
        categoryName: 'Resistores',
        model: '1KΩ 1/4W',
        quantity: 200,
        location: 'Gaveta B1',
        unitCost: 0.10,
      );

      final entity = ComponentMapper.toEntity(component);
      final map = entity.toDatabaseMap();

      expect(map['id'], 2);
      expect(map['category_id'], 2);
      expect(map['model'], '1KΩ 1/4W');
      expect(map['model_normalized'], '1kω 1/4w');
      expect(map['quantity'], 200);
      expect(map['location'], 'Gaveta B1');
      expect(map['location_normalized'], 'gaveta b1');
      expect(map['unit_cost'], 0.10);
    });
  });

  group('Model fromDatabaseMap', () {
    test('Category should create instance from Map', () {
      final map = {
        'id': 1,
        'name': 'Resistores',
        'name_normalized': 'resistores',
        'description': 'Resistores diversos',
      };

      final category = Category.fromDatabaseMap(map);

      expect(category.id, 1);
      expect(category.name, 'Resistores');
      expect(category.description, 'Resistores diversos');
    });

    test('Component should create instance from Map with JOIN', () {
      final map = {
        'id': 1,
        'category_id': 1,
        'category_name': 'Transistores',
        'model': 'BC547',
        'model_normalized': 'bc547',
        'quantity': 100,
        'location': 'Gaveta A1',
        'location_normalized': 'gaveta a1',
        'polarity': 'NPN',
        'package': 'TO-92',
        'unit_cost': 0.50,
        'notes': 'Transistor comum',
      };

      final component = Component.fromDatabaseMap(map);

      expect(component.id, 1);
      expect(component.categoryId, 1);
      expect(component.categoryName, 'Transistores');
      expect(component.model, 'BC547');
      expect(component.quantity, 100);
      expect(component.location, 'Gaveta A1');
      expect(component.polarity, 'NPN');
      expect(component.package, 'TO-92');
      expect(component.unitCost, 0.50);
      expect(component.notes, 'Transistor comum');
    });
  });
}
