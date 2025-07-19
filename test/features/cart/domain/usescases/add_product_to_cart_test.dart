import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/add_product_to_cart.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/cart_repository_mock.dart';

void main() {
  late AddProductToCart usecase;
  late MockCartRepository mockCartRepository;

  setUpAll((){
    registerFallbackValue(const Product(
      id: 0,
      title: 'any title',
      price: 0.0,
      description: 'any desc',
      category: 'any cat',
      image: 'any img',
      rating: Rating(rate: 0.0, count: 0),
    ));
  });

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = AddProductToCart(mockCartRepository);
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

  test(
    'should call addProduct on the repository',
    () async {
      when(() => mockCartRepository.addProduct(any()))
          .thenAnswer((_) async => const Right(null));

      final result = await usecase(tProduct);

      expect(result, const Right(null));
      verify(() => mockCartRepository.addProduct(tProduct));
      verifyNoMoreInteractions(mockCartRepository);
    },
  );

  test(
    'should return a CacheFailure when the call to repository is unsuccessful',
    () async {
      when(() => mockCartRepository.addProduct(any()))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'Could not add product')));

      final result = await usecase(tProduct);

      expect(result, const Left(CacheFailure(message: 'Could not add product')));
      verify(() => mockCartRepository.addProduct(tProduct));
      verifyNoMoreInteractions(mockCartRepository);
    },
  );
}
