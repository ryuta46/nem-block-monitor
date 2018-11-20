// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mosaic_definition_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MosaicDefinitionDTO _$MosaicDefinitionDTOFromJson(Map<String, dynamic> json) {
  return MosaicDefinitionDTO(
      json['creator'] as String,
      json['id'] == null
          ? null
          : MosaicIdDTO.fromJson(json['id'] as Map<String, dynamic>),
      json['description'] as String,
      (json['properties'] as List)
          ?.map((e) => e as Map<String, dynamic>)
          ?.toList(),
      json['levy'] == null
          ? null
          : MosaicLevyDTO.fromJson(json['levy'] as Map<String, dynamic>));
}
