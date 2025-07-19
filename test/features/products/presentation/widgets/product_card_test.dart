import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartViewModel extends StateNotifier<CartState> with Mock implements CartViewModel {
  MockCartViewModel(super.initialState);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Product(id: 0, title: '', price: 0, description: '', category: '', image: '', rating: Rating(rate: 0, count: 0)));
  });

  const tProduct = Product(
    id: 1,
    title: 'Test Product Title',
    price: 99.99,
    description: 'Test Description',
    category: 'Test Category',
    image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
    rating: Rating(rate: 4.5, count: 120),
  );


  Widget createWidgetUnderTest({required MockCartViewModel mock}) {
    return ProviderScope(
      overrides: [
        cartViewModelProvider.overrideWith((ref) => mock),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: ProductCard(product: tProduct),
        ),
      ),
    );
  }

  group('ProductCard', () {
    testWidgets('renders product title and price correctly', (WidgetTester tester) async {
      final mock = MockCartViewModel(const CartState(items: []));
      when(() => mock.addProduct(any())).thenAnswer((_) async {});
      when(() => mock.updateQuantity(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest(mock: mock));

      expect(find.text('Test Product Title'), findsOneWidget);
      expect(find.text('\$99.99'), findsOneWidget);
    });

    testWidgets('shows "Add to cart" button when product is not in cart', (WidgetTester tester) async {
      final mock = MockCartViewModel(const CartState(items: []));
      when(() => mock.addProduct(any())).thenAnswer((_) async {});
      
      await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      
      final addButton = find.text('Add to cart');
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      verify(() => mock.addProduct(tProduct)).called(1);
    });

    testWidgets('shows quantity selector when product is in cart', (WidgetTester tester) async {

      const cartItem = CartItem(product: tProduct, quantity: 2);
      final mock = MockCartViewModel(const CartState(items: [cartItem]));
      when(() => mock.updateQuantity(any(), any())).thenAnswer((_) async {});
      
      await tester.pumpWidget(createWidgetUnderTest(mock: mock));

      expect(find.text('2'), findsOneWidget);
      final addButton = find.byIcon(Icons.add_circle_outline);
      final removeButton = find.byIcon(Icons.remove_circle_outline);
      expect(addButton, findsOneWidget);
      expect(removeButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      verify(() => mock.updateQuantity(tProduct.id, 3)).called(1);
    });
  });
}
