import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class DioClient {
  late final Dio dio;

  Future<void> Function()? onUnauthorized;
  String? Function()? _tokenProvider;

  set tokenProvider(String? Function() provider) {
    _tokenProvider = provider;
  }

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
        sendTimeout: Duration(milliseconds: AppConfig.sendTimeoutMs),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (AppConfig.apiFail.isNotEmpty) {
            options.queryParameters['__fail'] = AppConfig.apiFail;
          }
          if (AppConfig.apiDelay.isNotEmpty) {
            options.queryParameters['__delay'] = AppConfig.apiDelay;
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final dynamic raw = _tokenProvider?.call();
            if (raw is String && raw.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $raw';
            } else {
              options.headers.remove('Authorization');
            }
          } catch (e) {
            debugPrint('Dio auth interceptor error: $e');
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            final path = e.requestOptions.path;
            if (!path.contains('/auth/')) {
              await onUnauthorized?.call();
            }
          }
          handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }
  }
}
