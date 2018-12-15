import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data_pair_dto.dart';

part 'transaction_meta_data_pair_array_dto.g.dart';

@JsonSerializable(createToJson: false)
class TransactionMetaDataPairArrayDTO {
  final List<TransactionMetaDataPairDTO> data;

  TransactionMetaDataPairArrayDTO({this.data});

  static final Function factory = _$TransactionMetaDataPairArrayDTOFromJson;
  factory TransactionMetaDataPairArrayDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<List<TransactionMetaDataPair>> toModel() async {
    return Future.wait(data.map((metaPair) => metaPair.toModel()));
  }
}
