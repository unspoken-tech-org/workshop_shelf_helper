# Agent Development Guide

## Project Overview

This is a Flutter desktop application (Windows) for managing electronic components inventory. The app uses SQLite for local data storage, Provider for state management, and follows a clean architecture pattern with repositories, entities, and mappers.

**Project Name:** Workshop Shelf Helper  
**Main Language:** Dart/Flutter  
**Target Platform:** Windows Desktop  
**Architecture:** Clean Architecture with Provider pattern  
**Communication Language:** pt-BR (Brazilian Portuguese) - All responses from LLMs should be in Brazilian Portuguese

---

## Build, Test, and Run Commands

### Running the Application
```bash
# Run in debug mode (recommended for development)
flutter run -d windows

# Run in release mode
flutter run -d windows --release
```

### Building
```bash
# Build for Windows release
flutter build windows --release

# Output location: build/windows/runner/Release/
```

### Testing
```bash
# Run all tests
flutter test

# Run a single test file
flutter test test/entity_mapper_test.dart

# Run tests with coverage
flutter test --coverage

# Run tests verbosely
flutter test --verbose
```

### Linting and Analysis
```bash
# Analyze code
flutter analyze

# Format all Dart files
dart format .

# Format a specific file
dart format lib/models/component.dart

# Check formatting without applying changes
dart format --set-exit-if-changed .
```

### Dependency Management
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Clean build cache
flutter clean
```

---

## Code Style Guidelines

### Imports Organization
Group imports in this order, separated by blank lines:
1. Dart core libraries (`dart:*`)
2. Flutter libraries (`package:flutter/*`)
3. Third-party packages (`package:*`)
4. Relative imports (local project files)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:provider/provider.dart';

import '../models/component.dart';
import '../repositories/component_repository.dart';
```

### Naming Conventions

**Files:**
- Use snake_case: `component_provider.dart`, `import_service.dart`
- Suffix widgets with descriptive names: `_screen.dart`, `_card.dart`, `_dialog.dart`

**Classes:**
- Use PascalCase: `ComponentProvider`, `DatabaseHelper`
- Interfaces start with `I`: `IDatabase`, `IComponentRepository`
- Entities end with `Entity`: `ComponentEntity`, `CategoryEntity`

**Variables & Functions:**
- Use camelCase: `filteredComponents`, `loadComponents()`
- Private members start with underscore: `_database`, `_loadComponents()`
- Boolean variables: Use positive naming (`isLoading`, not `notLoading`)

**Constants:**
- Use camelCase for local constants: `const maxThreshold = 10`

### Type Annotations
- Always specify return types for functions
- Use explicit types for class fields
- Prefer explicit types over `var` in most cases

```dart
// Good
Future<List<Component>> getAll() async { }
final List<Component> _components = [];
final IDatabase _database;

// Avoid
getAll() async { }
var _components = [];
```

### Null Safety
- Use nullable types (`?`) only when necessary
- Prefer non-nullable types with default values
- Use null-aware operators: `?.`, `??`, `??=`

```dart
String? notes;           // Nullable field
int quantity = 0;        // Non-nullable with default
final name = map['name'] as String?;  // Explicit nullable cast
```

### Widgets

**IMPORTANT: Avoid Widget-Returning Functions**

From `.cursor/rules/flutter-rules.mdc`:
- DO NOT create functions that return widgets
- ALWAYS create separate `StatelessWidget` or `StatefulWidget` classes instead
- Reason: Better performance (rebuild optimization), reusability, maintainability, and Hot Reload support

```dart
// BAD - Don't do this
Widget _buildCard() {
  return Card(child: Text('Hello'));
}

// GOOD - Do this instead
class CustomCard extends StatelessWidget {
  const CustomCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(child: Text('Hello'));
  }
}
```

**Widget Constructor:**
- Always use `const` constructors when possible
- Always include `super.key` parameter

```dart
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) { }
}
```

### Navigation with Provider

When navigating and sharing existing providers, use this pattern:

```dart
Navigator.push(
  context,  // context from parent widget
  MaterialPageRoute(
    builder: (_) => MultiProvider(  // underscore indicates unused parameter
      providers: [
        ChangeNotifierProvider.value(value: context.read<CategoryProvider>()),
        ChangeNotifierProvider.value(value: context.read<ComponentProvider>()),
      ],
      child: const DestinationScreen(),
    ),
  ),
);
```

**Key Points:**
- Use underscore `_` for unused builder parameter
- Use `ChangeNotifierProvider.value` to reuse existing instances
- Use `context.read<>()` from parent scope, not from builder parameter

### Error Handling

```dart
// In Providers
Future<bool> addComponent(Component component) async {
  try {
    final id = await _repository.create(component);
    component.id = id;
    _filteredComponents.add(component);
    return true;
  } catch (e) {
    _error = 'Erro ao adicionar componente: $e';
    return false;
  } finally {
    notifyListeners();
  }
}

// In Repositories
Future<Component?> getById(int id) async {
  final result = await db.rawQuery(query, [id]);
  if (result.isNotEmpty) {
    return Component.fromDatabaseMap(result.first);
  }
  return null;
}
```

### Database Patterns

**Table Names:**
- Plural form: `components`, `categories`
- Snake_case for column names: `category_id`, `unit_cost`, `model_normalized`

**Text Normalization:**
- Use `normalizeText()` utility for searchable fields
- Store both original and normalized versions
- Normalized fields end with `_normalized`: `model_normalized`, `location_normalized`

**Entities vs Models:**
- **Entities:** Database layer representations (in `database/entities/`)
- **Models:** Business logic representations (in `models/`)
- **Mappers:** Convert between entities and models (in `mappers/`)

---

## Project Structure

```
lib/
├── config/              # Environment configuration
├── database/
│   ├── entities/        # Database entities with normalized fields
│   ├── interfaces/      # Repository interfaces (I prefix)
│   ├── migrations/      # Database migrations
│   └── seeders/         # Database seeders
├── mappers/             # Entity <-> Model converters
├── models/              # Business models
├── providers/           # State management (ChangeNotifier)
├── repositories/        # Data access layer
├── screens/             # UI screens organized by feature
│   ├── categories/
│   ├── components/
│   ├── home/
│   │   └── widgets/    # Screen-specific widgets
│   ├── import/
│   └── reports/
├── services/            # Business services
├── utils/               # Utility functions
├── widgets/             # Shared widgets
└── main.dart            # App entry point
```

---

## Environment Variables

Copy `.env.example` to `.env` and configure:

```env
GITHUB_OWNER=your-github-username
GITHUB_REPO=app-organizador-oficina
```

Load in `main.dart`:
```dart
await dotenv.load(fileName: ".env");
```

---

## Common Patterns

### Model with copyWith
```dart
Component copyWith({int? id, String? model}) {
  return Component(
    id: id ?? this.id,
    model: model ?? this.model,
  );
}
```

### Provider Pattern
```dart
class MyProvider with ChangeNotifier {
  List<Item> _items = [];
  bool _isLoading = false;
  
  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  
  void loadItems() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _items = await repository.getAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## Key Dependencies

- **provider:** ^6.1.1 - State management
- **sqflite_common_ffi:** ^2.3.0 - SQLite for desktop
- **flutter_lints:** ^5.0.0 - Linting rules
- **flutter_dotenv:** ^5.2.1 - Environment variables
- **pdf:** ^3.10.7 - PDF export
- **csv:** ^6.0.0 - CSV export

---

## Important Notes for Agents

1. This is a WINDOWS DESKTOP app, not mobile
2. Always use `const` constructors for widgets when possible
3. Create widget classes, NOT widget functions
4. Use interfaces (I prefix) for dependency injection
5. Normalize searchable text fields for better search UX
6. Provider instances should be shared via `.value` when navigating
7. Follow the existing repository pattern for data access
8. Use `async/await` with proper error handling
9. Call `notifyListeners()` in finally blocks for state management
10. Check the Flutter rules in `.cursor/rules/flutter-rules.mdc` before making widget changes
