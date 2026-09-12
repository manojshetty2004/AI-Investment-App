import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _ownsClient = client == null,
        _baseUrl = baseUrl ?? _defaultBaseUrl;

  final http.Client _client;
  final bool _ownsClient;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    const configured = String.fromEnvironment('TRADEX_API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Uri _uri(String path) => Uri.parse('${_baseUrl.replaceAll(RegExp(r'/$'), '')}$path');

  Future<Map<String, dynamic>> getRecommendation({
    required String riskType,
    required num investmentAmount,
    required int investmentTenure,
  }) async {
    final response = await _send(() => _client.post(
          _uri('/recommend'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'risk_type': riskType,
            'investment_amount': investmentAmount,
            'investment_tenure': investmentTenure,
          }),
        ));
    final data = _decode(response);
    if (data is! Map<String, dynamic>) throw const ApiException('Invalid recommendation response.');
    return data;
  }

  Future<Map<String, dynamic>> getAgentStatus() async {
    final data = _decode(await _send(() => _client.get(_uri('/agents/status'))));
    if (data is! Map<String, dynamic>) throw const ApiException('Invalid agent status response.');
    return data;
  }

  Future<List<dynamic>> getLogs() async {
    final data = _decode(await _send(() => _client.get(_uri('/agents/logs'))));
    if (data is! List<dynamic>) throw const ApiException('Invalid agent logs response.');
    return data;
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 25));
    } catch (_) {
      throw const ApiException('Unable to reach TradeX. Please try again.');
    }
  }

  Object? _decode(http.Response response) {
    Object? data;
    try {
      data = jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('TradeX returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];
        if (detail is Map<String, dynamic>) {
          throw ApiException('${detail['agent'] ?? 'Agent'}: ${detail['message'] ?? 'Unavailable'}');
        }
        if (detail is String) throw ApiException(detail);
      }
      throw ApiException('TradeX request failed (${response.statusCode}).');
    }
    return data;
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
