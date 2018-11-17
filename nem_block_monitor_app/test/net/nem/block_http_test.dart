
import 'package:nem_block_monitor_app/net/nem/block_http.dart';
import 'package:test/test.dart';

import '../../bridge/nem_method_channel_test.dart';

void main() {
  test('getBlockByHeight', () async {
    DummyChannel.register();
    final blockHttp = BlockHttp(Uri.http("nistest.ttechdev.com:7890", ""));
    final block = await blockHttp.getBlockByHeight(1728577);

    expect(block.prevBlockHash, "0000000000000000000000000000000000000000000000000000000000000000");
    expect(block.height, 1);
  });
}