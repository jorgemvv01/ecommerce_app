import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  const CartItem({required this.product, required this.quantity});
  
  double get subtotal => product.price * quantity;

  @override
  List<Object> get props => [product, quantity];
}