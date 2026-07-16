/// Port for generating unique identifiers.
///
/// Lives in the domain-facing core layer as pure Dart so entities and use
/// cases never depend on a concrete id-generation package.
abstract class IdGenerator {
  String newId();
}
