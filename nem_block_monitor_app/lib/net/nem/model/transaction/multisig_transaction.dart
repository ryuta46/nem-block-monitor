
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_signature_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class MultisigTransaction extends Transaction {
  final Transaction otherTrans;
  final List<MultisigSignatureTransaction> signatures;

  MultisigTransaction(Transaction base, this.otherTrans, this.signatures): super.fromBase(base);
}