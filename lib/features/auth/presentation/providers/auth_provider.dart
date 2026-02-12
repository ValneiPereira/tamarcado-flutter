import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../shared/data/datasources/notification_remote_datasource.dart';
import '../../../shared/data/datasources/user_remote_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';

// Core providers
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.read(secureStorageProvider);
  return DioClient(storage);
});

final authDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final dioClient = ref.read(dioClientProvider);
  return AuthRemoteDatasource(dioClient.dio);
});

final userDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasource(ref.read(dioClientProvider).dio);
});

final notificationDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasource(ref.read(dioClientProvider).dio);
});

// Auth State
class AuthState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isInitializing;
  final String? error;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isInitializing = true,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isAuthenticated,
    bool? isInitializing,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitializing: isInitializing ?? this.isInitializing,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _storage;
  final AuthRemoteDatasource _datasource;

  AuthNotifier(this._storage, this._datasource) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final token = await _storage.getAccessToken();
      final userData = await _storage.getUser();

      if (token != null && userData != null) {
        final user = UserModel.fromJson(userData);
        state = AuthState(
          user: user,
          isAuthenticated: true,
          isInitializing: false,
        );
      } else {
        state = const AuthState(isInitializing: false);
      }
    } catch (_) {
      state = const AuthState(isInitializing: false);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(error: null);
    try {
      final response = await _datasource.login(
        email: email,
        password: password,
      );

      await _storage.saveAccessToken(response.accessToken);
      await _storage.saveRefreshToken(response.refreshToken);
      await _storage.saveUser(response.user.toJson());

      state = AuthState(
        user: response.user,
        isAuthenticated: true,
        isInitializing: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: _extractErrorMessage(e),
        isInitializing: false,
      );
      rethrow;
    }
  }

  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Map<String, dynamic> address,
  }) async {
    state = state.copyWith(error: null);
    try {
      final response = await _datasource.registerClient(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );

      await _storage.saveAccessToken(response.accessToken);
      await _storage.saveRefreshToken(response.refreshToken);
      await _storage.saveUser(response.user.toJson());

      state = AuthState(
        user: response.user,
        isAuthenticated: true,
        isInitializing: false,
      );
    } catch (e) {
      state = state.copyWith(error: _extractErrorMessage(e));
      rethrow;
    }
  }

  Future<void> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String phone,
    required Map<String, dynamic> address,
    required String category,
    required String serviceType,
    required List<Map<String, dynamic>> services,
  }) async {
    state = state.copyWith(error: null);
    try {
      final response = await _datasource.registerProfessional(
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        category: category,
        serviceType: serviceType,
        services: services,
      );

      await _storage.saveAccessToken(response.accessToken);
      await _storage.saveRefreshToken(response.refreshToken);
      await _storage.saveUser(response.user.toJson());

      state = AuthState(
        user: response.user,
        isAuthenticated: true,
        isInitializing: false,
      );
    } catch (e) {
      state = state.copyWith(error: _extractErrorMessage(e));
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _storage.clearAll();
    state = const AuthState(isInitializing: false);
  }

  void forceLogout() {
    state = const AuthState(isInitializing: false);
  }

  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
    _storage.saveUser(user.toJson());
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _extractErrorMessage(Object e) {
    if (e.toString().contains('401')) {
      return 'Email ou senha incorretos';
    }
    if (e.toString().contains('409')) {
      return 'Este email já está em uso';
    }
    return 'Ocorreu um erro. Tente novamente.';
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.read(secureStorageProvider);
  final datasource = ref.read(authDatasourceProvider);
  final notifier = AuthNotifier(storage, datasource);

  // Conectar callback de logout do DioClient (sem criar ciclo)
  final dioClient = ref.read(dioClientProvider);
  dioClient.onLogout = () => notifier.forceLogout();

  return notifier;
});
