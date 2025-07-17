import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class AddProductToCart implements UseCase<void, Product> {
  final CartRepository repository;
  AddProductToCart(this.repository);
  @override
  Future<Either<Failure, void>> call(Product params) => repository.addProduct(params);
}