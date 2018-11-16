

enum ImportanceMode {
  activate,
  deactivate
}

class ImportanceModeValues {
  static final Map<ImportanceMode, int> values = {
    ImportanceMode.activate: 1,
    ImportanceMode.deactivate: 2,
  };

  static final Map<int, ImportanceMode> types = values.map((k, v) => MapEntry(v, k));

}