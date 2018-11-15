
import 'package:nem_block_monitor_app/net/nem/base_http.dart';
import 'package:nem_block_monitor_app/net/nem/chain_repository.dart';
import 'package:nem_block_monitor_app/net/nem/models/block_height_dto.dart';

class ChainHttp extends BaseHttp implements ChainRepository {
  ChainHttp(Uri baseUri) : super(baseUri);

  @override
  Future<int> getBlockchainHeight() async {
    final dto = await get<BlockHeightDTO>(
        BlockHeightDTO.factory, "/chain/height");
    return dto.height;
  }
}