

import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/message.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class TransferTransaction extends Transaction {
  final int amount;
  final Address recipient;
  final Message message;
  final List<Mosaic> mosaics;

  TransferTransaction(Transaction base, this.amount, this.recipient, this.message, this.mosaics) : super.fromBase(base);
}