import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_store_api_client/fake_store_api_client.dart' as api_client;

import 'package:ecommerce_app/main.dart' as app;
import 'package:ecommerce_app/features/auth/presentation/screens/login_screen.dart';
import 'package:ecommerce_app/features/products/presentation/screens/products_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/providers/auth_providers.dart';
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
    registerFallbackValue(const api_client.UserRequest(email: 'any', username: 'any', password: 'any'));
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

  const tToken = 'fake_token';
  const tUser = api_client.User(
      id: 1, email: 'test@test.com', username: 'testuser', password: '',
      name: api_client.Name(firstname: 'John', lastname: 'Doe'),
      address: api_client.Address(city: '', street: '', number: 0, zipcode: '', geolocation: api_client.Geolocation(lat: '', long: '')),
      phone: ''
  );

  testWidgets('Login flow test', (tester) async {
    
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right(tToken));
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

    expect(find.byType(CustomLoading), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);


    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'testuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');

    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login'));
    
    await tester.pumpAndSettle();

    expect(find.byType(ProductsScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('Failed login flow', (tester) async {
    when(() => mockAuthApi.login(any()))
        .thenAnswer((_) async => const Left(api_client.ServerFailure('Invalid credentials')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );
    
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'wrong_user');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'wrong_pass');
    await tester.tap(find.widgetWithText(VillaElevatedButton, 'Login').last);

  
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProductsScreen), findsNothing);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Incorrect username or password'), findsOneWidget);
  });


  testWidgets('Successful logout flow', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right(tToken));
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

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ProductsScreen), findsNothing);

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Session closed correctly.'), findsOneWidget);
  });

  testWidgets('Successful registration flow', (tester) async {
    when(() => mockUsersApi.createUser(any())).thenAnswer((_) async => const Right(2));
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right(tToken));
    when(() => mockUsersApi.getUser(2)).thenAnswer((_) async => Right(tUser.copyWith(id: 2)));
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
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);

    await tester.enterText(find.widgetWithText(VillaTextField, 'Email'), 'new@user.com');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'newuser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'newpassword');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.byType(ProductsScreen), findsOneWidget);
    expect(find.byType(RegisterScreen), findsNothing);
  });

  testWidgets('Failed registration flow', (tester) async {
    when(() => mockUsersApi.createUser(any()))
        .thenAnswer((_) async => const Left(api_client.ServerFailure('User already exists')));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(VillaTextField, 'Email'), 'existing@user.com');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Username'), 'existinguser');
    await tester.enterText(find.widgetWithText(VillaTextField, 'Password'), 'password');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.byType(ProductsScreen), findsNothing);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Registration could not be completed. The user may already exist'), findsOneWidget);
  });

  testWidgets('Session persistence flow', (tester) async {
    when(() => mockAuthApi.login(any())).thenAnswer((_) async => const Right(tToken));
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const app.MyApp(),
      ),
    );
    
    await tester.pumpAndSettle();

    expect(find.byType(ProductsScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });
}
