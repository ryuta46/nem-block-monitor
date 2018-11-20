
enum TransactionType {
  importanceTransfer,
  mosaicDefinitionCreation,
  mosaicSupplyChange,
  multisigAggregateModification,
  multisigSignature,
  multisig,
  provisioningNamespace,
  transfer,
}


class TransactionTypeValues {
  static final Map<TransactionType, int> values = {
    TransactionType.importanceTransfer: 0x801,
    TransactionType.mosaicDefinitionCreation: 0x4001,
    TransactionType.mosaicSupplyChange: 0x4002,
    TransactionType.multisigAggregateModification: 0x1001,
    TransactionType.multisigSignature: 0x1002,
    TransactionType.multisig: 0x1004,
    TransactionType.provisioningNamespace: 0x2001,
    TransactionType.transfer: 0x101,
  };

  static final Map<int, TransactionType> types = values.map((k, v) => MapEntry(v, k));
}