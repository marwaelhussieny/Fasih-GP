// lib/core/network/improved_api_client.dart - Updated for Ngrok

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode = 0, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ImprovedApiClient {
  late final Dio _dio;
  final String baseUrl;
  String? _accessToken;

  ImprovedApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true', // Essential for ngrok
        'User-Agent': 'FlutterApp/1.0',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Logging interceptor for debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ));
    }

    // Auth token and ngrok interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Always add ngrok bypass header
          options.headers['ngrok-skip-browser-warning'] = 'true';
          options.headers['User-Agent'] = 'FlutterApp/1.0';

          // Add auth token if available
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }

          if (kDebugMode) {
            print('🚀 API Request: ${options.method} ${options.path}');
            print('📤 Headers: ${options.headers}');
            if (options.data != null) {
              print('📦 Body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
            print('📨 Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
            print('💥 Error: ${error.message}');
            print('📨 Response: ${error.response?.data}');
          }

          // Handle common HTTP errors
          if (error.response != null) {
            throw _handleDioError(error);
          }
          handler.next(error);
        },
      ),
    );

    // Retry interceptor for network issues
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {

            // Retry once for timeout errors
            try {
              if (kDebugMode) {
                print('🔄 Retrying request due to timeout...');
              }

              final response = await _dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (e) {
              // If retry fails, continue with original error
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }

  ApiException _handleDioError(DioException error) {
    String message = 'حدث خطأ غير متوقع';
    int statusCode = error.response?.statusCode ?? 0;

    // Extract error message from response
    if (error.response?.data is Map) {
      final data = error.response!.data as Map<String, dynamic>;
      message = data['message'] ?? data['error'] ?? data['msg'] ?? message;
    } else if (error.response?.data is String) {
      message = error.response!.data as String;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
        break;
      case DioExceptionType.connectionError:
        if (error.message?.contains('SocketException') == true) {
          message = 'لا يوجد اتصال بالإنترنت';
        } else {
          message = 'خطأ في الاتصال بالخادم';
        }
        break;
      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 400:
            message = 'طلب غير صحيح';
            break;
          case 401:
            message = 'غير مصرح بالوصول';
            break;
          case 403:
            message = 'ممنوع الوصول';
            break;
          case 404:
            message = 'الخدمة غير موجودة';
            break;
          case 429:
            message = 'تم تجاوز الحد المسموح من الطلبات';
            break;
          case 500:
            message = 'خطأ داخلي في الخادم';
            break;
          case 502:
            message = 'الخادم غير متاح مؤقتاً';
            break;
          case 503:
            message = 'الخدمة غير متاحة';
            break;
          default:
          // Keep extracted message
            break;
        }
        break;
      case DioExceptionType.cancel:
        message = 'تم إلغاء الطلب';
        break;
      case DioExceptionType.unknown:
      default:
        if (error.message?.contains('ngrok') == true) {
          message = 'خطأ في الاتصال بخادم التطوير (ngrok)';
        } else {
          message = 'حدث خطأ في الشبكة';
        }
    }

    return ApiException(
      message,
      statusCode: statusCode,
      data: error.response?.data,
    );
  }

  void setToken(String token) {
    _accessToken = token;
    if (kDebugMode) {
      print('🔑 Auth token updated');
    }
  }

  void clearToken() {
    _accessToken = null;
    if (kDebugMode) {
      print('🔓 Auth token cleared');
    }
  }

  String? get currentToken => _accessToken;

  // Test connection to the backend
  Future<bool> testConnection() async {
    try {
      final response = await get('/auth/login');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Connection test failed: $e');
      }
      return false;
    }
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> uploadFile(
      String path,
      File file, {
        required String fieldName,
        Map<String, dynamic>? data,
        ProgressCallback? onSendProgress,
        Options? options,
      }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Helper method for E3rbly API calls
  Future<Map<String, dynamic>> callE3rblyAPI(
      String endpoint, {
        required Map<String, dynamic> body,
        String? userId,
      }) async {
    try {
      if (userId != null) {
        body['userId'] = userId;
      }

      final response = await post('/e3rbly/$endpoint', data: body);

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ApiException('استجابة غير صحيحة من الخادم');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      } else {
        throw ApiException('فشل في الاتصال بخدمة E3rbly: $e');
      }
    }
  }

  void dispose() {
    _dio.close();
  }
}