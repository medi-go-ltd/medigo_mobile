class AddressUtils {
  static final _ukPostcodeRegex = RegExp(
    r'^[A-Za-z]{1,2}[0-9][0-9A-Za-z]?\s*[0-9][A-Za-z]{2}$',
  );

  static String formatAddress({
    required String line1,
    String? line2,
    required String town,
    required String postcode,
  }) {
    final parts = <String>[line1.trim()];
    if (line2 != null && line2.trim().isNotEmpty) {
      parts.add(line2.trim());
    }
    parts.add(town.trim());
    parts.add(postcode.trim().toUpperCase());
    return parts.join(', ');
  }

  static ({String line1, String line2, String town, String postcode})
  parseAddress(String address) {
    final trimmed = address.trim();
    if (trimmed.isEmpty) {
      return (line1: '', line2: '', town: '', postcode: '');
    }

    final postcodeMatch = RegExp(
      r'[A-Za-z]{1,2}[0-9][0-9A-Za-z]?\s*[0-9][A-Za-z]{2}\s*$',
    ).firstMatch(trimmed);

    String postcode = '';
    String beforePostcode = trimmed;

    if (postcodeMatch != null) {
      postcode = postcodeMatch.group(0)!.trim().toUpperCase();
      beforePostcode = trimmed.substring(0, postcodeMatch.start).trim();
      if (beforePostcode.endsWith(',')) {
        beforePostcode = beforePostcode
            .substring(0, beforePostcode.length - 1)
            .trim();
      }
    }

    String line1 = beforePostcode;
    String line2 = '';
    String town = '';

    if (beforePostcode.isNotEmpty) {
      final parts = beforePostcode.split(',').map((p) => p.trim()).toList();
      if (parts.length >= 2) {
        town = parts.removeLast();
        line1 = parts.take(parts.length).join(', ');
        if (parts.length >= 2) {
          line2 = parts.removeLast();
          line1 = parts.join(', ');
        }
      }
    }

    return (line1: line1, line2: line2, town: town, postcode: postcode);
  }

  static bool isValidUkPostcode(String value) {
    return _ukPostcodeRegex.hasMatch(value.trim().replaceAll(' ', ''));
  }
}
