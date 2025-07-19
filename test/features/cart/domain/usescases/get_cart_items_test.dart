import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/get_cart_items.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/cart_repository_mock.dart';

void main() {
  late GetCartItems usecase;
  late MockCartRepository mockCartRepository;

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = GetCartItems(mockCartRepository);
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
  const tCartItem = CartItem(product: tProduct, quantity: 2);
  const tCartItemsList = [tCartItem];

  test(
    'should get list of cart items from the repository',
    () async {
      when(() => mockCartRepository.getCartItems())
          .thenAnswer((_) async => const Right(tCartItemsList));

      final result = await usecase(NoParams());

      expect(result, const Right(tCartItemsList));
      verify(() => mockCartRepository.getCartItems());
      verifyNoMoreInteractions(mockCartRepository);
    },
  );

  test(
    'should return a CacheFailure when the call to repository is unsuccessful',
    () async {
      when(() => mockCartRepository.getCartItems())
          .thenAnswer((_) async => const Left(CacheFailure(message: 'Error fetching cart')));

      final result = await usecase(NoParams());

      expect(result, const Left(CacheFailure(message: 'Error fetching cart')));
      verify(() => mockCartRepository.getCartItems());
      verifyNoMoreInteractions(mockCartRepository);
    },
  );
}
