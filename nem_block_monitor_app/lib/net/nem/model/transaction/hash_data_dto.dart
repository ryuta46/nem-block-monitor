import 'package:json_annotation/json_annotation.dart';

part 'package:nem_block_monitor_app/net/nem/model/transaction/hash_data_dto.g.dart';

@JsonSerializable(createToJson: false)
class HashDataDTO {
  final String data;
  HashDataDTO({this.data});
  static final Function factory = _$HashDataDTOFromJson;
  factory HashDataDTO.fromJson(Map<String, dynamic> json) => factory(json);
}
