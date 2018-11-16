import 'package:json_annotation/json_annotation.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_block_view_model.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_transfer_view_model_dto.dart';

part 'package:nem_block_monitor_app/net/nem/model/block/explorer_block_view_model_dto.g.dart';

@JsonSerializable(createToJson: false)
class ExplorerBlockViewModelArrayDTO {
  List<ExplorerBlockViewModelDTO> data;

  ExplorerBlockViewModelArrayDTO(this.data);
  static final Function factory = _$ExplorerBlockViewModelArrayDTOFromJson;
  factory ExplorerBlockViewModelArrayDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<List<ExplorerBlockViewModel>> toModel() async {
    return Future.wait(data.map( (item) => item.toModel()));
  }
}

@JsonSerializable(createToJson: false)
class ExplorerBlockViewModelDTO {
  List<ExplorerTransferViewModelDTO> txes;
  BlockDTO block;
  String hash;
  int difficulty;

  ExplorerBlockViewModelDTO(this.txes, this.block, this.hash, this.difficulty);

  static final Function factory = _$ExplorerBlockViewModelDTOFromJson;
  factory ExplorerBlockViewModelDTO.fromJson(Map<String, dynamic> json) => factory(json);

  Future<ExplorerBlockViewModel> toModel() async{
    return ExplorerBlockViewModel(
      await Future.wait(txes.map((item) => item.toModel())),
      await block.toModel(),
      this.hash,
      this.difficulty
    );
  }

}

