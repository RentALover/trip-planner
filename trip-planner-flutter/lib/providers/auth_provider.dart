import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/storage_keys.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthState {
  final UserInfo? user;
  final String? token;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.token, this.isLoading = false, this.error});

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  AuthState copyWith({UserInfo? user, String? token, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadSavedUser();
    return const AuthState();
  }

  Future<void> _loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.token);
    final userJson = prefs.getString(StorageKeys.userInfo);
    if (token != null && userJson != null) {
      try {
        // Parse simple stored JSON
        state = AuthState(token: token);
      } catch (_) {}
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resp = await ref.read(authServiceProvider).login(
        LoginReq(username: username, password: password),
      );
      state = AuthState(user: resp.user, token: resp.token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String username, String password, {String? nickname, String? email}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resp = await ref.read(authServiceProvider).register(
        RegisterReq(username: username, password: password, nickname: nickname, email: email),
      );
      state = AuthState(user: resp.user, token: resp.token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(authServiceProvider).logout();
    state = const AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
