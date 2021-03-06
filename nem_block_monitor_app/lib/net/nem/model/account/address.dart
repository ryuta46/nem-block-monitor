
import 'package:nem_block_monitor_app/bridge/app_method_channel.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';

class Address {
  final String plain;
  final NetworkType networkType;

  static NetworkType _checkNetworkType(String address) {
    if (address.startsWith("T")) {
      return NetworkType.testNet;
    } else if (address.startsWith("N")) {
      return NetworkType.mainNet;
    } else {
      throw ArgumentError("Network type of the address $address is unknown");
    }
  }

  Address(String address):
        plain = address.replaceAll("-", ""),
        networkType = Address._checkNetworkType(address);

  static Future<Address> fromPublicKey(String publicKey, NetworkType networkType) async {
    final address = await AppMethodChannel.calculateAddress(publicKey, networkType);
    return Address(address);
  }

  String get pretty {
    final regExp = RegExp(".{1,6}");
    return regExp.allMatches(plain).map((match) => match.group(0)).join("-");
  }
}