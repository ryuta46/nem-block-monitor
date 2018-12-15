// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_meta_data_pair_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionMetaDataPairDTO _$TransactionMetaDataPairDTOFromJson(
    Map<String, dynamic> json) {
  return TransactionMetaDataPairDTO(
      json['meta'] == null
          ? null
          : TransactionMetaDataDTO.fromJson(
              json['meta'] as Map<String, dynamic>),
      json['transaction'] as Map<String, dynamic>);
}
