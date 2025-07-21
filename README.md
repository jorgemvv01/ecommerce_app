# E-commerce - Flutter application

A robust and scalable e-commerce application built with Flutter, following Clean Architecture principles and powered by Riverpod for state management.

## Overview

This project is a feature-rich e-commerce mobile application designed to provide a seamless shopping experience. It consumes a custom `FakeStoreApiClient` package for backend interactions and is built with a strong emphasis on code quality, scalability, and testability.

## Features Implemented

* **Authentication flow**:
    * User login with username and password.
    * New user registration.
    * Secure session persistence using `flutter_secure_storage`.
    * User logout.
* **Product catalog**:
    * Displays a grid of all available products.
    * Real-time search functionality to filter products by title or description.
    * Filter products by category using dynamic choice chips.
    * "Pull-to-refresh" functionality to reload products.
* **Product detail**:
    * A dedicated screen showing detailed information for a selected product, including image, price, rating, and full description.
* **Shopping cart**:
    * In-memory (local) cart management.
    * Add products to the cart directly from the product list or detail screen.
    * Update product quantities (increment/decrement).
    * Clear all items from the cart with a confirmation dialog.
    * A persistent cart icon in the `AppBar` showing the total number of items.
* **Support & contact**:
    * A static information screen providing contact details for user support.

## Architecture

The application is built upon **Clean Architecture** principles to ensure a clear separation of concerns, making the codebase modular, independent of the UI and data sources, and highly testable.

### Project Structure

```
lib/
├── core/               # Shared code (errors, exceptions, widgets, etc.)
└── features/           # Application features (auth, products, cart, etc.)
    └── <feature_name>/
        ├── data/       # Data layer implementation
        ├── domain/     # Business logic (core)
        └── presentation/ # UI Layer (Flutter widgets)
```

### Layers explained

#### 1. Domain layer

This is the core of the application. It contains the business logic and is completely independent of any other layer.

* **`entities/`**: Pure Dart objects representing the core business models (e.g., `Product`, `User`). They have no knowledge of JSON parsing or UI.
* **`repositories/`**: Abstract classes (contracts) that define the operations that can be performed for an entity (e.g., `ProductRepository`).
* **`usecases/`**: Encapsulate a single business rule or action (e.g., `GetProducts`, `LoginUser`). They orchestrate data flow from repositories.

#### 2. Data layer

This layer is responsible for retrieving data from external sources and implementing the repository contracts defined in the domain.

* **`models/`**: Data Transfer Objects (DTOs) that represent data from the API. They extend domain `Entities` and include `fromJson`/`toJson` logic.
* **`gateways/`**: Implements the **Gateway Pattern**. These classes are responsible for communicating with a single data source (e.g., `ProductRemoteGateway` for the API, `AuthLocalGateway` for secure storage).
* **`repositories/`**: Concrete implementations of the repository contracts. They coordinate one or more gateways to fulfill a request, handle exceptions, and convert them into business-friendly `Failures`.

#### 3. Presentation layer

This layer contains everything related to the UI. It is powered by Flutter and Riverpod.

* **`screens/`**: The main pages of the application (e.g., `ProductsScreen`, `LoginScreen`).
* **`widgets/`**: Reusable UI components specific to a feature (e.g., `ProductCard`).
* **`viewmodels/`**: Implements the **ViewModel Pattern** using `StateNotifier`. These classes hold the UI state, expose methods for user interactions, and call the appropriate `UseCases` from the domain layer.
* **`providers/`**: The dependency injection and state management hub for each feature, using `Riverpod` to connect all layers.

## State management

* **Riverpod**: Chosen for its compile-safe dependency injection, declarative state management, and excellent testability.
* **ViewModel pattern (`StateNotifier`)**: Each screen with complex logic has a dedicated `ViewModel` (`StateNotifier`) that holds its state (`State` class) and exposes methods to modify it. This keeps the UI widgets clean and focused only on rendering the state.

## Testing strategy

The application has a comprehensive testing suite to ensure code quality and prevent regressions.

* **Unit tests**: Located in the `test/` directory, mirroring the `lib/` structure. They test individual classes (`UseCases`, `Repositories`, `Gateways`, `ViewModels`) in isolation using the `mocktail` package to mock dependencies.
* **Widget tests**: Also in the `test/` directory. They test individual widgets (`ProductCard`, `LoginScreen`, etc.) to verify UI rendering and user interactions. `Riverpod`'s override capabilities are used to provide mock `ViewModels`.
* **Integration tests**: Located in the `integration_test/` directory. These tests run the full application on an emulator or device to verify complete user flows, such as login, adding a product to the cart, and logging out. API calls are mocked at the `ApiClient` level to ensure tests are fast and reliable.

### Running tests

**Run all unit and widget tests**:
```
flutter test
```
**Run integration tests**:
```
flutter test integration_test
```
**Generate coverage report**:
```
flutter test --coverage
genhtml coverage/lcov.info -ocoverage/html
```

###  Unit and widget test coverage:
<img src="https://github.com/jorgemvv01/ecommerce_app/raw/main/resources/unit_and_widget_test_coverage.jpg" alt="unit and widget test coverage" width="400"/>

###  Integration test coverage:
<img src="https://github.com/jorgemvv01/ecommerce_app/raw/main/resources/integration_test_coverage.jpg" alt="integration test coverage" width="400"/>

## Application flowchart

This diagram describes the navigation flow and main user interactions throughout the application.

<img src="https://github.com/jorgemvv01/ecommerce_app/raw/main/resources/app-flow.jpg" alt="application flowchart" width="400"/>