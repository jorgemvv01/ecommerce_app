import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatus implements UseCase<User, NoParams> {
  final AuthRepository repository;
  CheckAuthStatus(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}