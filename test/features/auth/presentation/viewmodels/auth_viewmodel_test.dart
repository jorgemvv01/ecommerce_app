import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/check_auth_status.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/login_user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/logout_user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUser extends Mock implements LoginUser {}
class MockRegisterUser extends Mock implements RegisterUser {}
class MockLogoutUser extends Mock implements LogoutUser {}
class MockCheckAuthStatus extends Mock implements CheckAuthStatus {}

void main() {
  late AuthViewModel viewModel;
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockLogoutUser mockLogoutUser;
  late MockCheckAuthStatus mockCheckAuthStatus;

  setUpAll(() {
    registerFallbackValue(const LoginParams(username: 'any_username', password: 'any_password'));
    registerFallbackValue(const RegisterParams(email: 'any_email', username: 'any_username', password: 'any_password'));
    registerFallbackValue(NoParams());
  });

  const tUser = User(id: 1, email: 'test@test.com', username: 'testuser', firstName: 'John', lastName: 'Doe', password: 'password');

  group('AuthViewModel Initialization (checkAuthStatus)', () {
    test('should be in unauthenticated state if checkAuthStatus fails', () async {
      mockLoginUser = MockLoginUser();
      mockRegisterUser = MockRegisterUser();
      mockLogoutUser = MockLogoutUser();
      mockCheckAuthStatus = MockCheckAuthStatus();
      
      when(() => mockCheckAuthStatus(any())).thenAnswer((_) async => const Left(CacheFailure(message: 'No session')));
      
      viewModel = AuthViewModel(mockLoginUser, mockLogoutUser, mockCheckAuthStatus, mockRegisterUser);
      
      await untilCalled(() => mockCheckAuthStatus(any()));

      expect(viewModel.state.status, AuthStatus.unauthenticated);
    });

    test('should be in authenticated state if checkAuthStatus succeeds', () async {
      mockLoginUser = MockLoginUser();
      mockRegisterUser = MockRegisterUser();
      mockLogoutUser = MockLogoutUser();
      mockCheckAuthStatus = MockCheckAuthStatus();
      
      when(() => mockCheckAuthStatus(any())).thenAnswer((_) async => const Right(tUser));

      viewModel = AuthViewModel(mockLoginUser, mockLogoutUser, mockCheckAuthStatus, mockRegisterUser);

      await untilCalled(() => mockCheckAuthStatus(any()));

      expect(viewModel.state.status, AuthStatus.authenticated);
      expect(viewModel.state.user, tUser);
    });
  });

  group('Login', () {
    setUp(() {
      mockLoginUser = MockLoginUser();
      mockRegisterUser = MockRegisterUser();
      mockLogoutUser = MockLogoutUser();
      mockCheckAuthStatus = MockCheckAuthStatus();
      when(() => mockCheckAuthStatus(any())).thenAnswer((_) async => const Left(CacheFailure(message: 'No session')));
      viewModel = AuthViewModel(mockLoginUser, mockLogoutUser, mockCheckAuthStatus, mockRegisterUser);
    });

    test('should emit [loading, authenticated] states when login is successful', () async {
      when(() => mockLoginUser(any())).thenAnswer((_) async => const Right(tUser));

      final future = viewModel.login('testuser', 'password');

      expect(viewModel.state.status, AuthStatus.loading);

      await future;

      expect(viewModel.state.status, AuthStatus.authenticated);
      expect(viewModel.state.user, tUser);
      verify(() => mockLoginUser(const LoginParams(username: 'testuser', password: 'password'))).called(1);
    });

    test('should emit [loading, unauthenticated] states when login fails', () async {
      when(() => mockLoginUser(any())).thenAnswer((_) async => const Left(ServerFailure(message: 'Error')));

      final future = viewModel.login('testuser', 'password');

      expect(viewModel.state.status, AuthStatus.loading);

      await future;

      expect(viewModel.state.status, AuthStatus.unauthenticated);
      expect(viewModel.state.errorMessage, 'Error');
    });
  });

  group('Register', () {
    setUp(() {
      mockLoginUser = MockLoginUser();
      mockRegisterUser = MockRegisterUser();
      mockLogoutUser = MockLogoutUser();
      mockCheckAuthStatus = MockCheckAuthStatus();
      when(() => mockCheckAuthStatus(any())).thenAnswer((_) async => const Left(CacheFailure(message: 'No session')));
      viewModel = AuthViewModel(mockLoginUser, mockLogoutUser, mockCheckAuthStatus, mockRegisterUser);
    });

    test('should emit [loading, authenticated] states when registration is successful', () async {
      when(() => mockRegisterUser(any())).thenAnswer((_) async => const Right(tUser));

      final future = viewModel.register(email: 'test@test.com', username: 'testuser', password: 'password');

      expect(viewModel.state.status, AuthStatus.loading);

      await future;

      expect(viewModel.state.status, AuthStatus.authenticated);
      expect(viewModel.state.user, tUser);
      verify(() => mockRegisterUser(const RegisterParams(email: 'test@test.com', username: 'testuser', password: 'password'))).called(1);
    });

    test('should emit [loading, error] states when use case fails', () async {
      when(() => mockRegisterUser(any())).thenAnswer((_) async => const Left(ServerFailure(message: 'User already exists')));

      final future = viewModel.register(email: 'test@test.com', username: 'testuser', password: 'password');
      expect(viewModel.state.status, AuthStatus.loading);
      await future;

      expect(viewModel.state.status, AuthStatus.error);
      expect(viewModel.state.errorMessage, 'User already exists');
    });

    test('should emit error state and not call use case when validation fails', () async {
      // Act: Llamamos al método. La transición de estado es síncrona.
      await viewModel.register(email: '', username: 'testuser', password: 'password');

      // Assert: Verificamos el estado final directamente.
      expect(viewModel.state.status, AuthStatus.error);
      expect(viewModel.state.errorMessage, contains('Email'));
      verifyNever(() => mockRegisterUser(any()));
    });
  });
  
  group('Logout', () {
    setUp(() {
      mockLoginUser = MockLoginUser();
      mockRegisterUser = MockRegisterUser();
      mockLogoutUser = MockLogoutUser();
      mockCheckAuthStatus = MockCheckAuthStatus();
      when(() => mockCheckAuthStatus(any())).thenAnswer((_) async => const Right(tUser));
      viewModel = AuthViewModel(mockLoginUser, mockLogoutUser, mockCheckAuthStatus, mockRegisterUser);
    });

    test('should emit [unauthenticated] state when logout is successful', () async {
      when(() => mockLogoutUser(any())).thenAnswer((_) async => const Right(null));

      await viewModel.logout();

      expect(viewModel.state.status, AuthStatus.unauthenticated);
      expect(viewModel.state.user, isNull);
      verify(() => mockLogoutUser(NoParams())).called(1);
    });
  });
}
