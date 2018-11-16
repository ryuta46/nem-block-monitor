
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';

class MosaicDefinition {
  final PublicAccount creator;
  final MosaicId mosaicId;
  final String description;
  final int divisibility;
  final int initialSupply;
  final bool supplyMutable;
  final bool transferable;
  final MosaicLevy levy;

  MosaicDefinition(this.creator, this.mosaicId, this.description, this.divisibility, this.initialSupply, this.supplyMutable, this.transferable, this.levy);
}