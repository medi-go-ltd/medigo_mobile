#!/bin/bash

# Build and Upload Android Release to Firebase App Distribution
# Usage: ./scripts/build-and-upload-android.sh [release-notes]

set -e

RELEASE_NOTES="${1:-$(git log -1 --pretty=%B)}"
APP_ID="1:118670844588:android:be3eb7c20639233ad2f509"
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

echo "🚀 Building Android release APK..."
flutter build apk --release

if [ ! -f "$APK_PATH" ]; then
    echo "❌ Error: APK not found at $APK_PATH"
    exit 1
fi

echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute "$APK_PATH" \
  --app "$APP_ID" \
  --groups "testers" \
  --release-notes "$RELEASE_NOTES"

echo "✅ Build and upload complete!"
echo "📱 Testers will receive an email notification"

