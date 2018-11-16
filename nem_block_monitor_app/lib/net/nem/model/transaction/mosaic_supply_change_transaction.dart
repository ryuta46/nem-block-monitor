
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/mosaic_supply_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

class MosaicSupplyChangeTransaction extends Transaction {
  final MosaicSupplyType supplyType;
  final int delta;
  final MosaicId mosaicId;

  MosaicSupplyChangeTransaction(Transaction base, this.supplyType, this.delta, this.mosaicId): super.fromBase(base);
}