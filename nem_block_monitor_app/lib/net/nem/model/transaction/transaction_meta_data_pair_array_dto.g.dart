// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_meta_data_pair_array_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionMetaDataPairArrayDTO _$TransactionMetaDataPairArrayDTOFromJson(
    Map<String, dynamic> json) {
  return TransactionMetaDataPairArrayDTO(
      data: (json['data'] as List)
          ?.map((e) => e == null
              ? null
              : TransactionMetaDataPairDTO.fromJson(e as Map<String, dynamic>))
          ?.toList());
}
