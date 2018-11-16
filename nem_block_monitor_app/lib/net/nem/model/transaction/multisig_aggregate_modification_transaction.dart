
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_cosignatory_modification.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class MultisigAggregateModificationTransaction extends Transaction {
  final List<MultisigCosignatoryModification> modifications;
  final int minCosignatoriesRelativeChange;

  MultisigAggregateModificationTransaction(Transaction base, this.modifications, this.minCosignatoriesRelativeChange): super.fromBase(base);
}