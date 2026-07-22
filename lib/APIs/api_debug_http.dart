import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiDebugHttp {
  static http.Client client() => _LoggingClient(http.Client());

  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    _logRequest('GET', url, headers: headers);
    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      return response;
    } catch (e, st) {
      _logException('GET', url, e, st);
      rethrow;
    }
  }

  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('POST', url, headers: headers, body: body);
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      _logResponse('POST', url, response);
      return response;
    } catch (e, st) {
      _logException('POST', url, e, st);
      rethrow;
    }
  }

  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('PUT', url, headers: headers, body: body);
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      _logResponse('PUT', url, response);
      return response;
    } catch (e, st) {
      _logException('PUT', url, e, st);
      rethrow;
    }
  }

  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    _logRequest('DELETE', url, headers: headers, body: body);
    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: body,
        encoding: encoding,
      );
      _logResponse('DELETE', url, response);
      return response;
    } catch (e, st) {
      _logException('DELETE', url, e, st);
      rethrow;
    }
  }

  static void _logRequest(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    debugPrint('API REQUEST [$method] ${url.toString()}');
    if (headers != null && headers.isNotEmpty) {
      debugPrint('API REQUEST HEADERS [$method] ${_sanitizeHeaders(headers)}');
    }
    if (body != null) {
      debugPrint('API REQUEST BODY [$method] $body');
    }
  }

  static void _logResponse(String method, Uri url, http.Response response) {
    debugPrint(
      'API RESPONSE [$method] ${url.toString()} STATUS=${response.statusCode}',
    );
    if (response.statusCode >= 400) {
      debugPrint('API FAILURE BODY [$method] ${response.body}');
    }
  }

  static void _logException(
    String method,
    Uri url,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('API EXCEPTION [$method] ${url.toString()} ERROR=$error');
    debugPrint('API EXCEPTION TRACE [$method] $stackTrace');
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    if (sanitized['Authorization'] != null) {
      sanitized['Authorization'] = 'SmartCare ***';
    }
    return sanitized;
  }
}

class _LoggingClient extends http.BaseClient {
  _LoggingClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    debugPrint('API REQUEST [${request.method}] ${request.url}');
    if (request.headers.isNotEmpty) {
      debugPrint(
        'API REQUEST HEADERS [${request.method}] ${ApiDebugHttp._sanitizeHeaders(request.headers)}',
      );
    }

    try {
      final response = await _inner.send(request);
      debugPrint(
        'API RESPONSE [${request.method}] ${request.url} STATUS=${response.statusCode}',
      );
      return response;
    } catch (e, st) {
      debugPrint(
        'API EXCEPTION [${request.method}] ${request.url} ERROR=$e',
      );
      debugPrint('API EXCEPTION TRACE [${request.method}] $st');
      rethrow;
    }
  }
}
