
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_definition_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/hash_data_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/importance_mode.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/importance_transfer_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/message.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/message_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/modification_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/mosaic_definition_creation_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/mosaic_supply_change_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/mosaic_supply_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_aggregate_modification_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_cosignatory_modification.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_signature_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/multisig_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/provisioning_namespace_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transaction_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/transfer_transaction.dart';

class TransactionMapping {

  static Future<Transaction> apply(Map<String, dynamic> dict) async {
    final base = await getBase(dict);

    switch(base.type) {
      case TransactionType.importanceTransfer:
        return getImportanceTransfer(base, dict);
      case TransactionType.mosaicDefinitionCreation:
        return getMosaicDefinitionCreation(base, dict);
      case TransactionType.mosaicSupplyChange:
        return getMosaicSupplyChange(base, dict);
      case TransactionType.multisigAggregateModification:
        return getMultisigAggregateModification(base, dict);
      case TransactionType.multisigSignature:
        return getMultisigSignature(base, dict);
      case TransactionType.multisig:
        return getMultisig(base, dict);
      case TransactionType.provisioningNamespace:
        return getProvisioningNamespace(base, dict);
      case TransactionType.transfer:
        return getTransfer(base, dict);
      default:
        return null;
    }
  }

  static Future<Transaction> getBase(Map<String, dynamic> dict) async {
    final typeValue = dict["type"];
    final type = TransactionTypeValues.types[typeValue];

    final int version = dict["version"];
    final networkType = NetworkTypeValues.types[(version & 0xFFFFFFFF) >> 24];

    return Transaction(
      dict["timeStamp"] as int,
      dict["signature"] as String,
      await PublicAccount.fromPublicKey(dict["signer"] as String, networkType),
      dict["fee"] as int,
      dict["deadline"] as int,
      type,
      networkType
    );
  }

  static Future<ImportanceTransferTransaction> getImportanceTransfer(Transaction base, Map<String, dynamic> dict) async {
    return ImportanceTransferTransaction(
        base,
        ImportanceModeValues.types[dict["mode"] as int],
        await PublicAccount.fromPublicKey(dict["remoteAccount"] as String, base.networkType)
    );
  }

  static Future<MosaicDefinitionCreationTransaction> getMosaicDefinitionCreation(Transaction base, Map<String, dynamic> dict) async {

    return MosaicDefinitionCreationTransaction(
        base,
        dict["creationFee"] as int,
        Address(dict["creationFeeSink"] as String),
        await MosaicDefinitionDTO.fromJson(dict["mosaicDefinition"]).toModel(base.networkType)
    );
  }
  static Future<MosaicSupplyChangeTransaction> getMosaicSupplyChange(Transaction base, Map<String, dynamic> dict) async {
    return MosaicSupplyChangeTransaction(
        base,
        MosaicSupplyTypeValues.types[dict["supplyType"] as int],
        dict["delta"] as int,
        MosaicIdDTO.fromJson(dict["mosaicId"]).toModel()
    );
  }
  static Future<MultisigAggregateModificationTransaction> getMultisigAggregateModification(Transaction base, Map<String, dynamic> dict) async {
    final List<dynamic> modificationsDict = dict["modifications"];
    List<MultisigCosignatoryModification> modifications = [];
    if (modificationsDict != null) {
      modifications = (await Future.wait(modificationsDict.map((modificationDict) async {
        return MultisigCosignatoryModification(
            ModificationTypeValues.types[modificationDict["modificationType"]],
            await PublicAccount.fromPublicKey(modificationDict["cosignatoryAccount"], base.networkType));
      }))).toList();
    }

    int relativeChange = 0;
    final Map<String, dynamic> minCosignatoriesDict = dict["minCosignatories"];
    if (minCosignatoriesDict != null) {
      relativeChange = minCosignatoriesDict["relativeChange"] as int;
    }

    return MultisigAggregateModificationTransaction(
        base,
        modifications,
        relativeChange);
  }

  static Future<MultisigSignatureTransaction> getMultisigSignature(Transaction base, Map<String, dynamic> dict) async {
    return MultisigSignatureTransaction(
        base,
        HashDataDTO.fromJson(dict["otherHash"]).data,
        Address(dict["otherAccount"])
    );
  }

  static Future<MultisigTransaction> getMultisig(Transaction base, Map<String, dynamic> dict) async {
    final otherTrans = await TransactionMapping.apply(dict["otherTrans"]);
    final List<dynamic> signaturesDict = dict["signatures"];
    final List<MultisigSignatureTransaction> signatures = (await Future.wait(signaturesDict.map(
            (signatureDict) async => await TransactionMapping.apply(signatureDict) as MultisigSignatureTransaction))).toList();

    return MultisigTransaction(
        base,
        otherTrans,
        signatures
    );
  }
  static Future<ProvisioningNamespaceTransaction> getProvisioningNamespace(Transaction base, Map<String, dynamic> dict) async {
    return ProvisioningNamespaceTransaction(
      base,
      dict["rentalFee"] as int,
      Address(dict["rentalFeeSink"] as String),
      dict["newPart"] as String,
      dict["parent"] as String,
    );
  }

  static Future<TransferTransaction> getTransfer(Transaction base, Map<String, dynamic> dict) async {
    final messageDict = dict["message"] as Map<String, dynamic>;
    Message message;
    if (messageDict == null) {
      message = null;
    } else {
      message = Message(
          MessageTypeValues.types[messageDict["type"]],
          messageDict["payload"]
      );
    }

    final List<dynamic> mosaicsArray = dict["mosaics"];
    List<Mosaic> mosaics = [];

    if (mosaicsArray != null) {
      mosaics = mosaicsArray.map((mosaicDict) {
        final mosaicIdDict = mosaicDict["mosaicId"];
        final mosaicId = MosaicIdDTO.fromJson(mosaicIdDict).toModel();
        return Mosaic(mosaicId, mosaicDict["quantity"] as int);
      }).toList();
    }

    return TransferTransaction(
        base,
        dict["amount"] as int,
        Address(dict["recipient"]),
        message,
        mosaics
    );
  }

}