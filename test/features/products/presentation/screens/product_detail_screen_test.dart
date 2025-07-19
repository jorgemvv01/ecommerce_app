import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:ecommerce_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:ecommerce_app/features/cart/presentation/viewmodels/cart_viewmodel.dart';
import 'package:ecommerce_app/features/cart/presentation/providers/cart_providers.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/cart/domain/entities/cart_item.dart';
import 'package:villa_design/villa_design.dart';

class MockCartViewModel extends StateNotifier<CartState> with Mock implements CartViewModel {
  MockCartViewModel(super.initialState);
}

void main() {
  setUpAll(() {
    registerFallbackValue(const Product(id: 0, title: '', price: 0, description: '', category: '', image: '', rating: Rating(rate: 0, count: 0)));
  });

  const tProduct = Product(
    id: 1,
    title: 'Detailed Product Title',
    price: 123.45,
    description: 'This is a detailed product description.',
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
        home: ProductDetailScreen(product: tProduct),
      ),
    );
  }

  group('ProductDetailScreen', () {
    testWidgets('renders all product details correctly', (tester) async {
      final mock = MockCartViewModel(const CartState(items: []));
      when(() => mock.addProduct(any())).thenAnswer((_) async {});
      when(() => mock.updateQuantity(any(), any())).thenAnswer((_) async {});

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      expect(find.text('Detailed Product Title'), findsWidgets);
      expect(find.text('\$123.45'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('This is a detailed product description.'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows "Add to cart" button when product is not in cart', (tester) async {
      final mock = MockCartViewModel(const CartState(items: []));
      when(() => mock.addProduct(any())).thenAnswer((_) async {});

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      final addButton = find.widgetWithText(VillaElevatedButton, 'Add to cart');
      tester.ensureVisible(addButton);
      expect(addButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      verify(() => mock.addProduct(tProduct)).called(1);
    });

    testWidgets('shows quantity selector when product is in cart', (tester) async {
      const cartItem = CartItem(product: tProduct, quantity: 3);
      final mock = MockCartViewModel(const CartState(items: [cartItem]));
      when(() => mock.updateQuantity(any(), any())).thenAnswer((_) async {});

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(mock: mock));
      });

      expect(find.text('3'), findsOneWidget);
      final addButton = find.widgetWithIcon(VillaIconButton, Icons.add);
      final removeButton = find.widgetWithIcon(VillaIconButton, Icons.remove);
      tester.ensureVisible(addButton);
      tester.ensureVisible(removeButton);
      expect(addButton, findsOneWidget);
      expect(removeButton, findsOneWidget);

      await tester.tap(addButton);
      await tester.pump();

      verify(() => mock.updateQuantity(tProduct.id, 4)).called(1);
    });
  });
}
