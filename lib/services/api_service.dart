import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medigo_mobile/config/api_config.dart';
import 'package:medigo_mobile/utils/app_exception.dart';

class ApiService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> _headersWithAuth(String? token) {
    final headers = _headers;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: _headersWithAuth(token),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw NetworkException.fromError(e);
    }
  }

  Future<http.Response> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    try {
      var url = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        url = url.replace(queryParameters: queryParameters);
      }
      final response = await http.get(url, headers: _headersWithAuth(token));
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.put(
        url,
        headers: _headersWithAuth(token),
        body: body != null ? jsonEncode(body) : null,
      );
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<http.Response> delete(String endpoint, {String? token}) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(url, headers: _headersWithAuth(token));
      return response;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
