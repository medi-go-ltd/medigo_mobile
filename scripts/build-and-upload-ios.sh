#!/bin/bash

# Build and Upload iOS Release to Firebase App Distribution
# Usage: ./scripts/build-and-upload-ios.sh [release-notes]
# Note: Replace YOUR_IOS_APP_ID with your actual iOS App ID from Firebase Console

set -e

RELEASE_NOTES="${1:-$(git log -1 --pretty=%B)}"
APP_ID="1:118670844588:ios:048f1e88f63fbe6ed2f509"
IPA_PATH="build/ios/ipa/medigo_mobile.ipa"

echo "🚀 Building iOS release IPA..."
flutter build ipa --release --export-method=ad-hoc

if [ ! -f "$IPA_PATH" ]; then
    echo "❌ Error: IPA not found at $IPA_PATH"
    exit 1
fi

if [ "$APP_ID" == "YOUR_IOS_APP_ID" ]; then
    echo "❌ Error: Please set YOUR_IOS_APP_ID in this script"
    echo "   Get it from Firebase Console → Project Settings → Your iOS App"
    exit 1
fi

echo "📤 Uploading to Firebase App Distribution..."
firebase appdistribution:distribute "$IPA_PATH" \
  --token "1//03b1SHKkJy1PxCgYIARAAGAMSNwF-L9IrUIEgR_ypSCgchWEyZqvsPqtxKH4P_3gKNft4oBeP1szfuXWENccUxp-n7gVtw8g7moA" \
  --app "$APP_ID" \
  --groups "ios-testing" \
  --release-notes "$RELEASE_NOTES"

echo "✅ Build and upload complete!"
echo "📱 Testers will receive an email notification"

