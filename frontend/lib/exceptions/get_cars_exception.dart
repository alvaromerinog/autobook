class GetCarsException implements Exception {
  final int statusCode;

  const GetCarsException(this.statusCode);

  @override
  String toString() =>
      'GetCarsException: failed to fetch cars (HTTP $statusCode)';
}
