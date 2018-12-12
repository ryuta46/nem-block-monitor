

import 'package:decimal/decimal.dart';

class AssetUtil {
  static getAmount(int quantity, int divisibility) {
    var div = Decimal.fromInt(1);
    for (var i = 0; i < divisibility; i++) {
      div = div * Decimal.fromInt(10);
    }
    return Decimal.fromInt(quantity) / div;
  }
}