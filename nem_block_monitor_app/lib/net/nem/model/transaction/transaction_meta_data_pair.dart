

import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data.dart';

class TransactionMetaDataPair {
  final TransactionMetaData meta;
  final Transaction transaction;

  TransactionMetaDataPair(this.meta, this.transaction);
}

