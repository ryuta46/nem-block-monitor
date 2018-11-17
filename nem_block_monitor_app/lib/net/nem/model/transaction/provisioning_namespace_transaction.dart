import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class ProvisioningNamespaceTransaction extends Transaction {
  final int creationFee;
  final PublicAccount creationFeeSing;
  final String newPart;
  final String parent;

  ProvisioningNamespaceTransaction(Transaction base, this.creationFee, this.creationFeeSing, this.newPart, this.parent): super.fromBase(base);
}