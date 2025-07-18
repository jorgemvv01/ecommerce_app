import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:ecommerce_app/features/auth/data/gateways/auth_local_gateway.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthLocalGatewayImpl gateway;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockSecureStorage = MockFlutterSecureStorage();
    gateway = AuthLocalGatewayImpl(secureStorage: mockSecureStorage);
  });

  const tUserModel = UserModel(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    firstName: 'John',
    lastName: 'Doe',
    password: 'password'
  );
  const tToken = 'test_token';
  final tUserJson = json.encode(tUserModel.toJson());

  group('getSession', () {
    test(
      'should return user and token when they are present in storage',
      () async {
        when(() => mockSecureStorage.read(key: any(named: 'key')))
            .thenAnswer((invocation) async {
          final key = invocation.namedArguments[#key];
          if (key == 'SECURE_USER') return tUserJson;
          if (key == 'SECURE_TOKEN') return tToken;
          return null;
        });

        final result = await gateway.getSession();

        expect(result, isNotNull);
        expect(result!.$1, tUserModel);
        expect(result.$2, tToken);
        verify(() => mockSecureStorage.read(key: 'SECURE_USER'));
        verify(() => mockSecureStorage.read(key: 'SECURE_TOKEN'));
      },
    );

    test(
      'should return null when there is no session in storage',
      () async {
        when(() => mockSecureStorage.read(key: any(named: 'key')))
            .thenAnswer((_) async => null);

        final result = await gateway.getSession();

        expect(result, isNull);
      },
    );
  });

  group('saveSession', () {
    test(
      'should call FlutterSecureStorage to save the user and token',
      () async {
        when(() => mockSecureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
            .thenAnswer((_) async => Future.value());

        await gateway.saveSession(tUserModel, tToken);

        verify(() => mockSecureStorage.write(key: 'SECURE_USER', value: tUserJson));
        verify(() => mockSecureStorage.write(key: 'SECURE_TOKEN', value: tToken));
        verifyNoMoreInteractions(mockSecureStorage);
      },
    );
  });

  group('clearSession', () {
    test(
      'should call FlutterSecureStorage to delete the user and token',
      () async {
        when(() => mockSecureStorage.delete(key: any(named: 'key')))
            .thenAnswer((_) async => Future.value());

        await gateway.clearSession();

        verify(() => mockSecureStorage.delete(key: 'SECURE_USER'));
        verify(() => mockSecureStorage.delete(key: 'SECURE_TOKEN'));
        verifyNoMoreInteractions(mockSecureStorage);
      },
    );
  });
}
