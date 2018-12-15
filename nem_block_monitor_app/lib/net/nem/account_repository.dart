

import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair.dart';

abstract class AccountRepository {
  Future<List<TransactionMetaDataPair>> getOutgoingTransactions(Address address, {int id = -1});
}
