import 'package:autobook/core/di/dio_provider.dart';
import 'package:autobook/features/maintenances/data/models/maintenance_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'maintenance_remote_datasource.g.dart';

@riverpod
MaintenanceRemoteDataSource maintenanceRemoteDatasource(Ref ref) {
  return MaintenanceRemoteDataSource(ref.watch(dioProvider));
}

@RestApi()
abstract class MaintenanceRemoteDataSource {
  factory MaintenanceRemoteDataSource(Dio dio, {String? baseUrl}) =
      _MaintenanceRemoteDataSource;

  @GET('/cars/{carId}/maintenances')
  Future<MaintenancesListResponse> fetchForCar(@Path('carId') String carId);

  @POST('/cars/{carId}/maintenances')
  Future<void> create(@Path('carId') String carId, @Body() MaintenanceDto dto);

  @GET('/cars/{carId}/maintenances/{id}')
  Future<MaintenanceDto> fetchOne(
    @Path('carId') String carId,
    @Path('id') String id,
  );

  @PUT('/cars/{carId}/maintenances/{id}')
  Future<void> update(
    @Path('carId') String carId,
    @Path('id') String id,
    @Body() MaintenanceDto dto,
  );

  @DELETE('/cars/{carId}/maintenances/{id}')
  Future<void> delete(@Path('carId') String carId, @Path('id') String id);
}
