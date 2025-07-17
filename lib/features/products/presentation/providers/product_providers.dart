
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/features/products/data/gateways/product_remote_gateway.dart';
import 'package:ecommerce_app/features/products/data/repositories/product_repository_impl.dart';
import 'package:ecommerce_app/features/products/domain/repositories/product_repository.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_categories.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_products.dart';
import 'package:ecommerce_app/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRemoteGatewayProvider = Provider<ProductRemoteGateway>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProductRemoteGatewayImpl(apiClient: apiClient);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteGateway = ref.watch(productRemoteGatewayProvider);
  return ProductRepositoryImpl(remoteGateway: remoteGateway);
});

final getCategoriesUseCaseProvider = Provider<GetCategories>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetCategories(repository);
});

final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  final repository = ref.watch(productRepositoryProvider);
  return GetProducts(repository);
});

final productsViewModelProvider = StateNotifierProvider<ProductsViewModel, ProductsState>((ref) {
  final getProductsUseCase = ref.watch(getProductsUseCaseProvider);
  final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
  return ProductsViewModel(getProductsUseCase, getCategoriesUseCase);
});