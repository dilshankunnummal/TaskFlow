import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String generate();
}

final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator();

  static const Uuid _uuid = Uuid();

  @override
  String generate() => _uuid.v4();
}
