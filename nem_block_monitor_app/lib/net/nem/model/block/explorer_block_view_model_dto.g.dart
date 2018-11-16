// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explorer_block_view_model_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExplorerBlockViewModelArrayDTO _$ExplorerBlockViewModelArrayDTOFromJson(
    Map<String, dynamic> json) {
  return ExplorerBlockViewModelArrayDTO((json['data'] as List)
      ?.map((e) => e == null
          ? null
          : ExplorerBlockViewModelDTO.fromJson(e as Map<String, dynamic>))
      ?.toList());
}

ExplorerBlockViewModelDTO _$ExplorerBlockViewModelDTOFromJson(
    Map<String, dynamic> json) {
  return ExplorerBlockViewModelDTO(
      (json['txes'] as List)
          ?.map((e) => e == null
              ? null
              : ExplorerTransferViewModelDTO.fromJson(
                  e as Map<String, dynamic>))
          ?.toList(),
      json['block'] == null
          ? null
          : BlockDTO.fromJson(json['block'] as Map<String, dynamic>),
      json['hash'] as String,
      json['difficulty'] as int);
}
