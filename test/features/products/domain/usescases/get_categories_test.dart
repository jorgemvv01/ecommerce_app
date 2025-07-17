
import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_categories.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks/product_repository_mock.dart';

void main() {
  late GetCategories usecase;
  late MockProductRepository mockProductRepository;

  setUp(() {
    mockProductRepository = MockProductRepository();
    usecase = GetCategories(mockProductRepository);
  });

  final tCategoriesList = ["electronics", "jewelery", "men's clothing"];

  test(
    'should get list of categories from the repository',
    () async {
      when(() => mockProductRepository.getCategories())
          .thenAnswer((_) async => Right(tCategoriesList));

      final result = await usecase(NoParams());

      expect(result, Right(tCategoriesList));
      verify(() => mockProductRepository.getCategories()).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    },
  );

  test(
    'should return a Failure when the call to repository is unsuccessful',
    () async {
      when(() => mockProductRepository.getCategories())
        .thenAnswer((_) async => const Left(NetworkFailure()));

      final result = await usecase(NoParams());

      expect(result, const Left(NetworkFailure(message: 'Could not connect to the network. Check your internet connection')));
      verify(() => mockProductRepository.getCategories()).called(1);
      verifyNoMoreInteractions(mockProductRepository);
    },
  );
}
