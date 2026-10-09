import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waytowebs_app/core/network/zoho_api_client.dart';
import 'package:waytowebs_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:waytowebs_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:waytowebs_app/features/auth/domain/entities/user_entity.dart';
import 'package:waytowebs_app/features/auth/domain/repositories/auth_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in ProviderScope');
});

final zohoApiClientProvider = Provider<ZohoApiClient>((ref) {
  return ZohoApiClientImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final zohoClient = ref.watch(zohoApiClientProvider);
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return AuthRemoteDataSourceImpl(
    zohoApiClient: zohoClient,
    sharedPreferences: sharedPrefs,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final String? otpSentTo;
  final bool otpSent;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.otpSentTo,
    this.otpSent = false,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    String? otpSentTo,
    bool? otpSent,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      otpSentTo: otpSentTo ?? this.otpSentTo,
      otpSent: otpSent ?? this.otpSent,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(const AuthState()) {
    checkInitialAuthStatus();
  }

  Future<void> checkInitialAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final user = await authRepository.getCurrentUser();
    state = state.copyWith(user: user, isLoading: false);
  }

  Future<bool> sendOtp({
    required String phone,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await authRepository.sendOtp(phone, role);
      state = state.copyWith(
        isLoading: false,
        otpSent: true,
        otpSentTo: phone,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> verifyOtpAndLogin({
    required String phone,
    required String otp,
    required UserRole role,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await authRepository.verifyOtpAndLogin(
        phone: phone,
        otp: otp,
        role: role,
      );
      state = state.copyWith(
        user: user,
        isLoading: false,
        otpSent: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await authRepository.logout();
    state = const AuthState();
  }

  void resetOtpState() {
    state = state.copyWith(otpSent: false, clearError: true);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository: repository);
});

final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final repository = ref.watch(authRepositoryProvider);
  return await repository.getAllUsers();
});
