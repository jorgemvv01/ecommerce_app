import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

class RegisterUser implements UseCase<User, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, User>> call(RegisterParams params) async {
    return await repository.register(params);
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String username;
  final String password;

  const RegisterParams({
    required this.email,
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [email, username, password];
}