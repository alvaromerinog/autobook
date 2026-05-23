class CreateCarException implements Exception {
  final int statusCode;

  const CreateCarException(this.statusCode);

  @override
  String toString() =>
      'CreateCarException: failed to create car (HTTP $statusCode)';
}
