
import 'package:nem_block_monitor_app/net/nem/block_http.dart';
import 'package:test/test.dart';

void main() {
  test('getBlockByHeight', () async {
    final blockHttp = BlockHttp(Uri.http("nistest.ttechdev.com:7890", ""));
    final block = await blockHttp.getBlockByHeight(1);

    expect(block.prevBlockHash, "0000000000000000000000000000000000000000000000000000000000000000");
    expect(block.height, 1);
  });
}