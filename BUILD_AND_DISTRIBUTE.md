# Building Release Builds and Uploading to Firebase

This guide covers building release builds for Android and iOS, and uploading them to Firebase App Distribution.

## Prerequisites

1. Firebase project set up (already done)
2. Firebase App Distribution enabled in Firebase Console
3. Firebase CLI installed (for automated uploads)
4. Android signing key (for production Android builds)
5. Apple Developer account (for iOS builds)

---

## Part 1: Building Release Builds

### Android Release Build

#### Option A: Build APK (for testing)

```bash
# Build release APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

#### Option B: Build App Bundle (for Google Play Store)

```bash
# Build release App Bundle
flutter build appbundle --release

# The AAB will be at: build/app/outputs/bundle/release/app-release.aab
```

#### Option C: Build Split APKs (smaller file size)

```bash
# Build split APKs by ABI
flutter build apk --release --split-per-abi

# APKs will be at:
# - build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# - build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# - build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### iOS Release Build

#### Build IPA for Distribution

```bash
# Build iOS release
flutter build ipa --release

# The IPA will be at: build/ios/ipa/medigo_mobile.ipa
```

**Note:** For iOS, you'll need:
- Xcode installed
- Valid provisioning profile
- Apple Developer account
- Signing certificates configured in Xcode

---

## Part 2: Setting Up Firebase App Distribution

### Step 1: Enable Firebase App Distribution

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `medi-go-44a20`
3. Navigate to **App Distribution** (in the left sidebar)
4. Click **Get started** if not already enabled
5. Accept the terms and enable the service

### Step 2: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Or using Homebrew (macOS)
brew install firebase-cli

# Login to Firebase
firebase login

# Verify installation
firebase --version
```

### Step 3: Install Firebase App Distribution CLI Plugin

```bash
# Install the App Distribution plugin
firebase appdistribution:install

# Or use the standalone CLI
# Download from: https://firebase.google.com/docs/app-distribution/ios/distribute-cli
```

---

## Part 3: Uploading Builds to Firebase App Distribution

### Method 1: Using Firebase CLI (Recommended)

#### For Android APK:

```bash
# Upload APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:118670844588:android:be3eb7c20639233ad2f509 \
  --groups "testers" \
  --release-notes "Release notes here"
```

#### For Android App Bundle:

```bash
# First convert AAB to APK (or use the APK method above)
# Or upload directly if Firebase supports it
firebase appdistribution:distribute build/app/outputs/bundle/release/app-release.aab \
  --app 1:118670844588:android:be3eb7c20639233ad2f509 \
  --groups "testers"
```

#### For iOS IPA:

```bash
# Upload IPA
firebase appdistribution:distribute build/ios/ipa/medigo_mobile.ipa \
  --app YOUR_IOS_APP_ID \
  --groups "testers" \
  --release-notes "iOS release notes"
```

**To find your iOS App ID:**
1. Go to Firebase Console → Project Settings
2. Find your iOS app
3. Copy the App ID

### Method 2: Using Firebase Console (Web UI)

1. Go to Firebase Console → **App Distribution**
2. Click **Release** → **Upload release**
3. Select your APK/IPA file
4. Add release notes
5. Select testers or groups
6. Click **Distribute**

### Method 3: Using Fastlane (Advanced)

Create a `fastlane/Fastfile`:

```ruby
lane :distribute_android do
  sh("flutter build apk --release")
  firebase_app_distribution(
    app: "1:118670844588:android:be3eb7c20639233ad2f509",
    apk_path: "build/app/outputs/flutter-apk/app-release.apk",
    groups: "testers",
    release_notes: "New release"
  )
end

lane :distribute_ios do
  sh("flutter build ipa --release")
  firebase_app_distribution(
    app: "YOUR_IOS_APP_ID",
    ipa_path: "build/ios/ipa/medigo_mobile.ipa",
    groups: "testers",
    release_notes: "iOS release"
  )
end
```

---

## Part 4: Managing Testers

### Add Testers via Firebase Console

1. Go to Firebase Console → **App Distribution** → **Testers & Groups**
2. Click **Add tester**
3. Enter email addresses
4. Click **Add**

### Create Tester Groups

1. Go to **Testers & Groups**
2. Click **Create group**
3. Name the group (e.g., "QA Team", "Beta Testers")
4. Add testers to the group
5. Use the group name in distribution commands

### Add Testers via CLI

```bash
# Add a tester
firebase appdistribution:testers:add tester@example.com \
  --app 1:118670844588:android:be3eb7c20639233ad2f509

# Create a group
firebase appdistribution:groups:create "qa-team" \
  --app 1:118670844588:android:be3eb7c20639233ad2f509

# Add tester to group
firebase appdistribution:groups:add testers@example.com \
  --group "qa-team" \
  --app 1:118670844588:android:be3eb7c20639233ad2f509
```

---

## Part 5: Automated Build Scripts

### Android Build and Upload Script

Create `scripts/build-and-upload-android.sh`:

```bash
#!/bin/bash

# Build release APK
echo "Building Android release APK..."
flutter build apk --release

# Upload to Firebase App Distribution
echo "Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:118670844588:android:be3eb7c20639233ad2f509 \
  --groups "testers" \
  --release-notes "$(git log -1 --pretty=%B)"

echo "✅ Build and upload complete!"
```

Make it executable:
```bash
chmod +x scripts/build-and-upload-android.sh
```

### iOS Build and Upload Script

Create `scripts/build-and-upload-ios.sh`:

```bash
#!/bin/bash

# Build release IPA
echo "Building iOS release IPA..."
flutter build ipa --release

# Upload to Firebase App Distribution
echo "Uploading to Firebase App Distribution..."
firebase appdistribution:distribute build/ios/ipa/medigo_mobile.ipa \
  --app YOUR_IOS_APP_ID \
  --groups "testers" \
  --release-notes "$(git log -1 --pretty=%B)"

echo "✅ Build and upload complete!"
```

---

## Part 6: CI/CD Integration (GitHub Actions)

Create `.github/workflows/firebase-distribution.yml`:

```yaml
name: Build and Distribute

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_ANDROID_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          file: build/app/outputs/flutter-apk/app-release.apk
          groups: testers
          releaseNotes: ${{ github.event.head_commit.message }}

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build IPA
        run: flutter build ipa --release
      
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_IOS_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          file: build/ios/ipa/medigo_mobile.ipa
          groups: testers
          releaseNotes: ${{ github.event.head_commit.message }}
```

---

## Part 7: Quick Reference Commands

### Build Commands

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS IPA
flutter build ipa --release

# Clean build
flutter clean && flutter pub get
```

### Upload Commands

```bash
# Android
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:118670844588:android:be3eb7c20639233ad2f509 \
  --groups "testers"

# iOS
firebase appdistribution:distribute build/ios/ipa/medigo_mobile.ipa \
  --app YOUR_IOS_APP_ID \
  --groups "testers"
```

---

## Troubleshooting

### Android Issues

- **"App not found"**: Verify the App ID in Firebase Console
- **"Permission denied"**: Ensure you're logged in with `firebase login`
- **"File too large"**: Use split APKs or optimize assets

### iOS Issues

- **"Invalid IPA"**: Ensure the build is signed correctly
- **"Provisioning profile error"**: Check Xcode signing settings
- **"App ID mismatch"**: Verify the App ID matches Firebase Console

### General Issues

- **"Not authenticated"**: Run `firebase login`
- **"Plugin not found"**: Run `firebase appdistribution:install`
- **"Network error"**: Check internet connection and Firebase status

---

## Next Steps

1. Set up signing keys for production Android builds
2. Configure iOS provisioning profiles for distribution
3. Set up automated CI/CD pipelines
4. Create tester groups for organized distribution
5. Set up release notes templates

---

## Resources

- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [Flutter Build Docs](https://docs.flutter.dev/deployment/android)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

