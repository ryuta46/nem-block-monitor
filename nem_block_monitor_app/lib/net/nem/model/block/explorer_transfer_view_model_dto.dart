import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_transfer_view_model.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_mapping.dart';

part 'package:nem_block_monitor_app/net/nem/model/block/explorer_transfer_view_model_dto.g.dart';

@JsonSerializable(createToJson: false)
class ExplorerTransferViewModelDTO {
  final Map<String, dynamic> tx;
  final String hash;
  final String innerHash;

  ExplorerTransferViewModelDTO(this.tx, this.hash, this.innerHash);

  static final Function factory = _$ExplorerTransferViewModelDTOFromJson;
  factory ExplorerTransferViewModelDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<ExplorerTransferViewModel> toModel() async{
    return ExplorerTransferViewModel(
      await TransactionMapping.apply(tx),
      hash,
      innerHash
    );
  }
}