
enum ModificationType {
  add,
  delete
}

class ModificationTypeValues {
  static final Map<ModificationType, int> values = {
    ModificationType.add: 1,
    ModificationType.delete: 2,
  };

  static final Map<int, ModificationType> types = values.map((k, v) => MapEntry(v, k));
}
