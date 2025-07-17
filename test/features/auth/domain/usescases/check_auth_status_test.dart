import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/entities/user.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/check_auth_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_repository_mock.dart';

void main() {
  late CheckAuthStatus usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = CheckAuthStatus(mockAuthRepository);
  });

  const tUser = User(
    id: 1,
    email: 'test@test.com',
    username: 'testuser',
    firstName: 'John',
    lastName: 'Doe',
    password: 'password'
  );

  test(
    'should get user from the repository when there is an active session',
    () async {
      when(() => mockAuthRepository.checkAuthStatus())
          .thenAnswer((_) async => const Right(tUser));

      final result = await usecase(NoParams());

      expect(result, const Right(tUser));
      verify(() => mockAuthRepository.checkAuthStatus());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return CacheFailure when there is no active session',
    () async {
      when(() => mockAuthRepository.checkAuthStatus())
          .thenAnswer((_) async => const Left(CacheFailure(message: 'No session')));

      final result = await usecase(NoParams());

      expect(result, const Left(CacheFailure(message: 'No session')));
      verify(() => mockAuthRepository.checkAuthStatus());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
