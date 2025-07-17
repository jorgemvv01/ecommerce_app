import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/register_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_repository_mock.dart';

void main() {
  late RegisterUser usecase;
  late MockAuthRepository mockAuthRepository;
  
  setUpAll(() {
    registerFallbackValue(const RegisterParams(
      email: 'any_email',
      username: 'any_username',
      password: 'any_password',
    ));
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUser(mockAuthRepository);
  });

  const tUser = User(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    firstName: 'John',
    lastName: 'Doe',
    password: 'password'
  );
  const tRegisterParams = RegisterParams(
    email: 'test@test.com',
    username: 'testuser',
    password: 'password',
  );

  test(
    'should get user from the repository when registration is successful',
    () async {
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Right(tUser));

      final result = await usecase(tRegisterParams);

      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.register(tRegisterParams));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return a ServerFailure when registration is unsuccessful',
    () async {
      when(() => mockAuthRepository.register(any()))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Could not register user')));

      final result = await usecase(tRegisterParams);

      expect(result, const Left(ServerFailure(message: 'Could not register user')));
      verify(() => mockAuthRepository.register(tRegisterParams));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
