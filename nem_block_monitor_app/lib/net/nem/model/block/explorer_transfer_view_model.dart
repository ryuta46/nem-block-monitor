

import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class ExplorerTransferViewModel {
  final Transaction tx;
  final String hash;
  final String innerHash;

  ExplorerTransferViewModel(this.tx, this.hash, this.innerHash);
}