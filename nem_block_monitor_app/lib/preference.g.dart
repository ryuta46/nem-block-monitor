// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PreferenceDTO _$_PreferenceDTOFromJson(Map<String, dynamic> json) {
  return _PreferenceDTO(
      json['network'] as String,
      (json['nodes'] as Map<String, dynamic>)
          ?.map((k, e) => MapEntry(k, e as String)));
}

Map<String, dynamic> _$_PreferenceDTOToJson(_PreferenceDTO instance) =>
    <String, dynamic>{'network': instance.network, 'nodes': instance.nodes};
