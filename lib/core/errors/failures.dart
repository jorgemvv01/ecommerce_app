import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = "Server error. Please try again later"});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = "Error accessing local data"});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = "Could not connect to the network. Check your internet connection"});
}

class GenericFailure extends Failure {
  const GenericFailure({super.message = "An unexpected error occurred"});
}