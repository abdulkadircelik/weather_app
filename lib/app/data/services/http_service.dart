import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';

abstract class IHttpService {
  Future<Map<String, dynamic>> get(String url, {Map<String, String>? headers});
  Future<Map<String, dynamic>> post(String url,
      {Map<String, dynamic>? body, Map<String, String>? headers});
}

class HttpService implements IHttpService {
  final http.Client _client;
  final Duration _timeout;

  HttpService({
    http.Client? client,
    Duration? timeout,
  })  : _client = client ?? http.Client(),
        _timeout =
            timeout ?? const Duration(seconds: AppConstants.httpTimeoutSeconds);

  @override
  Future<Map<String, dynamic>> get(String url,
      {Map<String, String>? headers}) async {
    try {
      final response =
          await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> post(String url,
      {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        body: body != null ? json.encode(body) : null,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw HttpException(
        'HTTP Error: ${response.statusCode}',
        response.statusCode,
        response.body,
      );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is HttpException) {
      return error;
    } else {
      return Exception('Network error: $error');
    }
  }

  void dispose() {
    _client.close();
  }
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  final String body;

  HttpException(this.message, this.statusCode, this.body);

  @override
  String toString() => '$message (Status: $statusCode)';
}
