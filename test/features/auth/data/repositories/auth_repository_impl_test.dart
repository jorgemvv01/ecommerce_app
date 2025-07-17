

import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/exceptions.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/data/gateways/auth_local_gateway.dart';
import 'package:ecommerce_app/features/auth/data/gateways/auth_remote_gateway.dart';
import 'package:ecommerce_app/features/auth/data/models/user_model.dart';
import 'package:ecommerce_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockAuthRemoteGateway extends Mock implements AuthRemoteGateway {}
class MockAuthLocalGateway extends Mock implements AuthLocalGateway {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteGateway mockRemoteGateway;
  late MockAuthLocalGateway mockLocalGateway;

  setUpAll(() {
    registerFallbackValue(const RegisterParams(
      email: 'any_email',
      username: 'any_username',
      password: 'any_password',
    ));
    registerFallbackValue(const UserModel(
      id: 1,
      email: 'any_email',
      username: 'any_username',
      firstName: 'any_firstName',
      lastName: 'any_lastName',
      password: 'any_password'
    ));
  });

  setUp(() {
    mockRemoteGateway = MockAuthRemoteGateway();
    mockLocalGateway = MockAuthLocalGateway();
    repository = AuthRepositoryImpl(
      remoteGateway: mockRemoteGateway,
      localGateway: mockLocalGateway,
    );
  });

  const tUserModel = UserModel(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    firstName: 'John',
    lastName: 'Doe',
    password: 'password'
  );
  const User tUser = tUserModel;
  const tUsername = 'testuser';
  const tPassword = 'password';
  const tToken = 'test_token';
  const tRegisterParams = RegisterParams(
    email: 'test@test.com',
    username: 'testuser',
    password: 'password',
  );

  group('login', () {
    test(
      'should return user and save session when login is successful',
      () async {
        when(() => mockRemoteGateway.login(any(), any()))
            .thenAnswer((_) async => tToken);
        when(() => mockRemoteGateway.getUserByUsername(any()))
            .thenAnswer((_) async => tUserModel);
        when(() => mockLocalGateway.saveSession(any(), any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.login(tUsername, tPassword);

        expect(result, const Right(tUser));
        verify(() => mockRemoteGateway.login(tUsername, tPassword));
        verify(() => mockRemoteGateway.getUserByUsername(tUsername));
        verify(() => mockLocalGateway.saveSession(tUserModel, tToken));
        verifyNoMoreInteractions(mockRemoteGateway);
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );

    test(
      'should return ServerFailure when remote gateway throws ServerException',
      () async {
        when(() => mockRemoteGateway.login(any(), any()))
            .thenThrow(ServerException());

        final result = await repository.login(tUsername, tPassword);

        expect(result, isA<Left<Failure, User>>());
        verify(() => mockRemoteGateway.login(tUsername, tPassword));
        verifyNoMoreInteractions(mockRemoteGateway);
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });

  group('register', () {
    test(
      'should register, login, and save session successfully',
      () async {
        when(() => mockRemoteGateway.register(any()))
            .thenAnswer((_) async => 1);
        when(() => mockRemoteGateway.getUserById(any()))
            .thenAnswer((_) async => tUserModel);
        when(() => mockRemoteGateway.login(any(), any()))
            .thenAnswer((_) async => tToken);
        when(() => mockLocalGateway.saveSession(any(), any()))
            .thenAnswer((_) async => Future.value());

        final result = await repository.register(tRegisterParams);

        expect(result, const Right(tUser));
        verify(() => mockRemoteGateway.register(tRegisterParams));
        verify(() => mockRemoteGateway.getUserById(1));
        verify(() => mockRemoteGateway.login(tRegisterParams.username, tRegisterParams.password));
        verify(() => mockLocalGateway.saveSession(tUserModel, tToken));
        verifyNoMoreInteractions(mockRemoteGateway);
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );

    test(
      'should return ServerFailure when registration fails',
      () async {
        when(() => mockRemoteGateway.register(any()))
            .thenThrow(ServerException());

        final result = await repository.register(tRegisterParams);

        expect(result, isA<Left<Failure, User>>());
        verify(() => mockRemoteGateway.register(tRegisterParams));
        verifyNoMoreInteractions(mockRemoteGateway);
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });

  group('checkAuthStatus', () {
    test(
      'should return user when local gateway has a session',
      () async {
        when(() => mockLocalGateway.getSession())
            .thenAnswer((_) async => (tUserModel, tToken));

        final result = await repository.checkAuthStatus();

        expect(result, const Right(tUser));
        verify(() => mockLocalGateway.getSession());
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );

    test(
      'should return CacheFailure when local gateway has no session',
      () async {
        when(() => mockLocalGateway.getSession())
            .thenAnswer((_) async => null);

        final result = await repository.checkAuthStatus();

        expect(result, isA<Left<Failure, User>>());
        verify(() => mockLocalGateway.getSession());
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });

  group('logout', () {
    test(
      'should call clearSession on local gateway and return success',
      () async {
        when(() => mockLocalGateway.clearSession())
            .thenAnswer((_) async => Future.value());

        final result = await repository.logout();

        expect(result, const Right(null));
        verify(() => mockLocalGateway.clearSession());
        verifyNoMoreInteractions(mockLocalGateway);
      },
    );
  });
}
