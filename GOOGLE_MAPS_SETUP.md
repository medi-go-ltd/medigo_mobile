# Google Maps Setup Instructions

This app uses Google Maps to display live location and doctor markers. You need to set up a Google Maps API key.

## Steps to Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
4. Go to "Credentials" → "Create Credentials" → "API Key"
5. Copy your API key

## Configure API Key

### Android

Edit `android/app/src/main/AndroidManifest.xml`:

Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE" />
```

### iOS

Edit `ios/Runner/AppDelegate.swift`:

Replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

## Restrict Your API Key (Recommended)

For security, restrict your API key:

1. Go to Google Cloud Console → Credentials
2. Click on your API key
3. Under "Application restrictions":
   - For Android: Add your package name and SHA-1 certificate fingerprint
   - For iOS: Add your bundle identifier
4. Under "API restrictions": Restrict to "Maps SDK for Android" and "Maps SDK for iOS"

## Testing

After adding your API key, rebuild the app:

```bash
flutter clean
flutter pub get
flutter run
```

The map should now display with your live location and doctor markers!

## Important Notes

### Google Logo
**Note:** The Google logo must remain visible on the map as per Google Maps Terms of Service. You cannot legally hide or remove it. The implementation includes padding to minimize its visual impact, but it must remain visible.

### Map Not Showing?
If the map appears blank or grey:
1. Verify your API key is correctly set in both Android and iOS configuration files
2. Ensure the Maps SDK APIs are enabled in Google Cloud Console
3. Check that your API key restrictions allow your app's package name/bundle ID
4. Rebuild the app after adding the API key:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

