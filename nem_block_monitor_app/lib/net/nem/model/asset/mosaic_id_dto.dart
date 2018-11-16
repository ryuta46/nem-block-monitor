
import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id.dart';

part 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id_dto.g.dart';

@JsonSerializable(createToJson: false)
class MosaicIdDTO {
  final String namespaceId;
  final String name;

  MosaicIdDTO(this.namespaceId, this.name);

  static final Function factory = _$MosaicIdDTOFromJson;
  factory MosaicIdDTO.fromJson(Map<String, dynamic> json) => factory(json);

  MosaicId toModel() {
    return MosaicId(namespaceId, name);

  }
}