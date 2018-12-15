import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_definition.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';

part 'mosaic_definition_dto.g.dart';

@JsonSerializable(createToJson: false)
class MosaicDefinitionDTO {
  final String creator;
  final MosaicIdDTO id;
  final String description;
  final List<Map<String, dynamic>> properties;
  final MosaicLevyDTO levy;

  MosaicDefinitionDTO(this.creator, this.id, this.description, this.properties, this.levy);

  static final Function factory = _$MosaicDefinitionDTOFromJson;
  factory MosaicDefinitionDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<MosaicDefinition> toModel(NetworkType networkType) async {
    final int divisibility = int.parse(_getPropertyValue("divisibility"));
    final int initialSupply = int.parse(_getPropertyValue("initialSupply"));
    final bool supplyMutable = _getPropertyValue("supplyMutable") == 'true';
    final bool transferable = _getPropertyValue("transferable") == 'true';
    return MosaicDefinition(
        await PublicAccount.fromPublicKey(creator, networkType),
        id.toModel(),
        description,
        divisibility,
        initialSupply,
        supplyMutable,
        transferable,
        levy?.toModel()
    );
  }

  String _getPropertyValue(String name) {
    final element = properties.firstWhere((element) => element["name"] == name, orElse: () => null);
    if (element != null) {
      return element["value"];
    } else {
      return null;
    }
  }
}