import 'package:autobook/core/id/id_generator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'uuid_id_generator.g.dart';

class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  @override
  String newId() => const Uuid().v4();
}

@Riverpod(keepAlive: true)
IdGenerator idGenerator(Ref ref) => const UuidIdGenerator();
