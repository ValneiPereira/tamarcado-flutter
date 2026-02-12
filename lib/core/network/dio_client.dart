import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../config/api_config.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio dio;
  final SecureStorageService _storage;
  final Logger _logger = Logger();

  bool _isRefreshing = false;
  final List<_QueueItem> _failedQueue = [];

  // Callback para logout (injetado pelo provider de auth)
  VoidCallback? onLogout;

  DioClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(_createAuthInterceptor());
  }

  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          _logger.d('[API] ${options.method} ${options.path}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          _logger.d('[API] ${response.requestOptions.path} - ${response.statusCode}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        final requestOptions = error.requestOptions;

        // Se o erro for na própria chamada de refresh, faz logout
        if (requestOptions.path.contains('/auth/refresh')) {
          _logger.e('[API] Refresh token failed. Logging out.');
          await _performLogout();
          return handler.reject(error);
        }

        // Se não for 401 ou já tentou refresh, rejeita
        if (error.response?.statusCode != 401 ||
            requestOptions.extra['_retry'] == true) {
          return handler.reject(error);
        }

        // Se já está fazendo refresh, coloca na fila
        if (_isRefreshing) {
          try {
            final queueItem = _QueueItem();
            _failedQueue.add(queueItem);
            await queueItem.completer.future;
            // Retry com novo token
            final token = await _storage.getAccessToken();
            requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await dio.fetch(requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(error);
          }
        }

        requestOptions.extra['_retry'] = true;
        _isRefreshing = true;

        try {
          final refreshToken = await _storage.getRefreshToken();
          if (refreshToken == null) {
            throw DioException(
              requestOptions: requestOptions,
              message: 'No refresh token available',
            );
          }

          _logger.i('[API] Refreshing access token...');

          // Usa uma instância separada para evitar interceptors
          final refreshDio = Dio(BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            headers: {'Content-Type': 'application/json'},
          ));

          final response = await refreshDio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = response.data['accessToken'] as String;
          final newRefreshToken = response.data['refreshToken'] as String?;

          await _storage.saveAccessToken(newAccessToken);
          if (newRefreshToken != null) {
            await _storage.saveRefreshToken(newRefreshToken);
          }

          // Processa a fila de requisições pendentes
          _processQueue(null);
          _isRefreshing = false;

          // Retry da requisição original com novo token
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (refreshError) {
          _processQueue(refreshError);
          _isRefreshing = false;

          _logger.e('[API] Refresh failed, logging out...');
          await _performLogout();

          return handler.reject(error);
        }
      },
    );
  }

  void _processQueue(Object? error) {
    for (final item in _failedQueue) {
      if (error != null) {
        item.completer.completeError(error);
      } else {
        item.completer.complete();
      }
    }
    _failedQueue.clear();
  }

  Future<void> _performLogout() async {
    await _storage.clearAll();
    onLogout?.call();
  }
}

class _QueueItem {
  final Completer<void> completer = Completer<void>();
}
