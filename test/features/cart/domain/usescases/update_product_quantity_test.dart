import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/features/cart/domain/usescases/update_product_quantity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/cart_repository_mock.dart';

void main() {
  late UpdateProductQuantity usecase;
  late MockCartRepository mockCartRepository;

  setUpAll(() {
    registerFallbackValue(const UpdateQuantityParams(productId: 0, newQuantity: 0));
  });

  setUp(() {
    mockCartRepository = MockCartRepository();
    usecase = UpdateProductQuantity(mockCartRepository);
  });

  const tUpdateParams = UpdateQuantityParams(productId: 1, newQuantity: 3);

  test(
    'should call updateProductQuantity on the repository',
    () async {
      when(() => mockCartRepository.updateProductQuantity(any(), any()))
          .thenAnswer((_) async => const Right(null));

      final result = await usecase(tUpdateParams);

      expect(result, const Right(null));
      verify(() => mockCartRepository.updateProductQuantity(tUpdateParams.productId, tUpdateParams.newQuantity));
      verifyNoMoreInteractions(mockCartRepository);
    },
  );

  test(
    'should return a CacheFailure when the call to repository is unsuccessful',
    () async {
      when(() => mockCartRepository.updateProductQuantity(any(), any()))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'Could not update quantity')));

      final result = await usecase(tUpdateParams);

      expect(result, const Left(CacheFailure(message: 'Could not update quantity')));
      verify(() => mockCartRepository.updateProductQuantity(tUpdateParams.productId, tUpdateParams.newQuantity));
      verifyNoMoreInteractions(mockCartRepository);
    },
  );
}
