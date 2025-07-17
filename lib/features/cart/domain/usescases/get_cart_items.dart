import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';

class GetCartItems implements UseCase<List<CartItem>, NoParams> {
  final CartRepository repository;
  GetCartItems(this.repository);
  @override
  Future<Either<Failure, List<CartItem>>> call(NoParams params) => repository.getCartItems();
}