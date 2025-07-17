import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/products/data/gateways/product_remote_gateway.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteGateway remoteGateway;

  ProductRepositoryImpl({
    required this.remoteGateway,
  });

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final products = await remoteGateway.getProducts();
      return Right(products);
    } on ServerException {
      return const Left(
        ServerFailure()
      );
    } on NetworkException {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    final productsResult = await getProducts();
    
    return productsResult.fold(
      (failure) => Left(failure),
      (products) {
        final categories = products.map((p) => p.category).toSet().toList();
        return Right(categories);
      },
    );
  }
}