import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Uri buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${ApiConstants.baseUrl}$normalizedPath').replace(
      queryParameters: queryParameters,
    );
  }

  Map<String, String> jsonHeaders({bool withAuth = true}) {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth && _authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
    bool withAuth = true,
  }) {
    return _client.get(
      buildUri(path, queryParameters: queryParameters),
      headers: jsonHeaders(withAuth: withAuth),
    );
  }

  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool withAuth = true,
  }) {
    return _client.post(
      buildUri(path, queryParameters: queryParameters),
      headers: jsonHeaders(withAuth: withAuth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> patch(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool withAuth = true,
  }) {
    return _client.patch(
      buildUri(path, queryParameters: queryParameters),
      headers: jsonHeaders(withAuth: withAuth),
      body: body == null ? null : jsonEncode(body),
    );
  }

  Future<http.Response> delete(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool withAuth = true,
  }) {
    return _client.delete(
      buildUri(path, queryParameters: queryParameters),
      headers: jsonHeaders(withAuth: withAuth),
      body: body == null ? null : jsonEncode(body),
    );
  }
}
