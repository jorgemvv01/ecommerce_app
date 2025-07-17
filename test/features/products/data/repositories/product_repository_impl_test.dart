import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/products/data/models/product_model.dart';
import 'package:ecommerce_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mocks/product_remote_gateway_mock.dart';

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteGateway mockRemoteGateway;

  setUp(() {
    mockRemoteGateway = MockProductRemoteGateway();
    repository = ProductRepositoryImpl(remoteGateway: mockRemoteGateway);
  });

  const tRatingModel = RatingModel(rate: 4.5, count: 100);
  const tProductModel = ProductModel(
    id: 1,
    title: 'Test product',
    price: 99.99, 
    description: 'Test desc',
    category: 'electronics',
    image: 'test.jpg',
    rating: tRatingModel
  );
  final tProductModelList = [tProductModel];
  final List<Product> tProductList = tProductModelList;

  group('getProducts', () {
    test(
      'should return remote data when the call to remote gateway is successful',
      () async {
        when(() => mockRemoteGateway.getProducts())
            .thenAnswer((_) async => tProductModelList);

        final result = await repository.getProducts();
        verify(() => mockRemoteGateway.getProducts()).called(1);
        expect(result, equals(Right(tProductList)));
      },
    );

    test(
      'should return server failure when the call to remote gateway is unsuccessful (ServerException)',
      () async {
        when(() => mockRemoteGateway.getProducts()).thenThrow(ServerException());

        final result = await repository.getProducts();
        verify(() => mockRemoteGateway.getProducts()).called(1);
        expect(result, isA<Left<Failure, List<Product>>>());
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (products) => fail('Expected a failure, but got a success'),
        );
      },
    );

    test(
      'should return network failure when the call to remote gateway is unsuccessful (NetworkException)',
      () async {
        when(() => mockRemoteGateway.getProducts()).thenThrow(NetworkException());
        final result = await repository.getProducts();

        verify(() => mockRemoteGateway.getProducts()).called(1);
        expect(result, isA<Left<Failure, List<Product>>>());
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (products) => fail('Expected a failure, but got a success'),
        );
      },
    );
  });

  group('getCategories', () {
    test(
      'should return list of categories when getProducts is successful',
      () async {
        when(() => mockRemoteGateway.getProducts())
            .thenAnswer((_) async => tProductModelList);

        final result = await repository.getCategories();

        verify(() => mockRemoteGateway.getProducts()).called(1);
        result.fold(
          (failure) => fail('Expected a Right, but got a Left: $failure'),
          (categories) => expect(categories, ['electronics']),
        );
      },
    );

    test(
      'should return a failure when getProducts is unsuccessful',
      () async {
        when(() => mockRemoteGateway.getProducts()).thenThrow(ServerException());

        final result = await repository.getCategories();
        verify(() => mockRemoteGateway.getProducts()).called(1);

        expect(result, isA<Left<Failure, List<String>>>());
      },
    );
  });
}
