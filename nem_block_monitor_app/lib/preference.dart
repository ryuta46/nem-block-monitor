import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'package:nem_block_monitor_app/preference.g.dart';

@JsonSerializable(createToJson: true)
class _PreferenceDTO {
  final String network;
  final Map<String, String> nodes;

  _PreferenceDTO(this.network, this.nodes);

  factory _PreferenceDTO.fromJson(Map<String, dynamic> json) => _$_PreferenceDTOFromJson(json);

  Map<String, dynamic> toJson() => _$_PreferenceDTOToJson(this);

}


class Preference {
  static Preference instance = Preference();
  static const keySetting = "setting";
  _PreferenceDTO _dto;

  Future<Preference> load() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String settingString = prefs.get(keySetting);
    if (settingString != null) {
      final decoded = jsonDecode(settingString);
      _dto = _PreferenceDTO.fromJson(decoded);
    } else {
      _dto = _PreferenceDTO(
          "testnet",
          {
            "mainnet": "https://nismain.ttechdev.com:7891",
            "testnet": "https://nistest.ttechdev.com:7891",
          }
      );
    }
    return this;
  }

  Future<_PreferenceDTO> _save(_PreferenceDTO dto) async {
    final encoded = jsonEncode(dto.toJson());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keySetting, encoded);

    return dto;
  }


  FutureOr<void> setNetwork(String newNetwork) async {
    _dto = await _save(_PreferenceDTO(newNetwork, _dto.nodes));
  }

  String get network => _dto.network;

  FutureOr<void> setNode(String network, String nodeUrl) async {
    final newNodes = Map<String, String>()..addAll(_dto.nodes);
    newNodes[network] = nodeUrl;

    _dto = await _save(_PreferenceDTO(_dto.network, newNodes));
  }

  String get node => _dto.nodes[_dto.network];

  String getNode(String network) => _dto.nodes[network];
}
