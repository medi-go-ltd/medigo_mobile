# Firebase Setup Guide

This guide will help you set up Firebase for the MediGo Mobile app.

## Prerequisites

1. A Firebase account (create one at https://console.firebase.google.com/)
2. Flutter CLI installed
3. Android Studio / Xcode (for platform-specific setup)

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "MediGo Mobile" (or your preferred name)
4. Follow the setup wizard

## Step 2: Add Android App

1. In Firebase Console, click "Add app" and select Android
2. Enter package name: `com.medigo.medigo`
3. Download `google-services.json`
4. Place the file in: `android/app/google-services.json`

## Step 3: Add iOS App

1. In Firebase Console, click "Add app" and select iOS
2. Enter bundle ID: `com.medigo.medigo` (check your `ios/Runner.xcodeproj` for the actual bundle ID)
3. Download `GoogleService-Info.plist`
4. Place the file in: `ios/Runner/GoogleService-Info.plist`
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click on `Runner` folder → "Add Files to Runner"
7. Select `GoogleService-Info.plist` and ensure "Copy items if needed" is checked

## Step 4: Install Dependencies

Run the following command to install Flutter dependencies:

```bash
flutter pub get
```

For iOS, also run:

```bash
cd ios
pod install
cd ..
```

## Step 5: Enable Firebase Services

In Firebase Console, enable the services you need:

- **Authentication**: For user login/signup
- **Firestore**: For database storage
- **Storage**: For file uploads (images, documents)

## Step 6: Configure Authentication (Optional)

If you want to use Firebase Authentication:

1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable sign-in methods you want to use (Email/Password, Google, etc.)

## Step 7: Configure Firestore (Optional)

If you want to use Firestore:

1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in test mode (for development)
4. Choose a location for your database

## Verification

After setup, run the app:

```bash
flutter run
```

The app should initialize Firebase without errors. Check the console logs for "Firebase initialized successfully".

## Troubleshooting

### Android Issues

- **Error: "google-services.json not found"**
  - Ensure `google-services.json` is in `android/app/` directory
  - Clean and rebuild: `flutter clean && flutter pub get && flutter run`

- **Error: "Plugin with id 'com.google.gms.google-services' not found"**
  - Check that `settings.gradle.kts` includes the Google Services plugin
  - Sync Gradle files in Android Studio

### iOS Issues

- **Error: "GoogleService-Info.plist not found"**
  - Ensure the file is added to Xcode project
  - Check that it's included in the target membership

- **CocoaPods errors**
  - Run `cd ios && pod deintegrate && pod install && cd ..`
  - Ensure minimum iOS version is 14.0 or higher

## Next Steps

Now that Firebase is set up, you can:

1. Implement Firebase Authentication in your auth repository
2. Use Firestore to store user data and doctor information
3. Use Firebase Storage for profile images and documents
4. Implement push notifications with Firebase Cloud Messaging (FCM)

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Authentication Guide](https://firebase.flutter.dev/docs/auth/overview)
- [Cloud Firestore Guide](https://firebase.flutter.dev/docs/firestore/overview)

