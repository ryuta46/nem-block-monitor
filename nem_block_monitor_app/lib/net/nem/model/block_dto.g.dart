// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockDTO _$BlockDTOFromJson(Map<String, dynamic> json) {
  return BlockDTO(
      timestamp: json['timestamp'] as int,
      signature: json['signature'] as String,
      prevBlockHash: json['prevBlockHash'] == null
          ? null
          : HashDataDTO.fromJson(json['prevBlockHash'] as Map<String, dynamic>),
      type: json['type'] as int,
      version: json['version'] as int,
      signer: json['signer'] as String,
      height: json['height'] as int);
}
