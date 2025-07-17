import 'package:dartz/dartz.dart';
import 'package:ecommerce_app/core/errors/failures.dart';
import 'package:ecommerce_app/core/usecases/usecase.dart';
import 'package:ecommerce_app/features/cart/domain/repositories/cart_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateProductQuantity implements UseCase<void, UpdateQuantityParams> {
  final CartRepository repository;
  UpdateProductQuantity(this.repository);
  @override
  Future<Either<Failure, void>> call(UpdateQuantityParams params) => repository.updateProductQuantity(params.productId, params.newQuantity);
}
class UpdateQuantityParams extends Equatable {
  final int productId;
  final int newQuantity;
  const UpdateQuantityParams({required this.productId, required this.newQuantity});
  @override
  List<Object> get props => [productId, newQuantity];
}