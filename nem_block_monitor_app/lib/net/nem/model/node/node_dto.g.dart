// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeEndPointDTO _$NodeEndPointDTOFromJson(Map<String, dynamic> json) {
  return NodeEndPointDTO(
      protocol: json['protocol'] as String,
      port: json['port'] as int,
      host: json['host'] as String);
}

NodeDTO _$NodeDTOFromJson(Map<String, dynamic> json) {
  return NodeDTO(
      endpoint: json['endpoint'] == null
          ? null
          : NodeEndPointDTO.fromJson(json['endpoint'] as Map<String, dynamic>));
}

NodeCollectionDTO _$NodeCollectionDTOFromJson(Map<String, dynamic> json) {
  return NodeCollectionDTO(
      data: (json['data'] as List)
          ?.map((e) =>
              e == null ? null : NodeDTO.fromJson(e as Map<String, dynamic>))
          ?.toList());
}
