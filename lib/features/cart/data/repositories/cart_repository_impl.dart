import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/data/gateways/cart_local_gateway.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalGateway localGateway;
  
  CartRepositoryImpl({required this.localGateway});

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final items = await localGateway.getCartItems();
      return Right(items);
    } catch (e) {
      return const Left(CacheFailure(message: "Local cart could not be obtained"));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      await localGateway.addProduct(product);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: "Product could not be added"));
    }
  }

  @override
  Future<Either<Failure, void>> updateProductQuantity(int productId, int newQuantity) async {
    try {
      await localGateway.updateQuantity(productId, newQuantity);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: "The quantity could not be updated"));
    }
  }

  @override
  Future<Either<Failure, void>> removeProduct(int productId) async {
    try {
      await localGateway.removeProduct(productId);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: "Product could not be removed"));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await localGateway.clear();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure(message: "Cart could not be emptied"));
    }
  }
}