import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/hash_data_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_mapping.dart';

part 'block_dto.g.dart';

@JsonSerializable(createToJson: false)
class BlockDTO {
  final int timeStamp;
  final String signature;
  final HashDataDTO prevBlockHash;
  final int type;
  final List<Map<String, dynamic>> transactions;
  final int version;
  final String signer;
  final int height;

  BlockDTO({this.timeStamp, this.signature, this.prevBlockHash, this.type, this.transactions, this.version, this.signer, this.height});
  static final Function factory = _$BlockDTOFromJson;
  factory BlockDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<Block> toModel() async{
    final networkType = NetworkTypeValues.types[(version & 0xFFFFFFFF) >> 24];
    return Block(
      height,
      BlockTypeValues.types[this.type],
      timeStamp,
      prevBlockHash == null ? null : prevBlockHash.data,
      await PublicAccount.fromPublicKey(signer, networkType),
      signature,
      (await Future.wait(transactions.map((element) async => await TransactionMapping.apply(element)))).toList(),
      networkType
    );
  }
}