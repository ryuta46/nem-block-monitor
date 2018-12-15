// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_meta_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionMetaDataDTO _$TransactionMetaDataDTOFromJson(
    Map<String, dynamic> json) {
  return TransactionMetaDataDTO(
      json['height'] as int,
      json['id'] as int,
      json['hash'] == null
          ? null
          : HashDataDTO.fromJson(json['hash'] as Map<String, dynamic>));
}
