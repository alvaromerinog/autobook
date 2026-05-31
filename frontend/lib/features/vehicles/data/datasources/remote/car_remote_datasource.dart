import 'package:autobook/core/di/dio_provider.dart';
import 'package:autobook/features/vehicles/data/models/car_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_remote_datasource.g.dart';

@riverpod
CarRemoteDataSource carRemoteDatasource(Ref ref) {
  return CarRemoteDataSource(ref.watch(dioProvider));
}

@RestApi()
abstract class CarRemoteDataSource {
  factory CarRemoteDataSource(Dio dio, {String? baseUrl}) =
      _CarRemoteDataSource;

  @GET('/cars')
  Future<CarsListResponse> fetchAll();

  @POST('/cars')
  Future<void> create(@Body() CarDto dto);
}
