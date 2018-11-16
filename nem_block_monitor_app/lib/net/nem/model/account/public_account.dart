

import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';

/// The public account structure contains account's address and public key.
class PublicAccount {

  /// Account address.
  final Address address;
  /// Account public key.
  final String publicKey;

  PublicAccount(this.address, this.publicKey);

  static Future<PublicAccount> fromPublicKey(String publicKey, NetworkType networkType) async {
    final address = await Address.fromPublicKey(publicKey, networkType);
    return PublicAccount(address, publicKey);
  }
}
