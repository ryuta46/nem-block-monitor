
enum TransactionType {
  importanceTransfer,
  mosaicDefinitionCreation,
  transfer,
  aggregateModification,
  multisigSignature,
  multisig
}


class TransactionTypeValues {
  static final Map<TransactionType, int> values = {
    TransactionType.importanceTransfer: 0x801,
    TransactionType.mosaicDefinitionCreation: 0x4001,
    TransactionType.transfer: 0x101,
    TransactionType.aggregateModification: 0x1001,
    TransactionType.multisigSignature: 0x1002,
    TransactionType.multisig: 0x1003,
  };

  static final Map<int, TransactionType> types = values.map((k, v) => MapEntry(v, k));
}