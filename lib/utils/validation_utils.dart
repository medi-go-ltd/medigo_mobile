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

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[\d\s\+\-\(\)]{10,20}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Home address is required';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  static String? validateGmcNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'GMC number is required';
    }
    final digitsOnly = value.trim().replaceAll(RegExp(r'\s'), '');
    final gmcRegex = RegExp(r'^[0-9]{5,8}$');
    if (!gmcRegex.hasMatch(digitsOnly)) {
      return 'Please enter a valid GMC number (5-8 digits)';
    }
    return null;
  }

  static String? validateFee(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Fee is required';
    }
    final fee = double.tryParse(value.trim());
    if (fee == null || fee < 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  static String? validateRadius(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Radius is required';
    }
    final radius = double.tryParse(value.trim());
    if (radius == null || radius < 1 || radius > 100) {
      return 'Please enter a radius between 1 and 100 km';
    }
    return null;
  }

  static String? validateYearsOfExperience(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Years of experience is required';
    }
    final years = int.tryParse(value.trim());
    if (years == null || years < 0 || years > 60) {
      return 'Please enter a valid number (0-60)';
    }
    return null;
  }
}
