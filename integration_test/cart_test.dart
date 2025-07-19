import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecommerce_app/features/products/presentation/screens/product_detail_screen.dart';
import 'package:ecommerce_app/features/products/presentation/screens/products_screen.dart';
import 'package:ecommerce_app/features/products/presentation/widgets/product_card.dart';
import 'package:ecommerce_app/main.dart' as app;
import 'package:fake_store_api_client/fake_store_api_client.dart' as api_client;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:villa_design/villa_design.dart';

class MockFakeStoreApiClient extends Mock implements api_client.FakeStoreApiClient {}
class MockAuthApi extends Mock implements api_client.AuthApiHandler {}
class MockUsersApi extends Mock implements api_client.UserApiHandler {}
class MockProductsApi extends Mock implements api_client.ProductApiHandler {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockFakeStoreApiClient mockApiClient;
  late MockAuthApi mockAuthApi;
  late MockUsersApi mockUsersApi;
  late MockProductsApi mockProductsApi;

  setUpAll((){
    registerFallbackValue(const api_client.LoginRequest(username: 'any', password: 'any'));
  });

  setUp(() async{
    await const FlutterSecureStorage().deleteAll();
    mockApiClient = MockFakeStoreApiClient();
    mockAuthApi = MockAuthApi();
    mockUsersApi = MockUsersApi();
    mockProductsApi = MockProductsApi();

    when(() => mockApiClient.auth).thenReturn(mockAuthApi);
    when(() => mockApiClient.users).thenReturn(mockUsersApi);
    when(() => mockApiClient.products).thenReturn(mockProductsApi);
  });

  const tUser = api_client.User(
      id: 1, email: 'test@test.com', username: 'testuser', password: '',
      name: api_client.Name(firstname: 'John', lastname: 'Doe'),
      address: api_client.Address(city: '', street: '', number: 0, zipcode: '', geolocation: api_client.Geolocation(lat: '', long: '')),
      phone: ''
  );
  final tProduct1 = api_client.Product(
    id: 1,
    title: 'Test Product 1',
    price: 10.0,
    description: 'Desc 1',
    category: 'electronics',
    image: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_.jpg',
    rating: api_client.Rating(rate: 4.0, count: 100),
  );
  final tProduct2 = api_client.Product(
    id: 2,
    title: 'Test Product 2',
    price: 25.5,
    description: 'Desc 2',
    category: 'electronics',
    image: 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
    rating: api_client.Rating(rate: 4.5, count: 200),
  );

  testWidgets('Shopping flow: login, add product to cart, and verify cart', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right('fake_token'));
    when(() => mockUsersApi.getUsers()).thenAnswer((_) async => const Right([tUser]));
    when(() => mockProductsApi.getProducts()).thenAnswer((_) async => Right([tProduct1]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');
    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductsScreen), findsOneWidget);

    expect(find.text('Test Product 1'), findsOneWidget);

    final addToCartButton = find.descendant(
      of: find.byType(ProductCard),
      matching: find.text('Add to cart'),
    );
    expect(addToCartButton, findsOneWidget);
    await tester.tap(addToCartButton);
    await tester.pump();

    expect(find.text('1'), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);
    
    expect(find.text('Test Product 1'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('Shopping flow: add multiple items, update quantity, and verify total', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right('fake_token'));
    when(() => mockUsersApi.getUsers()).thenAnswer((_) async => const Right([tUser]));
    when(() => mockProductsApi.getProducts()).thenAnswer((_) async => Right([tProduct1, tProduct2]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');
    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    final addToCart1 = find.descendant(of: find.widgetWithText(ProductCard, 'Test Product 1'), matching: find.text('Add to cart'));
    await tester.tap(addToCart1);
    await tester.pump();

    final addToCart2 = find.descendant(of: find.widgetWithText(ProductCard, 'Test Product 2'), matching: find.text('Add to cart'));
    await tester.tap(addToCart2);
    await tester.pump();

    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);

    final decreaseButton = find.descendant(
      of: find.widgetWithText(ListTile, 'Test Product 1'),
      matching: find.byIcon(Icons.remove_circle_outline),
    );
    await tester.tap(decreaseButton);
    await tester.pump();

    expect(find.text('Test Product 1'), findsNothing);
  });

  testWidgets('Shopping flow: clear cart', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right('fake_token'));
    when(() => mockUsersApi.getUsers()).thenAnswer((_) async => const Right([tUser]));
    when(() => mockProductsApi.getProducts()).thenAnswer((_) async => Right([tProduct1]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');
    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    final addToCartButton = find.descendant(of: find.byType(ProductCard), matching: find.text('Add to cart'));
    await tester.tap(addToCartButton);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);
    expect(find.text('Test Product 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });

  testWidgets('Shopping flow: product loading fails', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right('fake_token'));
    when(() => mockUsersApi.getUsers()).thenAnswer((_) async => const Right([tUser]));
    when(() => mockProductsApi.getProducts()).thenAnswer((_) async => const Left(api_client.NetworkFailure()));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');
    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
    await tester.pumpAndSettle();


    expect(find.text('Error: Could not connect to the network. Check your internet connection'), findsOneWidget);
    expect(find.byType(VillaElevatedButton), findsOneWidget);
  
  });

  testWidgets('Shopping flow: navigate to product detail', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right('fake_token'));
    when(() => mockUsersApi.getUsers()).thenAnswer((_) async => const Right([tUser]));
    when(() => mockProductsApi.getProducts()).thenAnswer((_) async => Right([tProduct1]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');
    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductsScreen), findsOneWidget);
    
    final detailButton = find.descendant(
      of: find.byType(ProductCard),
      matching: find.text('Detail'),
    );
    expect(detailButton, findsOneWidget);
    
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    expect(find.byType(ProductDetailScreen), findsOneWidget);
    expect(find.text('Test Product 1'), findsWidgets);
    expect(find.text('Desc 1'), findsOneWidget);

    await tester.tap(find.text('Add to cart'));
    await tester.pumpAndSettle();

    expect(find.byType(VillaIconButton), findsNWidgets(2));
  });
}
