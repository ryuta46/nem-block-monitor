

import 'package:flutter/services.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';

class AppMethodChannel {
  static const platform = const MethodChannel('nemblockmonitorapp.ttechsoft.com/nem');


  static Future<String> calculateAddress(String publicKey, NetworkType networkType) async {
    try {
      return await platform.invokeMethod("calculateAddress", {
        "publicKey": publicKey,
        "networkType": NetworkTypeValues.values[networkType]
      });
    } on PlatformException catch(e) {
      return "";
    }
  }

  static Future<void> toOssLicense() {
    return platform.invokeMethod('toOssLicense', {});
  }
}