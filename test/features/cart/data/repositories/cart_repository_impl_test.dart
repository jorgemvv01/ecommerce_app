import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/data/gateways/cart_local_gateway.dart';
import 'package:ecommerce_app/features/cart/data/models/cart_item_model.dart';
import 'package:ecommerce_app/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartLocalGateway extends Mock implements CartLocalGateway {}

void main() {
  late CartRepositoryImpl repository;
  late MockCartLocalGateway mockLocalGateway;

  setUpAll(() {
    registerFallbackValue(const Product(
      id: 0,
      title: 'any title',
      price: 0.0,
      description: 'any description',
      category: 'any category',
      image: 'any_image.jpg',
      rating: Rating(rate: 0.0, count: 0),
    ));
  });

  setUp(() {
    mockLocalGateway = MockCartLocalGateway();
    repository = CartRepositoryImpl(localGateway: mockLocalGateway);
  });

  const tProduct = Product(
    id: 1,
    title: 'Test Product',
    price: 10.0,
    description: 'Test Desc',
    category: 'Test Cat',
    image: 'test.jpg',
    rating: Rating(rate: 4.0, count: 100),
  );
  const tCartItemModel = CartItemModel(product: tProduct, quantity: 1);
  const tCartItemModelList = [tCartItemModel];

  group('getCartItems', () {
    test(
      'should return cart items from local gateway',
      () async {
        when(() => mockLocalGateway.getCartItems())
            .thenAnswer((_) async => tCartItemModelList);

        final result = await repository.getCartItems();

        expect(result, const Right(tCartItemModelList));
        verify(() => mockLocalGateway.getCartItems());
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );

    test(
      'should return Exception when the call to local gateway is unsuccessful',
      () async {
        when(() => mockLocalGateway.getCartItems()).thenThrow(Exception());

        final result = await repository.getCartItems();

        expect(result, isA<Left<Failure, dynamic>>());
      },
    );
  });

  group('addProduct', () {
    test(
      'should call addProduct on local gateway',
      () async {
        when(() => mockLocalGateway.addProduct(any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.addProduct(tProduct);

        expect(result, const Right(null));
        verify(() => mockLocalGateway.addProduct(tProduct));
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });

  group('updateProductQuantity', () {
    test(
      'should call updateQuantity on local gateway',
      () async {
        when(() => mockLocalGateway.updateQuantity(any(), any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.updateProductQuantity(1, 5);

        expect(result, const Right(null));
        verify(() => mockLocalGateway.updateQuantity(1, 5));
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });

  group('clearCart', () {
    test(
      'should call clear on local gateway',
      () async {
        when(() => mockLocalGateway.clear())
            .thenAnswer((_) async => Future.value());

        final result = await repository.clearCart();

        expect(result, const Right(null));
        verify(() => mockLocalGateway.clear());
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });
}
