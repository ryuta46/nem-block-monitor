import 'package:json_annotation/json_annotation.dart';

part 'block_height_dto.g.dart';

@JsonSerializable(createToJson: false)
class BlockHeightDTO {
  final int height;
  BlockHeightDTO({this.height});
  static final Function factory = _$BlockHeightDTOFromJson;
}
