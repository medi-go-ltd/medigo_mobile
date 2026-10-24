class ApiConfig {
  // TODO: Replace with your actual API base URL
  // Example: 'https://api.medigo.com/api/v1'
  static const String baseUrl = 'http://192.168.1.100:3001/api/v1';

  // API Endpoints
  static const String login = '/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendEmailVerification =
      '/auth/resend-email-verification';
}
