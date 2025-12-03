import 'package:firebase_core/firebase_core.dart';
import 'dart:developer' as developer;

/// Service for initializing and managing Firebase
class FirebaseService {
  static bool _initialized = false;
  static bool _hasError = false;
  static String? _errorMessage;

  /// Initialize Firebase
  ///
  /// This should be called before runApp() in main.dart
  /// Returns true if successful, false if failed (app can still run)
  static Future<bool> initialize() async {
    if (_initialized) {
      developer.log('Firebase already initialized');
      return true;
    }

    if (_hasError) {
      developer.log(
        'Firebase initialization previously failed: $_errorMessage',
      );
      return false;
    }

    try {
      await Firebase.initializeApp();
      _initialized = true;
      developer.log('Firebase initialized successfully');
      return true;
    } catch (e, stackTrace) {
      _hasError = true;
      _errorMessage = e.toString();
      developer.log(
        'Error initializing Firebase: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'FirebaseService',
      );
      // Don't rethrow - allow app to continue without Firebase
      // This is important for release builds where Firebase config might be missing
      return false;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;

  /// Check if Firebase initialization failed
  static bool get hasError => _hasError;

  /// Get error message if initialization failed
  static String? get errorMessage => _errorMessage;
}
