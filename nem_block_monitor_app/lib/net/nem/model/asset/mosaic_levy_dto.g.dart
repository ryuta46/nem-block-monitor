// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mosaic_levy_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MosaicLevyDTO _$MosaicLevyDTOFromJson(Map<String, dynamic> json) {
  return MosaicLevyDTO(
      json['type'] as int,
      json['recipient'] as String,
      json['mosaicId'] == null
          ? null
          : MosaicIdDTO.fromJson(json['mosaicId'] as Map<String, dynamic>),
      json['fee'] as int);
}
