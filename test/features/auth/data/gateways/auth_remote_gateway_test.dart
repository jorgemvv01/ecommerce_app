import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/features/auth/data/gateways/auth_remote_gateway.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:fake_store_api_client/fake_store_api_client.dart' as api_client;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFakeStoreApiClient extends Mock implements api_client.FakeStoreApiClient {}
class MockAuthApi extends Mock implements api_client.AuthApiHandler {}
class MockUsersApi extends Mock implements api_client.UserApiHandler {}

void main() {
  late AuthRemoteGatewayImpl gateway;
  late MockFakeStoreApiClient mockApiClient;
  late MockAuthApi mockAuthApi;
  late MockUsersApi mockUsersApi;

  setUpAll(() {
    registerFallbackValue(const api_client.UserRequest(
      email: 'any_email',
      username: 'any_username',
      password: 'any_password',
    ));
    
    registerFallbackValue(const api_client.LoginRequest(
      username: 'any_username',
      password: 'any_password',
    ));
  });

  setUp(() {
    mockApiClient = MockFakeStoreApiClient();
    mockAuthApi = MockAuthApi();
    mockUsersApi = MockUsersApi();
    gateway = AuthRemoteGatewayImpl(apiClient: mockApiClient);
    when(() => mockApiClient.auth).thenReturn(mockAuthApi);
    when(() => mockApiClient.users).thenReturn(mockUsersApi);
  });

  const tUsername = 'testuser';
  const tPassword = 'password';
  const tToken = 'test_token';
  const tRegisterParams = RegisterParams(
    email: 'test@test.com',
    username: 'testuser',
    password: 'password',
  );
  const tApiClientUser = api_client.User(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    password: '',
    name: api_client.Name(firstname: 'John', lastname: 'Doe'),
    address: api_client.Address(
        city: '', street: '', number: 0, zipcode: '', geolocation: api_client.Geolocation(lat: '', long: '')),
    phone: '',
  );
  const tUserModel = UserModel(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    firstName: 'John',
    lastName: 'Doe',
  );

  group('login', () {
    test(
      'should return token when the call to api client is successful',
      () async {
        when(() => mockAuthApi.login(any()))
          .thenAnswer((_) async => const Right(tToken));

        final result = await gateway.login(tUsername, tPassword);

        expect(result, equals(tToken));
        
        verify(() => mockAuthApi.login(const api_client.LoginRequest(username: tUsername, password: tPassword)));
        verifyNoMoreInteractions(mockAuthApi);
      },
    );

    test(
      'should throw a ServerException when the call to api client is unsuccessful',
      () async {
        when(() => mockAuthApi.login(any()))
          .thenAnswer((_) async => const Left(api_client.ServerFailure('API error')));

        final call = gateway.login;

        expect(() => call(tUsername, tPassword), throwsA(isA<ServerException>()));
      },
    );
  });

  group('register', () {
    const tUserRequest = api_client.UserRequest(
      email: tRegisterParams.email,
      username: tRegisterParams.username,
      password: tRegisterParams.password,
    );

    test(
      'should return new user ID when registration is successful',
      () async {
        when(() => mockUsersApi.createUser(tUserRequest))
            .thenAnswer((_) async => const Right(1));

        final result = await gateway.register(tRegisterParams);

        expect(result, equals(1));
        verify(() => mockUsersApi.createUser(tUserRequest));
        verifyNoMoreInteractions(mockUsersApi);
      },
    );

    test(
      'should throw a ServerException when registration fails',
      () async {
        when(() => mockUsersApi.createUser(tUserRequest))
            .thenAnswer((_) async => const Left(api_client.ServerFailure('API Error')));

        final call = gateway.register;

        expect(() => call(tRegisterParams), throwsA(isA<ServerException>()));
      },
    );
  });

  group('getUserById', () {
    test(
      'should return UserModel when the call to api client is successful',
      () async {
        when(() => mockUsersApi.getUser(any()))
            .thenAnswer((_) async => const Right(tApiClientUser));

        final result = await gateway.getUserById(1);

        expect(result, equals(tUserModel));
      },
    );

    test(
      'should throw a ServerException when the call to api client is unsuccessful',
      () async {
        when(() => mockUsersApi.getUser(any()))
            .thenAnswer((_) async => const Left(api_client.ServerFailure('API Error')));

        final call = gateway.getUserById;

        expect(() => call(1), throwsA(isA<ServerException>()));
      },
    );
  });
}
