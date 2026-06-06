import 'package:flutter/material.dart';

/// UK date display and parsing helpers (DD/MM/YYYY).
class UkDateUtils {
  UkDateUtils._();

  static const Locale ukLocale = Locale('en', 'GB');

  static String formatUk(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  static DateTime? parseUk(String value) {
    final match = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{4})$').firstMatch(value.trim());
    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;

    try {
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  /// Converts DD/MM/YYYY to yyyy-MM-dd for API payloads.
  static String? ukDisplayToIso(String value) {
    final date = parseUk(value);
    if (date == null) return null;
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
