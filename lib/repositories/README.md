# Repository Pattern

This directory contains the repository implementations for authentication.

## Architecture

We use the **Repository Pattern** with an interface to allow for easy switching between real API calls and mock data for testing/development.

### Files

- `i_auth_repository.dart` - Abstract interface defining the contract
- `auth_repository.dart` - Real implementation that calls the actual API
- `mock_auth_repository.dart` - Mock implementation that uses JSON data from assets

## Usage

### Switching Between Mock and Real API

Edit `lib/config/app_config.dart`:

```dart
class AppConfig {
  // Set to true for development/testing (uses mock data)
  // Set to false for production (uses real API)
  static const bool useMockData = true;
}
```

### Using in View Models

The `LoginViewModel` automatically uses the correct repository based on `AppConfig.useMockData`:

```dart
final viewModel = LoginViewModel(); // Uses default repository
```

### Dependency Injection for Testing

You can also inject a specific repository for testing:

```dart
final mockRepo = MockAuthRepository();
final viewModel = LoginViewModel(authRepository: mockRepo);
```

## Mock Data

Mock responses are stored in `assets/mock_data/mock_login_response.json`.

To customize mock responses, edit the JSON file or modify the `MockAuthRepository` class.


