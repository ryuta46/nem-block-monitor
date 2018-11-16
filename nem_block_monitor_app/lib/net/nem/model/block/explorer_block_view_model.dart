

import 'package:nem_block_monitor_app/net/nem/model/block/block.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/explorer_transfer_view_model.dart';

class ExplorerBlockViewModel {
  final List<ExplorerTransferViewModel> txes;
  final Block block;
  final String hash;
  final int difficulty;

  ExplorerBlockViewModel(this.txes, this.block, this.hash, this.difficulty);
}

