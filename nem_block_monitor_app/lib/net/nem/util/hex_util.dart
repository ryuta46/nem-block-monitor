import 'dart:convert';

class HexUtil {
  static String hexToUtf8(String hexString) {
    final byteLength = hexString.length / 2;
    List<int> bytes = [];
    for(int i=0; i<byteLength; i++) {
      final byteString = hexString.substring(i*2, i*2 + 2);
      bytes.add(int.parse(byteString, radix: 16));
    }
    return Utf8Decoder().convert(bytes);
  }
}