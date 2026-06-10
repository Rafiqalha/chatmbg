import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants.dart';

// ─── Provider ────────────────────────────────────────────────────────────────

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// ─── API Client ──────────────────────────────────────────────────────────────

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    final baseUrl =
        Platform.isAndroid ? AppConstants.apiBaseUrl : AppConstants.apiBaseUrlIos;

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      if (kDebugMode) _LoggingInterceptor(),
    ]);
  }

  // ─── Chat (SSE Streaming) ──────────────────────────────────────────────────

  Stream<Map<String, dynamic>> chatStream(String message) async* {
    final response = await _dio.post<ResponseBody>(
      '/api/v1/chat',
      data: {'message': message},
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data!.stream;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // keep incomplete line in buffer

      for (final line in lines) {
        if (!line.startsWith('data: ')) continue;
        final data = line.substring(6).trim();
        if (data == '[DONE]') return;
        try {
          yield json.decode(data) as Map<String, dynamic>;
        } catch (_) {
          // skip malformed JSON
        }
      }
    }
  }

  // ─── Menu Validation ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> validateMenu({
    required String menu,
    required String recipientGroup,
  }) async {
    final response = await _dio.post('/api/v1/validate-menu', data: {
      'menu': menu,
      'recipient_group': recipientGroup,
    });
    return response.data as Map<String, dynamic>;
  }

  // ─── Compliance Check ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> complianceCheck({
    required String checkType,
    required Map<String, dynamic> inputs,
  }) async {
    final response = await _dio.post('/api/v1/compliance-check', data: {
      'check_type': checkType,
      'inputs': inputs,
    });
    return response.data as Map<String, dynamic>;
  }

  // ─── Suppliers ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> searchSuppliers({
    double? lat,
    double? lon,
    int radiusKm = 20,
    String? category,
    bool verifiedOnly = false,
    String? query,
    int limit = 20,
  }) async {
    // ignore: use_null_aware_elements
    final response = await _dio.get('/api/v1/suppliers/search', queryParameters: {
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
      'radius_km': radiusKm,
      if (category != null) 'category': category,
      'verified_only': verifiedOnly,
      if (query != null) 'q': query,
      'limit': limit,
    });
    return response.data as Map<String, dynamic>;
  }

  // ─── Regulations ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getLatestRegulations() async {
    final response = await _dio.get('/api/v1/regulations/latest');
    return response.data as Map<String, dynamic>;
  }
}

// ─── Interceptors ────────────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('✖ ${err.response?.statusCode} ${err.message}');
    handler.next(err);
  }
}
