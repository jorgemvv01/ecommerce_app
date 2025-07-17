import 'dart:developer';

import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/add_product_to_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/clear_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/get_cart_items.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/update_product_quantity.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  const CartState({this.items = const []});
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => items.fold(0, (sum, item) => sum + item.subtotal);
  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);
  @override
  List<Object> get props => [items];
}

class CartViewModel extends StateNotifier<CartState> {
  final GetCartItems _getCartItems;
  final AddProductToCart _addProductToCart;
  final UpdateProductQuantity _updateProductQuantity;
  final ClearCart _clearCart;

  CartViewModel(this._getCartItems, this._addProductToCart, this._updateProductQuantity, this._clearCart) : super(const CartState());

  Future<void> _refreshCart() async {
    final result = await _getCartItems(NoParams());
    result.fold(
      (failure) => log(failure.message),
      (items) => state = state.copyWith(items: items),
    );
  }

  Future<void> addProduct(Product product) async {
    await _addProductToCart(product);
    await _refreshCart();
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    await _updateProductQuantity(UpdateQuantityParams(productId: productId, newQuantity: newQuantity));
    await _refreshCart();
  }

  Future<void> clearCart() async {
    await _clearCart(NoParams());
    await _refreshCart();
  }
}