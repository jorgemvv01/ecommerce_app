import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_store_api_client/fake_store_api_client.dart' as api_client;

import 'package:ecommerce_app/features/products/data/gateways/product_remote_gateway.dart';
import 'package:ecommerce_app/features/products/data/models/product_model.dart';
import 'package:ecommerce_app/core/errors/exceptions.dart';

class MockFakeStoreApiClient extends Mock implements api_client.FakeStoreApiClient {}
class MockProductsApi extends Mock implements api_client.ProductApiHandler {}

void main() {
  late ProductRemoteGatewayImpl gateway;
  late MockFakeStoreApiClient mockApiClient;
  late MockProductsApi mockProductsApi;

  setUp(() {
    mockApiClient = MockFakeStoreApiClient();
    mockProductsApi = MockProductsApi();
    gateway = ProductRemoteGatewayImpl(apiClient: mockApiClient);
    when(() => mockApiClient.products).thenReturn(mockProductsApi);
  });

  final tRating = api_client.Rating(rate: 4.5, count: 100);
  final tApiClientProduct = api_client.Product(
    id: 1,
    title: 'Test Product',
    price: 99.99,
    description: 'Test Desc',
    category: 'electronics',
    image: 'test.jpg',
    rating: tRating,
  );
  final tApiClientProductList = [tApiClientProduct];

  const tRatingModel = RatingModel(rate: 4.5, count: 100);
  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Product',
    price: 99.99,
    description: 'Test Desc',
    category: 'electronics',
    image: 'test.jpg',
    rating: tRatingModel,
  );
  final tProductModelList = [tProductModel];

  group('getProducts', () {
    test(
      'should return a list of ProductModel when the call to api client is successful',
      () async {
        when(() => mockProductsApi.getProducts())
            .thenAnswer((_) async => Right(tApiClientProductList));

        final result = await gateway.getProducts();

        expect(result, equals(tProductModelList));
        verify(() => mockProductsApi.getProducts()).called(1);
        verifyNoMoreInteractions(mockProductsApi);
      },
    );

    test(
      'should throw a ServerException when the call to api client is unsuccessful',
      () async {
        const tApiFailure = api_client.ServerFailure('API error');
        when(() => mockProductsApi.getProducts())
            .thenAnswer((_) async => const Left(tApiFailure));

        final call = gateway.getProducts;

        expect(() => call(), throwsA(isA<ServerException>()));
      },
    );

    test(
      'should throw a NetworkException when the call to api client is unsuccessful due to network issues',
      () async {
        const tApiFailure = api_client.NetworkFailure();
        when(() => mockProductsApi.getProducts())
            .thenAnswer((_) async => const Left(tApiFailure));

        final call = gateway.getProducts;

        expect(() => call(), throwsA(isA<NetworkException>()));
      },
    );
  });
}
