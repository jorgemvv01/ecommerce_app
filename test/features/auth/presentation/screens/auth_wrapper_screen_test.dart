import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/features/auth/presentation/screens/auth_wrapper_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/products/presentation/providers/product_providers.dart';
import 'package:ecommerce_app/features/products/presentation/screens/products_screen.dart';
import 'package:ecommerce_app/features/products/presentation/viewmodels/product_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel(super.state);
}
class MockProductsViewModel extends StateNotifier<ProductsState> with Mock implements ProductsViewModel {
  MockProductsViewModel(super.state);
}
class MockCartViewModel extends StateNotifier<CartState> with Mock implements CartViewModel {
  MockCartViewModel(super.state);
}

void main() {
  Widget createTestWidget({
    required MockAuthViewModel authViewModel,
    required MockProductsViewModel productsViewModel,
    required MockCartViewModel cartViewModel,
  }) {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => authViewModel),
        productsViewModelProvider.overrideWith((ref) => productsViewModel),
        cartViewModelProvider.overrideWith((ref) => cartViewModel),
      ],
      child: const MaterialApp(home: AuthWrapperScreen()),
    );
  }

  testWidgets('shows ProductsScreen when authenticated', (tester) async {
    final mockAuthVM = MockAuthViewModel(const AuthState(status: AuthStatus.authenticated));
    final mockProductsVM = MockProductsViewModel(const ProductsState());
    final mockCartVM = MockCartViewModel(const CartState());
    
    when(() => mockProductsVM.loadProducts()).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget(
      authViewModel: mockAuthVM,
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
    ));
    
    expect(find.byType(ProductsScreen), findsOneWidget);
  });

  testWidgets('shows LoginScreen when unauthenticated', (tester) async {
    final mockAuthVM = MockAuthViewModel(const AuthState(status: AuthStatus.unauthenticated));
    final mockProductsVM = MockProductsViewModel(const ProductsState());
    final mockCartVM = MockCartViewModel(const CartState());

    await tester.pumpWidget(createTestWidget(
      authViewModel: mockAuthVM,
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
    ));
    
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('shows LoginScreen when error', (tester) async {
    final mockAuthVM = MockAuthViewModel(const AuthState(status: AuthStatus.error, errorMessage: 'Error!'));
    final mockProductsVM = MockProductsViewModel(const ProductsState());
    final mockCartVM = MockCartViewModel(const CartState());

    await tester.pumpWidget(createTestWidget(
      authViewModel: mockAuthVM,
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
    ));
    
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('shows CustomLoading when initial or loading', (tester) async {
    final initialMock = MockAuthViewModel(const AuthState(status: AuthStatus.initial));
    final productsMock = MockProductsViewModel(const ProductsState());
    final cartMock = MockCartViewModel(const CartState());
    
    await tester.pumpWidget(createTestWidget(
      authViewModel: initialMock,
      productsViewModel: productsMock,
      cartViewModel: cartMock,
    ));
    expect(find.byType(CustomLoading), findsOneWidget);

    final loadingMock = MockAuthViewModel(const AuthState(status: AuthStatus.loading));
    await tester.pumpWidget(createTestWidget(
      authViewModel: loadingMock,
      productsViewModel: productsMock,
      cartViewModel: cartMock,
    ));
    expect(find.byType(CustomLoading), findsOneWidget);
  });

  testWidgets('shows error SnackBar when state changes to error', (tester) async {
    final mockAuthVM = MockAuthViewModel(const AuthState(status: AuthStatus.unauthenticated));
    final mockProductsVM = MockProductsViewModel(const ProductsState());
    final mockCartVM = MockCartViewModel(const CartState());

    await tester.pumpWidget(createTestWidget(
      authViewModel: mockAuthVM,
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
    ));
    expect(find.byType(SnackBar), findsNothing);

    mockAuthVM.state = const AuthState(status: AuthStatus.error, errorMessage: 'Test Error');
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Test Error'), findsOneWidget);
  });

  testWidgets('shows logout SnackBar when state changes from authenticated to unauthenticated', (tester) async {
    final mockAuthVM = MockAuthViewModel(const AuthState(status: AuthStatus.authenticated));
    final mockProductsVM = MockProductsViewModel(const ProductsState());
    final mockCartVM = MockCartViewModel(const CartState());
    when(() => mockProductsVM.loadProducts()).thenAnswer((_) async {});

    await tester.pumpWidget(createTestWidget(
      authViewModel: mockAuthVM,
      productsViewModel: mockProductsVM,
      cartViewModel: mockCartVM,
    ));
    expect(find.byType(SnackBar), findsNothing);

    mockAuthVM.state = const AuthState(status: AuthStatus.unauthenticated);
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Session closed correctly.'), findsOneWidget);
  });
}
