

import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/importance_mode.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class ImportanceTransferTransaction extends Transaction {
  final ImportanceMode mode;
  final PublicAccount remoteAccount;

  ImportanceTransferTransaction(Transaction base, this.mode, this.remoteAccount) : super.fromBase(base);
}