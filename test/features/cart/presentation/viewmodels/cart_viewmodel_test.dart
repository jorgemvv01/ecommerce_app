import 'package:ecommerce_app/features/cart/domain/usescases/add_product_to_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/clear_cart.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/get_cart_items.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/update_product_quantity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';

// Mocks
class MockGetCartItems extends Mock implements GetCartItems {}
class MockAddProductToCart extends Mock implements AddProductToCart {}
class MockUpdateProductQuantity extends Mock implements UpdateProductQuantity {}
class MockClearCart extends Mock implements ClearCart {}

void main() {
  late CartViewModel viewModel;
  late MockGetCartItems mockGetCartItems;
  late MockAddProductToCart mockAddProductToCart;
  late MockUpdateProductQuantity mockUpdateProductQuantity;
  late MockClearCart mockClearCart;

  setUpAll(() {
    registerFallbackValue(const Product(id: 0, title: '', price: 0, description: '', category: '', image: '', rating: Rating(rate: 0, count: 0)));
    registerFallbackValue(const UpdateQuantityParams(productId: 0, newQuantity: 0));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetCartItems = MockGetCartItems();
    mockAddProductToCart = MockAddProductToCart();
    mockUpdateProductQuantity = MockUpdateProductQuantity();
    mockClearCart = MockClearCart();
    viewModel = CartViewModel(
      mockGetCartItems,
      mockAddProductToCart,
      mockUpdateProductQuantity,
      mockClearCart,
    );
  });

  const tProduct = Product(id: 1, title: 'Test Product', price: 10.0, description: '', category: '', image: '', rating: Rating(rate: 4, count: 100));
  const tCartItem = CartItem(product: tProduct, quantity: 1);
  const tCartItemsList = [tCartItem];

  void setupGetCartItemsSuccess() {
    when(() => mockGetCartItems(any())).thenAnswer((_) async => const Right(tCartItemsList));
  }

  test('initial state should be empty', () {
    expect(viewModel.state, const CartState(items: []));
  });

  group('addProduct', () {
    test('should call AddProductToCart and refresh the cart', () async {
      when(() => mockAddProductToCart(any())).thenAnswer((_) async => const Right(null));
      setupGetCartItemsSuccess();

      await viewModel.addProduct(tProduct);

      verify(() => mockAddProductToCart(tProduct)).called(1);
      verify(() => mockGetCartItems(NoParams())).called(1);
      expect(viewModel.state.items, tCartItemsList);
    });
  });

  group('updateQuantity', () {
    test('should call UpdateProductQuantity and refresh the cart', () async {
      when(() => mockUpdateProductQuantity(any())).thenAnswer((_) async => const Right(null));
      setupGetCartItemsSuccess();

      await viewModel.updateQuantity(1, 5);

      verify(() => mockUpdateProductQuantity(const UpdateQuantityParams(productId: 1, newQuantity: 5))).called(1);
      verify(() => mockGetCartItems(NoParams())).called(1);
      expect(viewModel.state.items, tCartItemsList);
    });
  });

  group('clearCart', () {
    test('should call ClearCart and refresh the cart to an empty list', () async {
      when(() => mockClearCart(any())).thenAnswer((_) async => const Right(null));
      when(() => mockGetCartItems(any())).thenAnswer((_) async => const Right([]));

      await viewModel.clearCart();

      verify(() => mockClearCart(NoParams())).called(1);
      verify(() => mockGetCartItems(NoParams())).called(1);
      expect(viewModel.state.items, isEmpty);
    });
  });
}
