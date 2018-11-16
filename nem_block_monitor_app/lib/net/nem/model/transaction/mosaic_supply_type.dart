

enum MosaicSupplyType {
  increase,
  decrease
}

class MosaicSupplyTypeValues {
  static final Map<MosaicSupplyType, int> values = {
    MosaicSupplyType.increase: 1,
    MosaicSupplyType.decrease: 2,
  };

  static final Map<int, MosaicSupplyType> types = values.map((k, v) => MapEntry(v, k));
}
