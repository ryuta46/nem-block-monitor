import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class ProvisioningNamespaceTransaction extends Transaction {
  final int rentalFee;
  final Address rentalFeeSink;
  final String newPart;
  final String parent;

  ProvisioningNamespaceTransaction(Transaction base, this.rentalFee, this.rentalFeeSink, this.newPart, this.parent): super.fromBase(base);
}