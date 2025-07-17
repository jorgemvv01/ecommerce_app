import 'package:ecommerce_app/features/cart/data/gateways/cart_remote_gateway.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/add_product_to_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/clear_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/get_cart_items.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/update_product_quantity.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartLocalGatewayProvider = Provider<CartLocalGateway>((ref) => InMemoryCartLocalGateway());
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localGateway: ref.watch(cartLocalGatewayProvider),
  );
});
final getCartItemsProvider = Provider<GetCartItems>((ref) => GetCartItems(ref.watch(cartRepositoryProvider)));
final addProductToCartProvider = Provider<AddProductToCart>((ref) => AddProductToCart(ref.watch(cartRepositoryProvider)));
final updateProductQuantityProvider = Provider<UpdateProductQuantity>((ref) => UpdateProductQuantity(ref.watch(cartRepositoryProvider)));
final clearCartProvider = Provider<ClearCart>((ref) => ClearCart(ref.watch(cartRepositoryProvider)));

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>((ref) {
  return CartViewModel(
    ref.watch(getCartItemsProvider),
    ref.watch(addProductToCartProvider),
    ref.watch(updateProductQuantityProvider),
    ref.watch(clearCartProvider),
  );
});