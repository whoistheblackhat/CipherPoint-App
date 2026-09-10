// CipherPoint API Client
// Production URL: https://cipherpoint.linkpc.net

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final logger = Logger();

class CPApiClient {
  CPApiClient._internal();
  static final CPApiClient _instance = CPApiClient._internal();
  factory CPApiClient() => _instance;

  static const String baseUrl = 'https://cipherpoint.linkpc.net/api';
  static const String _tokenKey = 'cp_auth_token';
  static const String _userKey = 'cp_user_data';

  late final Dio _dio;
  late final FlutterSecureStorage _storage;
  late final Connectivity _connectivity;

  String? _accessToken;
  StreamController<void>? _logoutController;

  Stream<void> get onLogout => _logoutController?.stream ?? const Stream.empty();

  Future<void> init() async {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    );
    _connectivity = Connectivity();

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      compact: false,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Check connectivity
        final connectivityResult = await _connectivity.checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          handler.reject(DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'No internet connection',
          ));
          return;
        }

        // Add auth header
        final token = await getToken();
        if (token != null && !options.path.contains('/auth/')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await clearAuth();
          _logoutController?.add(null);
        }
        handler.next(error);
      },
    ));

    // Load saved token
    _accessToken = await _storage.read(key: _tokenKey);
  }

  Future<String?> getToken() async {
    if (_accessToken != null) return _accessToken;
    _accessToken = await _storage.read(key: _tokenKey);
    return _accessToken;
  }

  Future<void> setToken(String token) async {
    _accessToken = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearAuth() async {
    _accessToken = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<void> setUserData(Map<String, dynamic> user) async {
    await _storage.write(key: _userKey, value: user.toString());
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: _userKey);
    if (data == null) return null;
    // Parse the stored string back to map
    return null; // Use proper JSON storage in production
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    String? turnstileToken,
  }) async {
    final resp = await _dio.post('/auth/login', data: {
      'username': username,
      'password': password,
      if (turnstileToken != null) 'turnstile_token': turnstileToken,
    });
    return resp.data;
  }

  Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    String? turnstileToken,
    String? fingerprint,
  }) async {
    final resp = await _dio.post('/auth/signup', data: {
      'username': username,
      'email': email,
      'password': password,
      if (turnstileToken != null) 'turnstile_token': turnstileToken,
      if (fingerprint != null) 'fingerprint': fingerprint,
    });
    return resp.data;
  }

  Future<Map<String, dynamic>> me() async {
    final resp = await _dio.get('/auth/me');
    return resp.data;
  }

  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      try {
        await _dio.post('/auth/logout');
      } catch (_) {}
    }
    await clearAuth();
  }

  // Challenges
  Future<List<Map<String, dynamic>>> getChallenges({
    String? category,
    String? difficulty,
    String? search,
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _dio.get('/challenges', queryParameters: {
      if (category != null) 'category': category,
      if (difficulty != null) 'difficulty': difficulty,
      if (search != null) 'search': search,
      'limit': limit,
      'offset': offset,
    });
    return List<Map<String, dynamic>>.from(resp.data);
  }

  Future<Map<String, dynamic>> getChallenge(int id) async {
    final resp = await _dio.get('/challenges/$id');
    return resp.data;
  }

  Future<Map<String, dynamic>> submitFlag({
    required int challengeId,
    required String flag,
  }) async {
    final resp = await _dio.post('/flags/submit', data: {
      'challenge_id': challengeId,
      'flag': flag,
    });
    return resp.data;
  }

  Future<Map<String, dynamic>> unlockHint({
    required int challengeId,
    required int hintNumber,
  }) async {
    final resp = await _dio.post('/hints/unlock', data: {
      'challenge_id': challengeId,
      'hint_number': hintNumber,
    });
    return resp.data;
  }

  // Leaderboard
  Future<Map<String, dynamic>> getLeaderboard({int limit = 100}) async {
    final resp = await _dio.get('/leaderboard', queryParameters: {'limit': limit});
    return resp.data;
  }

  // Profile
  Future<Map<String, dynamic>> getProfile(int userId) async {
    final resp = await _dio.get('/users/$userId');
    return resp.data;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final resp = await _dio.put('/auth/profile', data: data);
    return resp.data;
  }

  // Intel Vault
  Future<List<Map<String, dynamic>>> getIntelArticles({
    String? category,
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _dio.get('/intel-vault', queryParameters: {
      if (category != null) 'category': category,
      'limit': limit,
      'offset': offset,
    });
    return List<Map<String, dynamic>>.from(resp.data);
  }

  Future<Map<String, dynamic>> getIntelArticle(int id) async {
    final resp = await _dio.get('/intel-vault/$id');
    return resp.data;
  }

  // Community
  Future<List<Map<String, dynamic>>> getCommunityChallenges({
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await _dio.get('/challenges/community', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    return List<Map<String, dynamic>>.from(resp.data);
  }

  // Media
  String getMediaUrl(String fileId) {
    return '$baseUrl/media/$fileId';
  }

  // Notifications
  Future<List<Map<String, dynamic>>> getNotifications({int limit = 50}) async {
    final resp = await _dio.get('/notifications', queryParameters: {'limit': limit});
    return List<Map<String, dynamic>>.from(resp.data);
  }

  Future<void> markNotificationRead(int id) async {
    await _dio.post('/notifications/$id/read');
  }

  // Comments
  Future<List<Map<String, dynamic>>> getComments(int challengeId) async {
    final resp = await _dio.get('/challenges/$challengeId/comments');
    return List<Map<String, dynamic>>.from(resp.data);
  }

  Future<Map<String, dynamic>> postComment({
    required int challengeId,
    required String body,
    int? parentId,
  }) async {
    final resp = await _dio.post('/challenges/$challengeId/comments', data: {
      'body': body,
      if (parentId != null) 'parent_id': parentId,
    });
    return resp.data;
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final resp = await _dio.get('/healthz');
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// Riverpod provider
final apiClientProvider = Provider<CPApiClient>((ref) {
  final client = CPApiClient();
  return client;
});

final initializedApiClientProvider = FutureProvider<CPApiClient>((ref) async {
  final client = ref.watch(apiClientProvider);
  await client.init();
  return client;
});