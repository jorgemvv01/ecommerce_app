import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser implements UseCase<void, NoParams> {
  final AuthRepository repository;
  LogoutUser(this.repository);
  
  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}