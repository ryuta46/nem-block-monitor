
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';

class MosaicLevy {
  final MosaicLevyType type;
  final Address recipient;
  final MosaicId mosaicId;
  final int fee;

  MosaicLevy(this.type, this.recipient, this.mosaicId, this.fee);
}