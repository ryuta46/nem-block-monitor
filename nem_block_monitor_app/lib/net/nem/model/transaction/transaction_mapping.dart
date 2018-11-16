
import 'package:nem_block_monitor_app/net/nem/model/account/address.dart';
import 'package:nem_block_monitor_app/net/nem/model/account/public_account.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_definition_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/asset/mosaic_id_dto.dart';
import 'package:nem_block_monitor_app/net/nem/model/block/network_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/importance_mode.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/importance_transfer_transaction.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/message.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/message_type.dart';
import 'package:nem_block_monitor_app/net/nem/model/transaction/mosaic_definition_creation_transaction.dart';
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
        await PublicAccount.fromPublicKey(dict["creationFeeSink"] as String, base.networkType),
        await MosaicDefinitionDTO.fromJson(dict["definition"]).toModel(base.networkType)
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

    final mosaicsArray = dict["mosaics"] as List<Map<String, dynamic>>;
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