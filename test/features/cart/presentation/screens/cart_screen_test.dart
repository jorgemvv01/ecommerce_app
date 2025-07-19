import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:villa_design/villa_design.dart';

class MockCartViewModel extends StateNotifier<CartState> with Mock implements CartViewModel {
  MockCartViewModel(super.initialState);

  @override
  Future<void> updateQuantity(int productId, int newQuantity) =>
      (noSuchMethod(Invocation.method(#updateQuantity, [productId, newQuantity])) ??
          Future.value()) as Future<void>;

  @override
  Future<void> clearCart() =>
      (noSuchMethod(Invocation.method(#clearCart, [])) ??
          Future.value()) as Future<void>;
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

  Widget createWidgetUnderTest({required MockCartViewModel mock}) {
    return ProviderScope(
      overrides: [
        cartViewModelProvider.overrideWith((ref) => mock),
      ],
      child: const MaterialApp(
        home: CartScreen(),
      ),
    );
  }

  group('CartScreen', () {
    testWidgets('shows empty message when cart is empty', (tester) async {
      final mock = MockCartViewModel(const CartState(items: []));

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      expect(find.text('Your cart is empty'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('shows list of items when cart is not empty', (tester) async {
      const cartItem = CartItem(product: tProduct, quantity: 2);
      final mock = MockCartViewModel(const CartState(items: [cartItem]));

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      expect(find.byType(ListView), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Test Product'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('calls updateQuantity when quantity buttons are tapped', (tester) async {
      const cartItem = CartItem(product: tProduct, quantity: 2);
      final mock = MockCartViewModel(const CartState(items: [cartItem]));
      when(() => mock.updateQuantity(any(), any())).thenAnswer((_) async {});

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      final addButton = find.widgetWithIcon(VillaIconButton, Icons.add_circle_outline);
      await tester.tap(addButton);
      await tester.pump();

      verify(() => mock.updateQuantity(tProduct.id, 3)).called(1);

      final removeButton = find.widgetWithIcon(VillaIconButton, Icons.remove_circle_outline);
      await tester.tap(removeButton);
      await tester.pump();

      verify(() => mock.updateQuantity(tProduct.id, 1)).called(1);
    });

    testWidgets('shows confirmation dialog and calls clearCart when delete button is tapped', (tester) async {
      const cartItem = CartItem(product: tProduct, quantity: 1);
      final mock = MockCartViewModel(const CartState(items: [cartItem]));
      when(() => mock.clearCart()).thenAnswer((_) async {});

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      final deleteIcon = find.widgetWithIcon(VillaIconButton, Icons.delete_outline);
      expect(deleteIcon, findsOneWidget);

      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Confirm elimination'), findsOneWidget);

      await tester.tap(find.widgetWithText(VillaTextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => mock.clearCart()).called(1);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}
