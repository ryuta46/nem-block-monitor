import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/block.dart';
import 'package:nem_block_monitor_app/net/nem/model/hash_data_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/network_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/public_account.dart';

part 'block_dto.g.dart';

@JsonSerializable(createToJson: false)
class BlockDTO {
  final int timestamp;
  final String signature;
  final HashDataDTO prevBlockHash;
  final int type;
  //transactions: Object[];
  final int version;
  final String signer;
  final int height;

  BlockDTO({this.timestamp, this.signature, this.prevBlockHash, this.type, this.version, this.signer, this.height});
  static final Function factory = _$BlockDTOFromJson;

  Future<Block> toModel() async{
    final networkType = NetworkTypeValues.types[version];
    return Block(
      height,
      BlockTypeValues.types[this.type],
      timestamp,
      prevBlockHash == null ? null : prevBlockHash.data,
      await PublicAccount.fromPublicKey(signer, networkType),
      signature,
      [],
      networkType
    );
  }
}