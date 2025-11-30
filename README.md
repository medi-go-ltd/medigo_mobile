# MediGo Mobile

A Flutter mobile application for connecting patients with healthcare providers. MediGo facilitates seamless communication and appointment management between doctors and patients.

## Features

- **Splash Screen**: Animated welcome screen with app branding
- **Role Selection**: Choose between Doctor or Patient account types
- **Authentication**: Secure login and registration flows
- **Role-Based UI**: Different registration fields based on user role
  - Doctors: Medical Registration Number
  - Patients: Password confirmation
- **Modern Design**: Clean, minimalist UI with custom theme and typography

## Getting Started

### Prerequisites

- Flutter SDK (>=3.9.0)
- Dart SDK (>=3.9.0-0)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDEs)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd medigo_mobile
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── features/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── splash/
│   │   └── splash_screen.dart
│   └── welcome/
│       └── welcome_screen.dart
├── models/
│   └── user_role.dart
├── routes/
│   └── app_routes.dart
├── theme/
│   └── app_theme.dart
└── main.dart
```

## Theme & Styling

The app uses a centralized theme system defined in `lib/theme/app_theme.dart`:

- **Colors**: Primary teal (#2EA5B7), dark blue accents, and semantic colors
- **Typography**: Custom MedigoSans font family with defined text styles
- **Components**: Consistent button styles, input fields, and spacing

## Routes

The app uses named routes managed by `AppRoutes`:

- `/` - Splash screen
- `/welcome` - Welcome/role selection screen
- `/login` - Login screen (requires UserRole argument)
- `/signup` - Registration screen (requires UserRole argument)

## Testing

Run tests with:
```bash
flutter test
```

The project includes widget tests for:
- App initialization
- Welcome screen
- Login screen (doctor and patient variants)
- Navigation flows

## Code Quality

- **Linting**: Configured with `flutter_lints` and custom rules
- **CI/CD**: GitHub Actions workflow for automated testing and analysis
- **Analysis**: Run `flutter analyze` to check code quality

## Building

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Ensure tests pass and code analysis is clean
4. Submit a pull request

## License

[Add your license here]

## Support

For issues and questions, please open an issue in the repository.
