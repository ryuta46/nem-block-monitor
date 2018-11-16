
import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';

abstract class BlockRepository {
  Future<Block> getBlockByHeight(int height);
}