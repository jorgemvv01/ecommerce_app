import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/features/products/data/models/product_model.dart';
import 'package:fake_store_api_client/fake_store_api_client.dart';

abstract class ProductRemoteGateway {
  Future<List<ProductModel>> getProducts();
}

class ProductRemoteGatewayImpl implements ProductRemoteGateway {
  final FakeStoreApiClient apiClient;
  
  ProductRemoteGatewayImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    final result = await apiClient.products.getProducts();

    return result.fold(
      (failure) => throw ServerException(),
      (products) {
        return products
          .map((product) => ProductModel.fromJson(product.toJson()))
          .toList();
      },
    );
  }
}