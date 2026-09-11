// Auth State Management with Riverpod

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/models.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthState extends _$AuthState {
  @override
  FutureOr<CPUser?> build() async {
    final client = ref.watch(apiClientProvider);
    try {
      final userData = await client.me();
      return CPUser.fromJson(userData);
    } catch (_) {
      return null;
    }
  }

  Future<bool> login({
    required String username,
    required String password,
    String? turnstileToken,
  }) async {
    state = const AsyncLoading();
    final client = ref.read(apiClientProvider);
    try {
      final resp = await client.login(
        username: username,
        password: password,
        turnstileToken: turnstileToken,
      );
      final authResp = CPAuthResponse.fromJson(resp);
      await client.setToken(authResp.token);
      state = AsyncData(authResp.user);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    String? turnstileToken,
    String? fingerprint,
  }) async {
    state = const AsyncLoading();
    final client = ref.read(apiClientProvider);
    try {
      final resp = await client.signup(
        username: username,
        email: email,
        password: password,
        turnstileToken: turnstileToken,
        fingerprint: fingerprint,
      );
      final authResp = CPAuthResponse.fromJson(resp);
      await client.setToken(authResp.token);
      state = AsyncData(authResp.user);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    final client = ref.read(apiClientProvider);
    await client.logout();
    state = const AsyncData(null);
  }

  Future<void> refreshUser() async {
    final client = ref.read(apiClientProvider);
    try {
      final userData = await client.me();
      state = AsyncData(CPUser.fromJson(userData));
    } catch (_) {
      state = const AsyncData(null);
    }
  }
}

@riverpod
Stream<void> authLogoutStream(AuthLogoutStreamRef ref) {
  final client = ref.watch(apiClientProvider);
  return client.onLogout;
}

@riverpod
Future<void> authLogoutListener(AuthLogoutListenerRef ref) async {
  ref.listen(authLogoutStreamProvider, (_, next) {
    next.whenOrNull(data: (_) => ref.invalidate(authStateProvider));
  });
  ref.keepAlive();
}
