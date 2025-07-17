import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_categories.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_products.dart';
import 'package:ecommerce_app/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducts extends Mock implements GetProducts {}
class MockGetCategories extends Mock implements GetCategories {}

void main() {
  late ProductsViewModel viewModel;
  late MockGetProducts mockGetProducts;
  late MockGetCategories mockGetCategories;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetCategories = MockGetCategories();
    viewModel = ProductsViewModel(mockGetProducts, mockGetCategories);
  });

  const tRating = Rating(rate: 4.0, count: 100);
  const tProduct1 = Product(id: 1, title: 'Laptop', price: 1200, description: 'desc', category: 'electronics', image: 'img.jpg', rating: tRating);
  const tProduct2 = Product(id: 2, title: 'T-Shirt', price: 25, description: 'desc', category: 'clothing', image: 'img.jpg', rating: tRating);
  final tProductList = [tProduct1, tProduct2];
  final tCategoriesList = ['electronics', 'clothing'];

  group('initialLoad', () {
    test(
      'should set state to loading, then to success with products and categories',
      () async {
        when(() => mockGetProducts(any())).thenAnswer((_) async => Right(tProductList));
        when(() => mockGetCategories(any())).thenAnswer((_) async => Right(tCategoriesList));

        final future = viewModel.loadProducts();

        expect(viewModel.state.isLoading, isTrue);

        await future;

        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.allProducts, tProductList);
        expect(viewModel.state.filteredProducts, tProductList);
        expect(viewModel.state.categories, tCategoriesList);
        expect(viewModel.state.errorMessage, isNull);
      },
    );

    test(
      'should set state to error when getting products fails',
      () async {
        when(() => mockGetCategories(any())).thenAnswer((_) async => Right(tCategoriesList));
        when(() => mockGetProducts(any())).thenAnswer((_) async => const Left(ServerFailure(message: 'Error')));

        await viewModel.loadProducts();

        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.errorMessage, 'Error');
        expect(viewModel.state.allProducts, isEmpty);
      },
    );
  });

  group('filtering and searching', () {
    setUp(() {
      viewModel.state = viewModel.state.copyWith(
        allProducts: tProductList,
        filteredProducts: tProductList,
      );
    });

    test('filterByCategory should update filteredProducts', () {
      viewModel.filterByCategory('electronics');

      expect(viewModel.state.selectedCategory, 'electronics');
      expect(viewModel.state.filteredProducts, [tProduct1]);
    });

    test('search should update filteredProducts based on title', () {
      viewModel.search('Laptop');

      expect(viewModel.state.searchQuery, 'Laptop');
      expect(viewModel.state.filteredProducts, [tProduct1]);
    });

    test('clearing category filter should show all products', () {
      viewModel.filterByCategory('electronics');
      
      viewModel.filterByCategory(null);

      expect(viewModel.state.selectedCategory, isNull);
      expect(viewModel.state.filteredProducts, tProductList);
    });
  });
}
