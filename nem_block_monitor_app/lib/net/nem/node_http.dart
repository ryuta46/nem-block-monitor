
import 'package:nem_block_monitor_app/net/nem/base_http.dart';
import 'package:nem_block_monitor_app/net/nem/model/node/node.dart';
import 'package:nem_block_monitor_app/net/nem/model/node/node_dto.dart';
import 'package:nem_block_monitor_app/net/nem/node_repository.dart';

class NodeHttp extends BaseHttp implements NodeRepository {
  NodeHttp(Uri baseUri) : super(baseUri);

  @override
  Future<List<Node>> getPeerList() async {
    final dto = await get<NodeCollectionDTO>(
        NodeCollectionDTO.factory, "/node/peer-list/active");
    return dto.toModel();
  }
}