import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// Launches the device's map app for navigation to the given address.
/// Uses Google Maps on Android and Apple Maps on iOS.
Future<bool> launchMapNavigation(String address) async {
  final encoded = Uri.encodeComponent(address);
  Uri url;

  if (Platform.isIOS) {
    url = Uri.parse('https://maps.apple.com/?q=$encoded');
  } else {
    url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
  }

  return launchUrl(url, mode: LaunchMode.externalApplication);
}
