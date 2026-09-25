typedef JsonMap = Map<String, dynamic>;

/// Typed accessors that fail with a descriptive [FormatException]
/// instead of an opaque cast error when bundled JSON is malformed.
extension JsonReader on JsonMap {
  String requireString(String key) {
    final value = this[key];
    if (value is String && value.isNotEmpty) return value;
    throw FormatException('Expected non-empty string for "$key"', value);
  }

  int requireInt(String key) {
    final value = this[key];
    if (value is int) return value;
    throw FormatException('Expected integer for "$key"', value);
  }

  JsonMap requireMap(String key) {
    final value = this[key];
    if (value is JsonMap) return value;
    throw FormatException('Expected object for "$key"', value);
  }

  List<JsonMap> requireMapList(String key) {
    final value = this[key];
    if (value is List && value.every((item) => item is JsonMap)) {
      return value.cast<JsonMap>();
    }
    throw FormatException('Expected list of objects for "$key"', value);
  }
}
