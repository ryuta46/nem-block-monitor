
import 'package:nem_block_monitor_app/net/nem/account_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:test_api/test_api.dart';

import '../../bridge/nem_method_channel_test.dart';

void main() {
  test('outgoingTransaction', () async {
    DummyChannel.register();
    final accountHttp = AccountHttp(Uri.http("nistest.ttechdev.com:7890", ""));
    final transactions = await accountHttp.getOutgoingTransactions(Address('TCRUHA3423WEYZN64CZ62IVK53VQ5JGIRJT5UMAE'));

    print(transactions);

    transactions.forEach((transaction) {
      print(transaction.meta.hash);
      //expect(block.height, 1);
    });
  });

  test('outgoingTransactionPaging', () async {
    DummyChannel.register();
    final accountHttp = AccountHttp(Uri.http("nistest.ttechdev.com:7890", ""));

    int id = -1;
    while(true) {
      final transactions = await accountHttp.getOutgoingTransactions(Address('TCRUHA3423WEYZN64CZ62IVK53VQ5JGIRJT5UMAE'), id: id);

      transactions.forEach((transaction) {
        print(transaction.meta.id);
        //expect(block.height, 1);
      });

      if (transactions.isEmpty) {
        break;
      }
      id = transactions.last.meta.id;
    }
  });

}