import 'package:nem_block_monitor_app/net/nem/chain_http.dart';
import 'package:test_api/test_api.dart';

void main() {
  test('getBlockHeight', () async {
    final chainHttp = ChainHttp(Uri.http("nistest.ttechdev.com:7890", ""));
    final height = await chainHttp.getBlockchainHeight();

    expect(height, greaterThan(0));
  });

}