import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:staff_mate/APIs/api_headers.dart';

class ApiRequest {
  static Future<dynamic> request({
    required String url,
    required String method,
    dynamic data,
    Map<String, String>? headers,
    String responseType = 'json',
  }) async {
    final requestHeaders = headers ?? await ApiHeaders.getHeaders();

    final requestHeadersWithDefaults = <String, String>{
      'Content-Type': 'application/json',
      ...requestHeaders,
    };

    final requestBody = data != null ? json.encode(data) : null;

    log('API Request: $method $url');
    log('Headers: $requestHeadersWithDefaults');

    if (requestBody != null) {
      log('Body: $requestBody');
    }

    try {
      final http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(Uri.parse(url), headers: requestHeadersWithDefaults)
              .timeout(const Duration(seconds: 30));
          break;

        case 'POST':
          response = await http
              .post(
                Uri.parse(url),
                headers: requestHeadersWithDefaults,
                body: requestBody,
              )
              .timeout(const Duration(seconds: 30));
          break;

        case 'PUT':
          response = await http
              .put(
                Uri.parse(url),
                headers: requestHeadersWithDefaults,
                body: requestBody,
              )
              .timeout(const Duration(seconds: 30));
          break;

        case 'DELETE':
          response = await http
              .delete(
                Uri.parse(url),
                headers: requestHeadersWithDefaults,
                body: requestBody,
              )
              .timeout(const Duration(seconds: 30));
          break;

        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      log('API Response Status: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseType == 'blob') {
          return response.bodyBytes;
        }

        if (response.body.isEmpty) {
          return null;
        }

        try {
          return json.decode(response.body);
        } catch (e) {
          log('JSON Parse Error: $e');
          return response.body;
        }
      }

      String errorMessage = 'API Error: ${response.statusCode}';

      try {
        final errorData = json.decode(response.body);

        if (errorData is Map) {
          errorMessage =
              errorData['message']?.toString() ??
              errorData['error']?.toString() ??
              errorMessage;
        } else if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      } catch (_) {
        if (response.body.isNotEmpty) {
          errorMessage = response.body;
        }
      }

      throw Exception(errorMessage);
    } catch (error) {
      log('API Error: $error');
      rethrow;
    }
  }

  static Future<dynamic> get(String url, {Map<String, String>? headers}) {
    return request(url: url, method: 'GET', headers: headers);
  }

  static Future<dynamic> post(
    String url,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return request(url: url, method: 'POST', data: data, headers: headers);
  }

  static Future<dynamic> put(
    String url,
    dynamic data, {
    Map<String, String>? headers,
  }) {
    return request(url: url, method: 'PUT', data: data, headers: headers);
  }

  static Future<dynamic> delete(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) {
    return request(url: url, method: 'DELETE', data: data, headers: headers);
  }
}
