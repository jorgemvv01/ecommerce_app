import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.product,
    required super.quantity,
  });


  CartItemModel copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}