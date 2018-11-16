
import 'package:nem_block_monitor_app/net/nem/base_http.dart';
import 'package:nem_block_monitor_app/net/nem/block_repository.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/block_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_block_view_model_dto.dart';

class BlockHttp extends BaseHttp implements BlockRepository {
  BlockHttp(Uri baseUri) : super(baseUri);

  @override
  Future<Block> getBlockByHeight(int height) async {
    final dto = await post<BlockDTO>(
        BlockDTO.factory, "/block/at/public", { "height": height });

    return dto.toModel();
  }
}