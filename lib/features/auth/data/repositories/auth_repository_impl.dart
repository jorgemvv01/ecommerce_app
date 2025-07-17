import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/data/gateways/auth_local_gateway.dart';
import 'package:ecommerce_app/features/auth/data/gateways/auth_remote_gateway.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteGateway remoteGateway;
  final AuthLocalGateway localGateway;

  AuthRepositoryImpl({
    required this.remoteGateway,
    required this.localGateway,
  });

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final token = await remoteGateway.login(username, password);
      final user = await remoteGateway.getUserByUsername(username);
      await localGateway.saveSession(user, token);
      return Right(user);
    } on ServerException {
      return const Left(
        ServerFailure(message: 'Incorrect username or password'
        )
      );
    }on NetworkException {
      return const Left(
        NetworkFailure()
      );
    }
  }

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    try {
      final session = await localGateway.getSession();
      if (session != null) {
        return Right(session.$1);
      } else {
        return const Left(CacheFailure(message: 'No hay sesión activa.'));
      }
    } catch (e) {
      return const Left(CacheFailure(message: 'No se pudo leer la sesión.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localGateway.clearSession();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: 'The session could not be closed.'));
    }
  }

  @override
  Future<Either<Failure, User>> register(RegisterParams params) async {
    try {
      final newUserId = await remoteGateway.register(params);
      final newUser = await remoteGateway.getUserById(newUserId);
      final token = await remoteGateway.login(newUser.username, newUser.password);
      await localGateway.saveSession(newUser, token);
      return Right(newUser);
    } on ServerException {
      return const Left(
        ServerFailure(message: "Registration could not be completed. The user may already exist.")
      );
    }
  }
}