part of 'failures.dart';

class ServerFailure extends Failure {
  const ServerFailure(this.statusCode);

  final int statusCode;
}
