import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_products.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/core/errors/failures.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProducts usecase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetProducts(mockProductRepository);
  });

  const tRating = Rating(rate: 4.5, count: 100);
  const tProduct = Product(
    id: 1, title: 'Test product',
    price: 99.99,
    description: 'Test desc',
    category: 'Test cat',
    image: 'test.jpg',
    rating: tRating
  );
  final tProductList = [tProduct];

  test(
    'should get list of products from the repository',
    () async {
      when(() => mockProductRepository.getProducts())
        .thenAnswer((_) async => Right(tProductList));
      final result = await usecase(NoParams());
      expect(result, Right(tProductList));
      verify(() => mockProductRepository.getProducts()).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test(
    'should return a ServerFailure when the call to repository is unsuccessful',
    () async {
      when(() => mockProductRepository.getProducts())
        .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      final result = await usecase(NoParams());

      expect(result, const Left(ServerFailure(message: 'Server error')));
      verify(() => mockProductRepository.getProducts()).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    },
  );
}