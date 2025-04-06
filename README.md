# CPP App

A Flutter application built with Clean Architecture principles.

## Project Overview

This project follows clean architecture guidelines as recommended by the Flutter team. The architecture is structured to maintain separation of concerns, making the codebase modular, testable, and maintainable.

## Architecture

The project is organized using **Clean Architecture** with three main layers:

### 1. Domain Layer
The innermost layer containing the business logic of the application.
- **Entities**: Core business objects (e.g., Order, OrderItem)
- **Repositories**: Abstract interfaces defining methods for data operations
- **Use Cases**: Individual business logic units representing application actions

### 2. Data Layer
The layer that implements repositories from the domain layer.
- **Models**: Extensions of domain entities with serialization/deserialization functionality
- **Repositories Implementations**: Concrete implementations of domain repositories
- **Data Sources**: Classes responsible for fetching data from external sources (API, local storage)

### 3. Presentation Layer
The outermost layer handling UI and user interaction.
- **Cubits**: State management components using flutter_bloc (simplified BLoC pattern)
- **Pages**: Screen UI components
- **Widgets**: Reusable UI elements specific to features

## Data Flow

### 1. Request Flow (UI to Data Source)
1. **User Interaction**: User interacts with a UI element (e.g., pressing a button to load orders)
2. **Cubit Action**: The UI calls a method on the appropriate Cubit
3. **Cubit State**: The Cubit emits a loading state and calls the appropriate Use Case
4. **Use Case**: The Use Case calls the corresponding Repository method
5. **Repository**: The Repository Implementation delegates to the appropriate Data Source
6. **Data Source**: The Data Source makes API calls or database queries to fetch data

### 2. Response Flow (Data Source to UI)
1. **Data Source**: Returns models from external sources (API response)
2. **Repository**: Handles errors, transforms models to entities, and returns wrapped in Either type
3. **Use Case**: Processes the repository response (may apply additional business logic)
4. **Cubit**: Receives the response and emits an appropriate state (success/error)
5. **UI**: Reacts to the new state and updates the display

### Error Handling
- Errors are captured at the Repository level and transformed into Failure objects
- The Either type (from dartz package) is used to represent success or failure outcomes
- UI displays appropriate error messages based on Failure types

## Current Features

The application currently implements the **Orders** feature with three main flows:
1. **Order Listing**: Displays all orders with essential information
2. **Order Details**: Shows comprehensive information about a selected order
3. **Order Creation**: Allows users to create new orders with customer and item details

## Technologies Used

- **State Management**: flutter_bloc with Cubits
- **Dependency Injection**: get_it
- **Navigation**: go_router
- **Network**: dio for API communication
- **Data Handling**: equatable for equality, dartz for functional programming

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## Resources

For help getting started with Flutter development:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

## Firebase & CI/CD Setup

### Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download the configuration files:
   - For Android: `google-services.json` and place it in `android/app/`
   - For iOS: `GoogleService-Info.plist` and place it in `ios/Runner/`

4. Initialize Firebase in your Flutter app:

```dart
// In main.dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}
```

### GitHub Actions CI/CD Setup

The project is configured with GitHub Actions for CI/CD. To enable the workflow:

1. Add the following secrets to your GitHub repository:
   - `FIREBASE_TOKEN`: Firebase CLI token (get it with `firebase login:ci`)
   - `FIREBASE_APP_ID`: Your Android app ID from Firebase
   - `FIREBASE_IOS_APP_ID`: Your iOS app ID from Firebase
   - `FIREBASE_PROJECT_ID`: Your Firebase project ID
   - `FIREBASE_SERVICE_ACCOUNT`: Firebase service account credentials (JSON)
   - `MATCH_PASSWORD`: Password for your iOS certificates repository
   - `MATCH_GIT_BASIC_AUTH`: Base64-encoded GitHub username:token for fastlane match
   - `APPLE_ID`: Your Apple ID email
   - `TEAM_ID`: Your Apple Developer Team ID
   - `APP_STORE_CONNECT_API_KEY_CONTENT`: Your App Store Connect API key JSON

2. Push to the `main` branch to trigger the workflow
3. You can also manually trigger the workflow from the GitHub Actions tab

### Testing Distribution

Once set up, each push to `main` will:
1. Run tests
2. Build Android APK and iOS IPA
3. Distribute to testers via Firebase App Distribution


flutter test --coverage && lcov --summary coverage/lcov.info