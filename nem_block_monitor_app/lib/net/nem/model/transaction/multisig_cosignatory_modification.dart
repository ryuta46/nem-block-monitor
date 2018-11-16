
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/modification_type.dart';

class MultisigCosignatoryModification {
  final ModificationType modificationType;
  final PublicAccount cosignatoryAccount;

  MultisigCosignatoryModification(this.modificationType, this.cosignatoryAccount);
}