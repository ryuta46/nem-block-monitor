import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/hash_data_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_meta_data.dart';

part 'transaction_meta_data_dto.g.dart';


@JsonSerializable(createToJson: false)
class TransactionMetaDataDTO {
  final int height;
  final int id;
  final HashDataDTO hash;

  TransactionMetaDataDTO(this.height, this.id, this.hash);

  static final Function factory = _$TransactionMetaDataDTOFromJson;
  factory TransactionMetaDataDTO.fromJson(Map<String, dynamic> json) => factory(json);

  TransactionMetaData toModel() {
    return TransactionMetaData(height, id, hash.data);
  }
}

