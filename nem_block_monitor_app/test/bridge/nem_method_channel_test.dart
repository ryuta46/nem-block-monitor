
import 'package:flutter_test/flutter_test.dart';
import 'package:nem_block_monitor_app/bridge/nem_method_channel.dart';
import 'package:nem_block_monitor_app/net/nem/model/network_type.dart';


void main() {
   test('calculateAddress', () async {
    final publicKey = "1e68cbd764e54655dd5ebadcdc28ef68409a87ab3deaf56fa9cb8e46145b5872";
    final expectedAddress = "NBERYPGLBLMJJYMTMNFSY3UDMXTLZFUNP4CQG7SO";
    final address = await NemMethodChannel.calculateAddress(publicKey, NetworkType.mainNet);

    expect(expectedAddress, address);
  });
}