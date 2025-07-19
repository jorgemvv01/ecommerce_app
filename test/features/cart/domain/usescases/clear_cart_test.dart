import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/clear_cart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/cart_repository_mock.dart';

void main() {
  late ClearCart usecase;
  late MockCartRepository mockCartRepository;

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = ClearCart(mockCartRepository);
  });

  test(
    'should call clearCart on the repository',
    () async {
      when(() => mockCartRepository.clearCart())
          .thenAnswer((_) async => const Right(null));

      final result = await usecase(NoParams());

      expect(result, const Right(null));
      verify(() => mockCartRepository.clearCart());
      verifyNoMoreInteractions(mockCartRepository);
    },
  );

  test(
    'should return a CacheFailure when the call to repository is unsuccessful',
    () async {
      when(() => mockCartRepository.clearCart())
          .thenAnswer((_) async => const Left(CacheFailure(message: 'Could not clear cart')));

      final result = await usecase(NoParams());

      expect(result, const Left(CacheFailure(message: 'Could not clear cart')));
      verify(() => mockCartRepository.clearCart());
      verifyNoMoreInteractions(mockCartRepository);
    },
  );
}
