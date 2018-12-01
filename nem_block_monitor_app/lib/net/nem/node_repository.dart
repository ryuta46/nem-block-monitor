

import 'package:nem_block_monitor_app/net/nem/model/node/node.dart';

abstract class NodeRepository {
  Future<List<Node>> getPeerList();
}