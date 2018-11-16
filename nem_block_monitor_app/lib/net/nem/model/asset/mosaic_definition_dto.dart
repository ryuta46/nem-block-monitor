import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_definition.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_levy_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';

part 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_definition_dto.g.dart';

@JsonSerializable(createToJson: false)
class MosaicDefinitionDTO {
  final String creator;
  final MosaicIdDTO mosaicId;
  final String description;
  final List<Map<String, dynamic>> properties;
  final MosaicLevyDTO levy;

  MosaicDefinitionDTO(this.creator, this.mosaicId, this.description, this.properties, this.levy);

  static final Function factory = _$MosaicDefinitionDTOFromJson;
  factory MosaicDefinitionDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<MosaicDefinition> toModel(NetworkType networkType) async {
    final int divisibility = _getPropertyValue("divisibility") ?? 0;
    final int initialSupply = _getPropertyValue("initialSupply");
    final bool supplyMutable = _getPropertyValue("supplyMutable");
    final bool transferable = _getPropertyValue("transferable");
    return MosaicDefinition(
        await PublicAccount.fromPublicKey(creator, networkType),
        mosaicId.toModel(),
        description,
        divisibility,
        initialSupply,
        supplyMutable,
        transferable,
        levy.toModel()
    );
  }

  dynamic _getPropertyValue(String name) {
    final element = properties.firstWhere((element) => element["name"] == name, orElse: () => null);
    if (element != null) {
      return element["value"];
    } else {
      return null;
    }
  }
}