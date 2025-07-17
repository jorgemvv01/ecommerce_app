import 'package:ecommerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';

abstract class CartLocalGateway {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addProduct(Product product);
  Future<void> updateQuantity(int productId, int newQuantity);
  Future<void> removeProduct(int productId);
  Future<void> clear();
}

class InMemoryCartLocalGateway implements CartLocalGateway {
  final List<CartItemModel> _items = [];

  @override
  Future<void> addProduct(Product product) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      final existingItem = _items[existingIndex];
      _items[existingIndex] = CartItemModel(
        product: existingItem.product,
        quantity: existingItem.quantity + 1,
      );
    } else {
      _items.add(CartItemModel(product: product, quantity: 1));
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems() async {
    return List.from(_items);
  }

  @override
  Future<void> removeProduct(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
  }

  @override
  Future<void> updateQuantity(int productId, int newQuantity) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == productId);
    if (existingIndex != -1) {
      if (newQuantity > 0) {
        _items[existingIndex] = _items[existingIndex].copyWith(quantity: newQuantity);
      } else {
        removeProduct(productId);
      }
    }
  }

  @override
  Future<void> clear() async {
    _items.clear();
  }
}