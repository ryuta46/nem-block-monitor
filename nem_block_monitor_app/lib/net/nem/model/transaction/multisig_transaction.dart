
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_signature_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class MultisigTransaction extends Transaction {
  final Transaction otherTrans;
  final List<MultisigSignatureTransaction> signatures;

  @override int get totalFee {
    final signatureFee = signatures.isEmpty
        ? 0
        : (signatures.length == 1
        ?  signatures[0].fee
        : signatures.map((signature) => signature.fee).reduce((f1, f2) => f1 + f2));
    return fee + otherTrans.fee + signatureFee;
  }

  MultisigTransaction(Transaction base, this.otherTrans, this.signatures): super.fromBase(base);
}