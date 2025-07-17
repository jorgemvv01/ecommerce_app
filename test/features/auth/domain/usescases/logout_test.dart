import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/auth/domain/usescases/logout_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/auth_repository_mock.dart';

void main() {
  late LogoutUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUser(mockAuthRepository);
  });

  test(
    'should call logout on the repository successfully',
    () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Right(null));

      final result = await usecase(NoParams());

      expect(result, const Right(null));
      verify(() => mockAuthRepository.logout());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return a CacheFailure when logout is unsuccessful',
    () async {
      when(() => mockAuthRepository.logout())
          .thenAnswer((_) async => const Left(CacheFailure(message: 'Could not log out')));

      final result = await usecase(NoParams());

      expect(result, const Left(CacheFailure(message: 'Could not log out')));
      verify(() => mockAuthRepository.logout());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
