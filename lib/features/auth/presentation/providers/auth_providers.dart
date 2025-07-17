import 'package:ecommerce_app/features/auth/data/gateways/auth_local_gateway.dart';
import 'package:ecommerce_app/features/auth/data/gateways/auth_remote_gateway.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/check_auth_status.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/login_user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/logout_user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:fake_store_api_client/fake_store_api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final apiClientProvider = Provider<FakeStoreApiClient>((ref) {
  return FakeStoreApiClient();
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) { 
  return const FlutterSecureStorage();
});

final authLocalGatewayProvider = Provider<AuthLocalGateway>((ref) {
  return AuthLocalGatewayImpl(secureStorage: ref.watch(secureStorageProvider));
});

final authRemoteGatewayProvider = Provider<AuthRemoteGateway>((ref) {
  return AuthRemoteGatewayImpl(apiClient: ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteGateway: ref.watch(authRemoteGatewayProvider),
    localGateway: ref.watch(authLocalGatewayProvider),
  );
});


final loginUserProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.watch(authRepositoryProvider));
});

final logoutUserProvider = Provider<LogoutUser>((ref) {
  return LogoutUser(ref.watch(authRepositoryProvider));
});

final checkAuthStatusProvider = Provider<CheckAuthStatus>((ref) {
  return CheckAuthStatus(ref.watch(authRepositoryProvider));
});

final registerUserProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.watch(authRepositoryProvider));
});

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  return AuthViewModel(
    ref.watch(loginUserProvider),
    ref.watch(logoutUserProvider),
    ref.watch(checkAuthStatusProvider),
    ref.watch(registerUserProvider)
  );
});