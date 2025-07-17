import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/login_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_repository_mock.dart';

void main() {
  late LoginUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUser(mockAuthRepository);
  });

  const tUser = User(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    firstName: 'John',
    lastName: 'Doe',
    password: 'password'
  );
  const tLoginParams = LoginParams(username: 'testuser', password: 'password');

  test(
    'should get user from the repository when login is successful',
    () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Right(tUser));

      final result = await usecase(tLoginParams);

      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.login(tLoginParams.username, tLoginParams.password));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return a ServerFailure when login is unsuccessful',
    () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Invalid credentials')));

      final result = await usecase(tLoginParams);

      expect(result, const Left(ServerFailure(message: 'Invalid credentials')));
      verify(() => mockAuthRepository.login(tLoginParams.username, tLoginParams.password));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
