import 'package:json_annotation/json_annotation.dart';

part 'package:nem_block_monitor_app/net/nem/model/block/block_height_dto.g.dart';

@JsonSerializable(createToJson: false)
class BlockHeightDTO {
  final int height;
  BlockHeightDTO({this.height});
  static final Function factory = _$BlockHeightDTOFromJson;
}
