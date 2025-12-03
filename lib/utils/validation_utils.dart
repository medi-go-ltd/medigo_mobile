class ValidationUtils {
  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Last name is required';
    }
    if (value.trim().length < 2) {
      return 'Last name must be at least 2 characters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    // Basic email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    final hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = value.contains(RegExp(r'[a-z]'));
    final hasNumber = value.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (!hasUpperCase) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!hasLowerCase) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!hasNumber) {
      return 'Password must contain at least one number';
    }

    if (!hasSpecialChar) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateMedicalRegistrationNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Medical registration number is required';
    }

    if (value.trim().length < 3) {
      return 'Medical registration number must be at least 3 characters';
    }

    // Allow alphanumeric and common separators
    final regNumberRegex = RegExp(r'^[a-zA-Z0-9\s\-/]+$');
    if (!regNumberRegex.hasMatch(value.trim())) {
      return 'Please enter a valid medical registration number';
    }

    return null;
  }
}
