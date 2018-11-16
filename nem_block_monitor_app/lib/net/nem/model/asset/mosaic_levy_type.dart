
enum MosaicLevyType {
  absolute,
  relative
}

class MosaicLevyTypeValues {
  static final Map<MosaicLevyType, int> values = {
    MosaicLevyType.absolute: 1,
    MosaicLevyType.relative: 2
  };

  static final Map<int, MosaicLevyType> types = values.map((k, v) => MapEntry(v, k));
}