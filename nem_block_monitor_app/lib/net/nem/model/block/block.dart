

import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';

enum BlockType {
  nemesis,
  regular
}

class BlockTypeValues {
  static final Map<BlockType, int> values = {
    BlockType.nemesis: -1,
    BlockType.regular: 1,
  };

  static final Map<int, BlockType> types = values.map((k, v) => MapEntry(v, k));
}

/// A blockchain is the structure that contains the transaction information. A blockchain can contain up to 120 transactions. Blocks are generated and signed by accounts and are the instrument by which information is spread in the network.
class Block  {
  /// Height of the block.
  final int height;
  /// Block type
  final BlockType type;
  /// Number of seconds elapsed since the creation of the nemesis block.
  final int timeStamp;
  /// sha3-256 hash of the last block as hex-string.
  final String prevBlockHash;
  /// Public account of the harvester of the block.
  final PublicAccount signer;

  /// The signature of the blockchain.
  final String signature;

  /// Array of transaction
  final List<Transaction> transactions;

  /// The blockchain version
  final NetworkType networkType;

  Block(this.height, this.type, this.timeStamp, this.prevBlockHash, this.signer, this.signature, this.transactions, this.networkType);
}