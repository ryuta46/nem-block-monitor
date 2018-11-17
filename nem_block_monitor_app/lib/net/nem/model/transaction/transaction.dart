

import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_type.dart';

class Transaction {
  final int timestamp;
  final String signature;
  final PublicAccount signer;
  final int fee;
  final int deadline;
  final TransactionType type;
  final NetworkType networkType;

  int get totalFee => fee;

  Transaction.fromBase(Transaction base):
        this.timestamp = base.timestamp,
        this.signature = base.signature,
        this.signer = base.signer,
        this.fee = base.fee,
        this.deadline = base.deadline,
        this.type = base.type,
        this.networkType = base.networkType;

  Transaction(
      this.timestamp, this.signature, this.signer, this.fee, this.deadline,
      this.type, this.networkType);
}

