import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';

class ClearCart implements UseCase<void, NoParams> {
    final CartRepository repository;
    ClearCart(this.repository);
    @override
    Future<Either<Failure, void>> call(NoParams params) => repository.clearCart();
}