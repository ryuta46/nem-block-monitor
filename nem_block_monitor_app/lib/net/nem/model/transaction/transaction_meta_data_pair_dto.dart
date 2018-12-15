
import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_mapping.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair.dart';

part 'transaction_meta_data_pair_dto.g.dart';

@JsonSerializable(createToJson: false)
class TransactionMetaDataPairDTO {
  final TransactionMetaDataDTO meta;
  final Map<String, dynamic> transaction;

  TransactionMetaDataPairDTO(this.meta, this.transaction);

  static final Function factory = _$TransactionMetaDataPairDTOFromJson;
  factory TransactionMetaDataPairDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<TransactionMetaDataPair> toModel() async {
    return TransactionMetaDataPair(
        meta.toModel(),
        await TransactionMapping.apply(transaction)
    );
  }

}
