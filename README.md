# CPP App

A Flutter application built with Clean Architecture principles.

## Project Overview

This project follows clean architecture guidelines as recommended by the Flutter team. The architecture is structured to maintain separation of concerns, making the codebase modular, testable, and maintainable.

## Architecture

The project is organized into the following main components:

### Core
- **Error**: Centralized error handling and custom exceptions
- **Network**: Network utilities, API client, and connection handling
- **DI**: Dependency injection setup using service locator pattern
- **Utils**: Common utility functions and extensions
- **Widgets**: Reusable UI components

### Features
Each feature is organized into its own module following the clean architecture layers:
- **Data**: Models, repositories implementation, and data sources
- **Domain**: Entities, repositories interfaces, and use cases
- **Presentation**: UI components, state management (BLoC)

Current features include:
- Home
- Authentication
- Orders

### Config
Contains app-wide configuration including:
- Theme
- Routes
- Constants

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Resources

For help getting started with Flutter development:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)
