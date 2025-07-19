// Ubicación: integration_test/misc_flow_test.dart

import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:ecommerce_app/features/products/presentation/screens/products_screen.dart';
import 'package:ecommerce_app/features/support/presentation/screens/support_screen.dart';
import 'package:ecommerce_app/main.dart' as app;
import 'package:fake_store_api_client/fake_store_api_client.dart' as api_client;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:villa_design/villa_design.dart';

// Mocks
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

  testWidgets('Navigate to Support Screen flow', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right('fake_token'));
    when(() => mockUsersApi.getUsers()).thenAnswer((_) async => const Right([tUser]));
    when(() => mockProductsApi.getProducts()).thenAnswer((_) async => const Right([]));

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

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Support'));
    await tester.pumpAndSettle();

    expect(find.byType(SupportScreen), findsOneWidget);
    expect(find.text('Get in touch'), findsOneWidget);
    expect(find.text('Email support'), findsOneWidget);
  });
}
