import 'package:json_annotation/json_annotation.dart';

part 'hash_data_dto.g.dart';

@JsonSerializable(createToJson: false)
class HashDataDTO {
  final String data;
  HashDataDTO({this.data});
  static final Function factory = _$HashDataDTOFromJson;
  factory HashDataDTO.fromJson(Map<String, dynamic> json) => factory(json);
}
