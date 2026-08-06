import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../APIs/api_host.dart';
import '../APIs/api_endpoints.dart';

/// Centralised API client handling base URL, headers, token refresh,
/// error handling and request/response logging.
class ApiClient {
  final Ref ref;

  ApiClient(this.ref);

  Future<http.Response> _sendRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    Object? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    // Build full URL with query parameters
    final uri = Uri.parse(url).replace(queryParameters: queryParameters);

    // Default headers – include Authorization if token exists
    final defaultHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final token = await _getToken();
    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }
    final allHeaders = {...defaultHeaders, ...?headers};

    // Logging request
   

    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: allHeaders);
          break;
        case 'POST':
          response = await http.post(uri, headers: allHeaders, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: allHeaders, body: jsonEncode(body));
          break;
        case 'PATCH':
          response = await http.patch(uri, headers: allHeaders, body: jsonEncode(body));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: allHeaders);
          break;
        default:
          throw UnsupportedError('Unsupported HTTP method: $method');
      }
    } catch (e) {
     
      rethrow;
    }

    // Logging response


    // Handle token refresh on 401
    if (response.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request once with new token
        return _sendRequest(
          method: method,
          url: url,
          headers: headers,
          body: body,
          queryParameters: queryParameters,
        );
      }
    }
    return response;
  }

  Future<String?> _getToken() async {
    // TODO: Retrieve token from secure storage or auth provider
    return null; // placeholder
  }

  Future<bool> _refreshToken() async {
    // TODO: Implement token refresh logic using AuthService

    return false; // placeholder
  }

  // Public helpers
  Future<http.Response> get(String endpoint, {Map<String, String>? headers, Map<String, dynamic>? queryParameters}) =>
      _sendRequest(method: 'GET', url: endpoint, headers: headers, queryParameters: queryParameters);

  Future<http.Response> post(String endpoint, {Map<String, String>? headers, Object? body}) =>
      _sendRequest(method: 'POST', url: endpoint, headers: headers, body: body);

  Future<http.Response> put(String endpoint, {Map<String, String>? headers, Object? body}) =>
      _sendRequest(method: 'PUT', url: endpoint, headers: headers, body: body);

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) =>
      _sendRequest(method: 'DELETE', url: endpoint, headers: headers);
}

// Provider for the ApiClient – can be accessed throughout the app.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref));
