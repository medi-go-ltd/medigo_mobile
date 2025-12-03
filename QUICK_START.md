# Quick Start: Build & Upload to Firebase

## 🚀 Quick Commands

### Android - Build & Upload in One Command

```bash
# Using the script (recommended)
./scripts/build-and-upload-android.sh

# Or manually
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:118670844588:android:be3eb7c20639233ad2f509 \
  --groups "testers" \
  --release-notes "Your release notes here"
```

### iOS - Build & Upload in One Command

```bash
# First, update YOUR_IOS_APP_ID in scripts/build-and-upload-ios.sh
# Then run:
./scripts/build-and-upload-ios.sh

# Or manually
flutter build ipa --release
firebase appdistribution:distribute build/ios/ipa/medigo_mobile.ipa \
  --app YOUR_IOS_APP_ID \
  --groups "testers" \
  --release-notes "Your release notes here"
```

## 📋 Prerequisites Checklist

- [ ] Firebase CLI installed: `npm install -g firebase-tools`
- [ ] Logged in to Firebase: `firebase login`
- [ ] Firebase App Distribution enabled in Firebase Console
- [ ] Testers added in Firebase Console → App Distribution → Testers & Groups
- [ ] For iOS: Apple Developer account and signing configured

## 🔍 Find Your App IDs

### Android App ID (already configured)
```
1:118670844588:android:be3eb7c20639233ad2f509
```

### iOS App ID
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `medi-go-44a20`
3. Click ⚙️ (Settings) → Project Settings
4. Scroll to "Your apps"
5. Find your iOS app and copy the App ID

## 📱 Adding Testers

### Via Firebase Console (Easiest)
1. Go to Firebase Console → App Distribution
2. Click "Testers & Groups"
3. Click "Add tester" or "Create group"
4. Enter email addresses

### Via CLI
```bash
# Add individual tester
firebase appdistribution:testers:add tester@example.com \
  --app 1:118670844588:android:be3eb7c20639233ad2f509

# Create group
firebase appdistribution:groups:create "qa-team" \
  --app 1:118670844588:android:be3eb7c20639233ad2f509
```

## 🎯 Common Workflows

### Daily Testing Build
```bash
./scripts/build-and-upload-android.sh "Daily build - $(date +%Y-%m-%d)"
```

### Release Candidate
```bash
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:118670844588:android:be3eb7c20639233ad2f509 \
  --groups "qa-team" \
  --release-notes "Release Candidate v1.0.0"
```

### Both Platforms
```bash
# Android
./scripts/build-and-upload-android.sh "Release v1.0.0"

# iOS (after updating App ID)
./scripts/build-and-upload-ios.sh "Release v1.0.0"
```

## 📚 Full Documentation

See [BUILD_AND_DISTRIBUTE.md](./BUILD_AND_DISTRIBUTE.md) for complete details.

