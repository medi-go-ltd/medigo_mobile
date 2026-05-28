#!/bin/bash

# Build and Upload iOS Release to Firebase App Distribution
# Usage: ./scripts/build-and-upload-ios.sh [--testers "email1,email2"] [release-notes]
# Note: Replace YOUR_IOS_APP_ID with your actual iOS App ID from Firebase Console

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Use FVM-managed Flutter SDK (avoids picking up a stale system Flutter install)
if [ -d "$PROJECT_ROOT/.fvm/flutter_sdk/bin" ]; then
  export PATH="$PROJECT_ROOT/.fvm/flutter_sdk/bin:$PATH"
elif command -v fvm &>/dev/null; then
  FLUTTER_CMD="fvm flutter"
else
  FLUTTER_CMD="flutter"
fi
FLUTTER_CMD="${FLUTTER_CMD:-flutter}"

TESTERS=""
RELEASE_NOTES=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --testers)
      TESTERS="$2"
      shift 2
      ;;
    *)
      RELEASE_NOTES="$1"
      shift
      ;;
  esac
done
RELEASE_NOTES="${RELEASE_NOTES:-$(git log -1 --pretty=%B)}"
APP_ID="1:118670844588:ios:048f1e88f63fbe6ed2f509"
IPA_PATH="build/ios/ipa/medigo_mobile.ipa"

echo "🚀 Building iOS release IPA..."
$FLUTTER_CMD build ipa --release --export-method=ad-hoc

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
DISTRIBUTE_ARGS=(
  --token "1//03b1SHKkJy1PxCgYIARAAGAMSNwF-L9IrUIEgR_ypSCgchWEyZqvsPqtxKH4P_3gKNft4oBeP1szfuXWENccUxp-n7gVtw8g7moA"
  --app "$APP_ID"
  --release-notes "$RELEASE_NOTES"
)
if [ -n "$TESTERS" ]; then
  DISTRIBUTE_ARGS+=(--testers "$TESTERS")
else
  DISTRIBUTE_ARGS+=(--groups "ios-testing")
fi

firebase appdistribution:distribute "$IPA_PATH" "${DISTRIBUTE_ARGS[@]}"

echo "✅ Build and upload complete!"
echo "📱 Testers will receive an email notification"

