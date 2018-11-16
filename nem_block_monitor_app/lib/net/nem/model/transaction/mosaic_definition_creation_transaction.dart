

import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_definition.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class MosaicDefinitionCreationTransaction extends Transaction {
  final int creationFee;
  final PublicAccount creationFeeSing;
  final MosaicDefinition mosaicDefinition;

  MosaicDefinitionCreationTransaction(Transaction base, this.creationFee, this.creationFeeSing, this.mosaicDefinition): super.fromBase(base);

}