import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:fake_store_api_client/fake_store_api_client.dart';

abstract class AuthRemoteGateway {
  Future<String> login(String username, String password);
  Future<UserModel> getUserByUsername(String username);
  Future<int> register(RegisterParams params);
  Future<UserModel> getUserById(int userId);
}

class AuthRemoteGatewayImpl implements AuthRemoteGateway {
  final FakeStoreApiClient apiClient;

  AuthRemoteGatewayImpl({required this.apiClient});

  @override
  Future<String> login(String username, String password) async {
    LoginRequest request = LoginRequest(
      username: username,
      password: password,
    );
    final result = await apiClient.auth.login(request);
    return result.fold(
      (failure) 
        => (failure is NetworkFailure) 
          ? throw NetworkException()
          : throw ServerException(),
      (token) => token,
    );
  }

  @override
  Future<UserModel> getUserByUsername(String username) async {
    final result = await apiClient.users.getUsers();
    return result.fold(
      (failure) => throw ServerException(),
      (users) {
        final userJson = users.firstWhere(
          (user) => user.username == username,
          orElse: () => throw ServerException(),
        );
        return UserModel.fromJson(userJson.toJson());
      },
    );
  }

  @override
  Future<int> register(RegisterParams params) async {
    final UserRequest userRequest = UserRequest(
      email: params.email,
      username: params.username,
      password: params.password
    );
    final result = await apiClient.users.createUser(
      userRequest
    );

    return result.fold(
      (failure) => throw ServerException(),
      (id) => id,
    );
  }

  @override
  Future<UserModel> getUserById(int userId) async {
    final result = await apiClient.users.getUser(userId);
    return result.fold(
      (failure) => throw ServerException(),
      (user) {
        return UserModel.fromJson(user.toJson());
      },
    );
  }
}