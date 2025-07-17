import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCartItems();
  Future<Either<Failure, void>> addProduct(Product product);
  Future<Either<Failure, void>> updateProductQuantity(int productId, int newQuantity);
  Future<Either<Failure, void>> removeProduct(int productId);
  Future<Either<Failure, void>> clearCart();
}