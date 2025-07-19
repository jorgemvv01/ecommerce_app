import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_providers.dart';
import 'package:ecommerce_app/features/products/presentation/screens/products_screen.dart';
import 'package:ecommerce_app/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:villa_design/villa_design.dart';


class MockProductsViewModel extends StateNotifier<ProductsState> with Mock implements ProductsViewModel {
  MockProductsViewModel(super.initialState);
}

class MockCartViewModel extends StateNotifier<CartState> with Mock implements CartViewModel {
  MockCartViewModel(super.initialState);
}

class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel(super.initialState);
}

void main() {
  const tProduct = Product(
    id: 1,
    title: 'Test Product',
    price: 10.0,
    description: 'Desc',
    category: 'Cat',
    image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
    rating: Rating(rate: 4.0, count: 100),
  );

  Widget createWidgetUnderTest({
    required MockProductsViewModel productsViewModel,
    required MockCartViewModel cartViewModel,
    required MockAuthViewModel authViewModel,
  }) {
    return ProviderScope(
      overrides: [
        productsViewModelProvider.overrideWith((ref) => productsViewModel),
        cartViewModelProvider.overrideWith((ref) => cartViewModel),
        authViewModelProvider.overrideWith((ref) => authViewModel),
      ],
      child: const MaterialApp(
        home: ProductsScreen(),
      ),
    );
  }

  void setupAllMocks(MockProductsViewModel mockProductsVM, MockAuthViewModel mockAuthVM) {
    when(() => mockProductsVM.loadProducts()).thenAnswer((_) async {});
    when(() => mockProductsVM.filterByCategory(any())).thenReturn(null);
    when(() => mockProductsVM.search(any())).thenReturn(null);
    when(() => mockAuthVM.logout()).thenAnswer((_) async {});
  }

  testWidgets('shows loading indicator when state is loading', (tester) async {
    final mockProductsVM = MockProductsViewModel(const ProductsState(isLoading: true));
    final mockCartVM = MockCartViewModel(const CartState());
    final mockAuthVM = MockAuthViewModel(AuthState.initial());
    setupAllMocks(mockProductsVM, mockAuthVM);
    
    await tester.pumpWidget(createWidgetUnderTest(
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
      authViewModel: mockAuthVM,
    ));

    expect(find.byType(CustomLoading), findsOneWidget);
  });

  testWidgets('shows error message when state has error', (tester) async {
    final mockProductsVM = MockProductsViewModel(const ProductsState(errorMessage: 'Failed to load'));
    final mockCartVM = MockCartViewModel(const CartState());
    final mockAuthVM = MockAuthViewModel(AuthState.initial());
    setupAllMocks(mockProductsVM, mockAuthVM);

    await tester.pumpWidget(createWidgetUnderTest(
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
      authViewModel: mockAuthVM,
    ));

    expect(find.text('Error: Failed to load'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows products grid when loading is successful', (tester) async {
    final mockProductsVM = MockProductsViewModel(const ProductsState(
      filteredProducts: [tProduct],
      allProducts: [tProduct],
    ));
    final mockCartVM = MockCartViewModel(const CartState());
    final mockAuthVM = MockAuthViewModel(AuthState.initial());
    setupAllMocks(mockProductsVM, mockAuthVM);

    await tester.pumpWidget(createWidgetUnderTest(
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
      authViewModel: mockAuthVM,
    ));

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(ProductCard), findsOneWidget);
  });

  testWidgets('calls search on viewmodel when text is entered in search bar', (tester) async {
    final mockProductsVM = MockProductsViewModel(const ProductsState());
    final mockCartVM = MockCartViewModel(const CartState());
    final mockAuthVM = MockAuthViewModel(AuthState.initial());
    setupAllMocks(mockProductsVM, mockAuthVM);

    await tester.pumpWidget(createWidgetUnderTest(
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
      authViewModel: mockAuthVM,
    ));
    await tester.enterText(find.byType(VillaSearchBar), 'laptop');
    await tester.pump();

    verify(() => mockProductsVM.search('laptop')).called(1);
  });

  testWidgets('calls filterByCategory on viewmodel when a category chip is tapped', (tester) async {
    final mockProductsVM = MockProductsViewModel(const ProductsState(categories: ['electronics']));
    final mockCartVM = MockCartViewModel(const CartState());
    final mockAuthVM = MockAuthViewModel(AuthState.initial());
    setupAllMocks(mockProductsVM, mockAuthVM);

    await tester.pumpWidget(createWidgetUnderTest(
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
      authViewModel: mockAuthVM,
    ));
    await tester.tap(find.text('electronics'));
    await tester.pump();

    verify(() => mockProductsVM.filterByCategory('electronics')).called(1);
  });
}
