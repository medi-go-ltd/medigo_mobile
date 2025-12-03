abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? responseData;

  const ApiException(
    super.message, {
    this.statusCode,
    this.responseData,
    super.code,
    super.originalError,
  });

  factory ApiException.fromResponse({
    required int statusCode,
    required Map<String, dynamic> responseData,
  }) {
    final errorMessage =
        responseData['message'] as String? ??
        responseData['error'] as String? ??
        responseData['errors']?.toString() ??
        'An error occurred. Please try again.';

    return ApiException(
      errorMessage,
      statusCode: statusCode,
      responseData: responseData,
      code: responseData['code'] as String?,
    );
  }

  factory ApiException.fromMessage(String message, {int? statusCode}) {
    return ApiException(message, statusCode: statusCode);
  }
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.fromError(dynamic error) {
    return NetworkException(
      'Network error: ${error.toString()}',
      originalError: error,
    );
  }
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code,
    super.originalError,
  });

  factory ValidationException.fromResponse(Map<String, dynamic> responseData) {
    final errors = responseData['errors'] as Map<String, dynamic>?;
    Map<String, List<String>>? fieldErrors;

    if (errors != null) {
      fieldErrors = errors.map(
        (key, value) => MapEntry(
          key,
          value is List
              ? value.map((e) => e.toString()).toList()
              : [value.toString()],
        ),
      );
    }

    final message =
        responseData['message'] as String? ??
        'Validation failed. Please check your input.';

    return ValidationException(message, fieldErrors: fieldErrors);
  }
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.originalError});
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.code, super.originalError});

  factory UnknownException.fromError(dynamic error) {
    return UnknownException(
      'An unexpected error occurred: ${error.toString()}',
      originalError: error,
    );
  }
}
