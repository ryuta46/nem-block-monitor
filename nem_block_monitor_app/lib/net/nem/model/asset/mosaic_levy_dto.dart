import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';

part 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy_dto.g.dart';

@JsonSerializable(createToJson: false)
class MosaicLevyDTO {
  final int type;
  final String recipient;
  final MosaicIdDTO mosaicId;
  final int fee;

  MosaicLevyDTO(this.type, this.recipient, this.mosaicId, this.fee);

  static final Function factory = _$MosaicLevyDTOFromJson;
  factory MosaicLevyDTO.fromJson(Map<String, dynamic> json) => factory(json);

  MosaicLevy toModel() {
    if (recipient == null) {
      return null;
    }
    return MosaicLevy(
        MosaicLevyTypeValues.types[int],
        Address(recipient),
        mosaicId.toModel(),
        fee
    );
  }
}
