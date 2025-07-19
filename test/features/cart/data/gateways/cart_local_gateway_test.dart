import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app/features/cart/data/gateways/cart_local_gateway.dart';
import 'package:ecommerce_app/features/products/domain/entities/product.dart';
import 'package:ecommerce_app/features/cart/data/models/cart_item_model.dart';

void main() {
  late InMemoryCartLocalGateway gateway;

  setUp(() {
    gateway = InMemoryCartLocalGateway();
  });

  const tProduct1 = Product(
    id: 1,
    title: 'Product 1',
    price: 10.0,
    description: 'Desc 1',
    category: 'Cat 1',
    image: 'img1.jpg',
    rating: Rating(rate: 4.0, count: 100),
  );
  const tProduct2 = Product(
    id: 2,
    title: 'Product 2',
    price: 20.0,
    description: 'Desc 2',
    category: 'Cat 2',
    image: 'img2.jpg',
    rating: Rating(rate: 5.0, count: 200),
  );

  test('should be empty initially', () async {
    final result = await gateway.getCartItems();
    expect(result, isEmpty);
  });

  group('addProduct', () {
    test('should add a new product to the cart', () async {
      await gateway.addProduct(tProduct1);

      final result = await gateway.getCartItems();

      expect(result, [const CartItemModel(product: tProduct1, quantity: 1)]);
    });

    test('should increment quantity if product already exists', () async {
      await gateway.addProduct(tProduct1);
      await gateway.addProduct(tProduct1);

      final result = await gateway.getCartItems();

      expect(result, [const CartItemModel(product: tProduct1, quantity: 2)]);
    });

    test('should add multiple different products', () async {
      await gateway.addProduct(tProduct1);
      await gateway.addProduct(tProduct2);

      final result = await gateway.getCartItems();

      expect(result, hasLength(2));
      expect(result, contains(const CartItemModel(product: tProduct1, quantity: 1)));
      expect(result, contains(const CartItemModel(product: tProduct2, quantity: 1)));
    });
  });

  group('updateQuantity', () {
    test('should update the quantity of an existing product', () async {
      await gateway.addProduct(tProduct1);
      await gateway.updateQuantity(tProduct1.id, 5);

      final result = await gateway.getCartItems();

      expect(result, [const CartItemModel(product: tProduct1, quantity: 5)]);
    });

    test('should remove the product if quantity is 0', () async {
      await gateway.addProduct(tProduct1);
      await gateway.updateQuantity(tProduct1.id, 0);

      final result = await gateway.getCartItems();

      expect(result, isEmpty);
    });

    test('should do nothing if product does not exist', () async {
      await gateway.updateQuantity(99, 5);

      final result = await gateway.getCartItems();

      expect(result, isEmpty);
    });
  });

  group('clear', () {
    test('should remove all items from the cart', () async {
      await gateway.addProduct(tProduct1);
      await gateway.addProduct(tProduct2);

      await gateway.clear();

      final result = await gateway.getCartItems();
      expect(result, isEmpty);
    });
  });
}
