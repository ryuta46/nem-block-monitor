
enum NetworkType {
  mainNet,
  testNet
}

class NetworkTypeValues {
  static final Map<NetworkType, int> values = {
    NetworkType.mainNet: 0x68,
    NetworkType.testNet: 0x98,
  };

  static final Map<int, NetworkType> types = values.map((k, v) => MapEntry(v, k));
}
