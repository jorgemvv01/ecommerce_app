import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/cart/presentation/widgets/cart_icon_badge.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCartViewModel extends StateNotifier<CartState> with Mock implements CartViewModel {
  MockCartViewModel(super.state);
}

void main() {
  Widget createWidgetUnderTest({required MockCartViewModel mock}) {
    return ProviderScope(
      overrides: [
        cartViewModelProvider.overrideWith((ref) => mock),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: CartIconBadge(),
        ),
      ),
    );
  }

  group('CartIconBadge', () {
    testWidgets('shows no badge when cart is empty', (tester) async {
      final mock = MockCartViewModel(const CartState(items: []));

      await tester.pumpWidget(createWidgetUnderTest(mock: mock));

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.byType(Container), findsNothing);
    });

    testWidgets('shows badge with correct item count when cart is not empty', (tester) async {
      const tProduct = Product(id: 1, title: 'Test', price: 10, description: '', category: '', image: '', rating: Rating(rate: 4, count: 100));
      final mock = MockCartViewModel(CartState(items: [
        const CartItem(product: tProduct, quantity: 3),
        CartItem(product: tProduct.copyWith(id: 2), quantity: 2),
      ]));

      await tester.pumpWidget(createWidgetUnderTest(mock: mock));

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}
