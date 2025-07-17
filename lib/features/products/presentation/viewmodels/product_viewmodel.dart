import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_categories.dart';
import 'package:ecommerce_app/features/products/domain/usecases/get_products.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

class ProductsState extends Equatable {
  final bool isLoading;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<String> categories;
  final String? selectedCategory;
  final String searchQuery;
  final String? errorMessage;

  const ProductsState({
    this.isLoading = false,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.errorMessage,
  });

  factory ProductsState.initial() => const ProductsState(isLoading: true);

  ProductsState copyWith({
    bool? isLoading,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProductsState(
      isLoading: isLoading ?? this.isLoading,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategory: clearCategory ? null : selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, allProducts, filteredProducts, categories, selectedCategory, searchQuery, errorMessage];
}


class ProductsViewModel extends StateNotifier<ProductsState> {
  final GetProducts _getProductsUseCase;
  final GetCategories _getCategoriesUseCase;
  bool _isFetching = false;

  ProductsViewModel(this._getProductsUseCase, this._getCategoriesUseCase) : super(ProductsState.initial());

  Future<void> loadProducts() async {
    if (_isFetching) return;
    _isFetching = true;
    state = state.copyWith(isLoading: true, clearError: true);

    final results = await Future.wait([
      _getCategoriesUseCase(NoParams()),
      _getProductsUseCase(NoParams()),
    ]);

    final failureOrCategories = results[0] as Either<Failure, List<String>>;
    final failureOrProducts = results[1] as Either<Failure, List<Product>>;

    failureOrCategories.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (categories) {
        failureOrProducts.fold(
          (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
          (products) {
            state = state.copyWith(
              isLoading: false,
              categories: categories,
              allProducts: products,
              filteredProducts: products,
            );
          },
        );
      },
    );
    
    _isFetching = false;
  }

  void filterByCategory(String? category) {
    state = state.copyWith(selectedCategory: category, clearCategory: category == null);
    _applyFilters();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    List<Product> filtered = List.from(state.allProducts);

    if (state.selectedCategory != null) {
      filtered = filtered.where((p) => p.category == state.selectedCategory).toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((p) =>
        p.title.toLowerCase().contains(query) ||
        p.description.toLowerCase().contains(query)
      ).toList();
    }
    
    state = state.copyWith(filteredProducts: filtered);
  }
}