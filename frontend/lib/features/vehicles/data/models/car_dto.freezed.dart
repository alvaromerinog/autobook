// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'car_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CarDto {

 String get id; String get brand; String get model; int get year; String get licensePlate; String? get color; int? get mileage;
/// Create a copy of CarDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarDtoCopyWith<CarDto> get copyWith => _$CarDtoCopyWithImpl<CarDto>(this as CarDto, _$identity);

  /// Serializes this CarDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarDto&&(identical(other.id, id) || other.id == id)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.color, color) || other.color == color)&&(identical(other.mileage, mileage) || other.mileage == mileage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,brand,model,year,licensePlate,color,mileage);

@override
String toString() {
  return 'CarDto(id: $id, brand: $brand, model: $model, year: $year, licensePlate: $licensePlate, color: $color, mileage: $mileage)';
}


}

/// @nodoc
abstract mixin class $CarDtoCopyWith<$Res>  {
  factory $CarDtoCopyWith(CarDto value, $Res Function(CarDto) _then) = _$CarDtoCopyWithImpl;
@useResult
$Res call({
 String id, String brand, String model, int year, String licensePlate, String? color, int? mileage
});




}
/// @nodoc
class _$CarDtoCopyWithImpl<$Res>
    implements $CarDtoCopyWith<$Res> {
  _$CarDtoCopyWithImpl(this._self, this._then);

  final CarDto _self;
  final $Res Function(CarDto) _then;

/// Create a copy of CarDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? brand = null,Object? model = null,Object? year = null,Object? licensePlate = null,Object? color = freezed,Object? mileage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,mileage: freezed == mileage ? _self.mileage : mileage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CarDto].
extension CarDtoPatterns on CarDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarDto value)  $default,){
final _that = this;
switch (_that) {
case _CarDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarDto value)?  $default,){
final _that = this;
switch (_that) {
case _CarDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String brand,  String model,  int year,  String licensePlate,  String? color,  int? mileage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarDto() when $default != null:
return $default(_that.id,_that.brand,_that.model,_that.year,_that.licensePlate,_that.color,_that.mileage);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String brand,  String model,  int year,  String licensePlate,  String? color,  int? mileage)  $default,) {final _that = this;
switch (_that) {
case _CarDto():
return $default(_that.id,_that.brand,_that.model,_that.year,_that.licensePlate,_that.color,_that.mileage);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String brand,  String model,  int year,  String licensePlate,  String? color,  int? mileage)?  $default,) {final _that = this;
switch (_that) {
case _CarDto() when $default != null:
return $default(_that.id,_that.brand,_that.model,_that.year,_that.licensePlate,_that.color,_that.mileage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarDto extends CarDto {
  const _CarDto({required this.id, required this.brand, required this.model, required this.year, required this.licensePlate, this.color, this.mileage}): super._();
  factory _CarDto.fromJson(Map<String, dynamic> json) => _$CarDtoFromJson(json);

@override final  String id;
@override final  String brand;
@override final  String model;
@override final  int year;
@override final  String licensePlate;
@override final  String? color;
@override final  int? mileage;

/// Create a copy of CarDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarDtoCopyWith<_CarDto> get copyWith => __$CarDtoCopyWithImpl<_CarDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarDto&&(identical(other.id, id) || other.id == id)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.model, model) || other.model == model)&&(identical(other.year, year) || other.year == year)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate)&&(identical(other.color, color) || other.color == color)&&(identical(other.mileage, mileage) || other.mileage == mileage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,brand,model,year,licensePlate,color,mileage);

@override
String toString() {
  return 'CarDto(id: $id, brand: $brand, model: $model, year: $year, licensePlate: $licensePlate, color: $color, mileage: $mileage)';
}


}

/// @nodoc
abstract mixin class _$CarDtoCopyWith<$Res> implements $CarDtoCopyWith<$Res> {
  factory _$CarDtoCopyWith(_CarDto value, $Res Function(_CarDto) _then) = __$CarDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String brand, String model, int year, String licensePlate, String? color, int? mileage
});




}
/// @nodoc
class __$CarDtoCopyWithImpl<$Res>
    implements _$CarDtoCopyWith<$Res> {
  __$CarDtoCopyWithImpl(this._self, this._then);

  final _CarDto _self;
  final $Res Function(_CarDto) _then;

/// Create a copy of CarDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? brand = null,Object? model = null,Object? year = null,Object? licensePlate = null,Object? color = freezed,Object? mileage = freezed,}) {
  return _then(_CarDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,brand: null == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,licensePlate: null == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,mileage: freezed == mileage ? _self.mileage : mileage // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$CarsListResponse {

 List<CarDto> get cars;
/// Create a copy of CarsListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CarsListResponseCopyWith<CarsListResponse> get copyWith => _$CarsListResponseCopyWithImpl<CarsListResponse>(this as CarsListResponse, _$identity);

  /// Serializes this CarsListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CarsListResponse&&const DeepCollectionEquality().equals(other.cars, cars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(cars));

@override
String toString() {
  return 'CarsListResponse(cars: $cars)';
}


}

/// @nodoc
abstract mixin class $CarsListResponseCopyWith<$Res>  {
  factory $CarsListResponseCopyWith(CarsListResponse value, $Res Function(CarsListResponse) _then) = _$CarsListResponseCopyWithImpl;
@useResult
$Res call({
 List<CarDto> cars
});




}
/// @nodoc
class _$CarsListResponseCopyWithImpl<$Res>
    implements $CarsListResponseCopyWith<$Res> {
  _$CarsListResponseCopyWithImpl(this._self, this._then);

  final CarsListResponse _self;
  final $Res Function(CarsListResponse) _then;

/// Create a copy of CarsListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cars = null,}) {
  return _then(_self.copyWith(
cars: null == cars ? _self.cars : cars // ignore: cast_nullable_to_non_nullable
as List<CarDto>,
  ));
}

}


/// Adds pattern-matching-related methods to [CarsListResponse].
extension CarsListResponsePatterns on CarsListResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CarsListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CarsListResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CarsListResponse value)  $default,){
final _that = this;
switch (_that) {
case _CarsListResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CarsListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _CarsListResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CarDto> cars)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CarsListResponse() when $default != null:
return $default(_that.cars);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CarDto> cars)  $default,) {final _that = this;
switch (_that) {
case _CarsListResponse():
return $default(_that.cars);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CarDto> cars)?  $default,) {final _that = this;
switch (_that) {
case _CarsListResponse() when $default != null:
return $default(_that.cars);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CarsListResponse implements CarsListResponse {
  const _CarsListResponse({required final  List<CarDto> cars}): _cars = cars;
  factory _CarsListResponse.fromJson(Map<String, dynamic> json) => _$CarsListResponseFromJson(json);

 final  List<CarDto> _cars;
@override List<CarDto> get cars {
  if (_cars is EqualUnmodifiableListView) return _cars;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_cars);
}


/// Create a copy of CarsListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CarsListResponseCopyWith<_CarsListResponse> get copyWith => __$CarsListResponseCopyWithImpl<_CarsListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CarsListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CarsListResponse&&const DeepCollectionEquality().equals(other._cars, _cars));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_cars));

@override
String toString() {
  return 'CarsListResponse(cars: $cars)';
}


}

/// @nodoc
abstract mixin class _$CarsListResponseCopyWith<$Res> implements $CarsListResponseCopyWith<$Res> {
  factory _$CarsListResponseCopyWith(_CarsListResponse value, $Res Function(_CarsListResponse) _then) = __$CarsListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<CarDto> cars
});




}
/// @nodoc
class __$CarsListResponseCopyWithImpl<$Res>
    implements _$CarsListResponseCopyWith<$Res> {
  __$CarsListResponseCopyWithImpl(this._self, this._then);

  final _CarsListResponse _self;
  final $Res Function(_CarsListResponse) _then;

/// Create a copy of CarsListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cars = null,}) {
  return _then(_CarsListResponse(
cars: null == cars ? _self._cars : cars // ignore: cast_nullable_to_non_nullable
as List<CarDto>,
  ));
}


}

// dart format on
