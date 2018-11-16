
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';
import 'package:test/test.dart';

void main() {
  test('fromPlainAddress', () async {
    final plain = 'NBERYPGLBLMJJYMTMNFSY3UDMXTLZFUNP4CQG7SO';
    final pretty = 'NBERYP-GLBLMJ-JYMTMN-FSY3UD-MXTLZF-UNP4CQ-G7SO';
    final address = Address(plain);

    expect(address.plain, plain);
    expect(address.pretty, pretty);
    expect(address.networkType, NetworkType.mainNet);
  });
  test('fromPrettyAddress', () async {
    final plain = 'NBERYPGLBLMJJYMTMNFSY3UDMXTLZFUNP4CQG7SO';
    final pretty = 'NBERYP-GLBLMJ-JYMTMN-FSY3UD-MXTLZF-UNP4CQ-G7SO';
    final address = Address(pretty);

    expect(address.plain, plain);
    expect(address.pretty, pretty);
    expect(address.networkType, NetworkType.mainNet);
  });
}
