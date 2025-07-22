# VisuaLit Flutter Development Guidelines

This document provides essential information for developers working on the VisuaLit Flutter project.

## Build/Configuration Instructions

### Environment Setup

1. **Flutter SDK**: This project requires Flutter SDK version 3.8.1 or higher.
   ```bash
   flutter --version
   ```

2. **Environment Variables**: The project uses a `.env` file for environment variables.
   - Create a `.env` file in the project root if it doesn't exist
   - Required variables:
     ```
     APPWRITE_ENDPOINT=your_appwrite_endpoint
     APPWRITE_PROJECT_ID=your_project_id
     ```

### Building the Project

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate Code**:
   The project uses code generation for Isar database models and Riverpod providers.
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Testing Information

### Test Configuration

1. **Flutter Test Framework**: The project uses the standard Flutter test framework.

2. **Test Dependencies**:
   - `flutter_test`: Standard Flutter testing package
   - No additional test dependencies are required

### Running Tests

1. **Run All Tests**:
   ```bash
   flutter test
   ```

2. **Run Specific Test File**:
   ```bash
   flutter test test/path/to/test_file.dart
   ```

3. **Run Tests with Coverage**:
   ```bash
   flutter test --coverage
   ```

### Adding New Tests

1. **Unit Tests**: Place in the `test` directory following the same structure as the lib directory.
   
   Example for testing a model:
   ```dart
   // test/models/book_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:visualit/features/reader/data/book_data.dart';
   
   void main() {
     group('Book Model Tests', () {
       test('Book should initialize with default values', () {
         final book = Book();
         expect(book.title, isNull);
         expect(book.status, ProcessingStatus.queued);
       });
     });
   }
   ```

2. **Widget Tests**: For testing UI components.
   
   Example:
   ```dart
   // test/widgets/book_card_test.dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:visualit/shared_widgets/book_card.dart';
   
   void main() {
     testWidgets('BookCard displays title and author', (WidgetTester tester) async {
       await tester.pumpWidget(MaterialApp(
         home: BookCard(
           title: 'Test Book',
           author: 'Test Author',
         ),
       ));
       
       expect(find.text('Test Book'), findsOneWidget);
       expect(find.text('Test Author'), findsOneWidget);
     });
   }
   ```

3. **Integration Tests**: For testing app flows, create files in the `integration_test` directory.

## Additional Development Information

### Project Architecture

The project follows a feature-first architecture:

- **Core**: Contains app-wide utilities, services, and configurations
  - `api`: API clients and services
  - `models`: Shared data models
  - `providers`: Global state providers
  - `router`: Navigation configuration
  - `services`: App-wide services
  - `theme`: Theme configuration

- **Features**: Each feature has its own directory with the following structure:
  - `data`: Data models and repositories
  - `domain`: Business logic and use cases
  - `presentation`: UI components and controllers

### State Management

- The project uses **Riverpod** for state management
- Controllers are implemented as providers in the presentation layer
- Use `ref.watch` for reactive state and `ref.read` for actions

### Database

- **Isar** is used for local database storage
- Model classes are annotated with `@collection` and `@embedded`
- Run code generation after modifying model classes:
  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

### Navigation

- **Go Router** is used for navigation
- Routes are defined in `lib/core/router/app_router.dart`
- Use the `context.go('/route')` or `ref.read(goRouterProvider).go('/route')` for navigation

### Code Style

- Follow the [Flutter style guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- Use named parameters for widget constructors
- Prefer const constructors when possible
- Use trailing commas for better formatting