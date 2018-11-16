
import 'package:nem_block_monitor_app/net/nem/base_http.dart';
import 'package:nem_block_monitor_app/net/nem/chain_repository.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_block_view_model.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_block_view_model_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block_height_dto.dart';

class ChainHttp extends BaseHttp implements ChainRepository {
  ChainHttp(Uri baseUri) : super(baseUri);

  @override
  Future<int> getBlockchainHeight() async {
    final dto = await get<BlockHeightDTO>(
        BlockHeightDTO.factory, "/chain/height");
    return dto.height;
  }

  Future<List<ExplorerBlockViewModel>> getBlocksAfter(int height) async {
    final dto = await post<ExplorerBlockViewModelArrayDTO>(
        ExplorerBlockViewModelArrayDTO.factory, "/local/chain/blocks-after", { "height": height });

    return dto.toModel();
  }

}