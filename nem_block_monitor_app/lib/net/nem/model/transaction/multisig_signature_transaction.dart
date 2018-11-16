
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class MultisigSignatureTransaction extends Transaction {
  final String otherHash;
  final Address otherAccount;

  MultisigSignatureTransaction(Transaction base, this.otherHash, this.otherAccount): super.fromBase(base);
}