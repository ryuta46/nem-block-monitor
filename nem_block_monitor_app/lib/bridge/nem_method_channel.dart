

import 'package:flutter/services.dart';
import 'package:nem_block_monitor_app/net/nem/model/network_type.dart';

class NemMethodChannel {
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
}