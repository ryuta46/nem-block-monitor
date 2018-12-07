import {Address, Asset, Transaction, TransferTransaction} from "nem-library";
import {NisApi} from "./nisApi";

export enum NotificationType {
    ADDRESS = 1,
    ASSET
}

export class NotificationMessage {
    constructor(
        readonly type: NotificationType,
        readonly sender: Address,
        readonly receiver: Address,
        readonly assetMessage: string,
        readonly transactionHash: string){}

    static async createAddressTransfer(wrapTransaction: Transaction, transfer: TransferTransaction): Promise<NotificationMessage> {
        let assetMessage = "";
        if (transfer.containAssets()) {
            const assetMessages: Array<string> = [];
            for (const asset of transfer.assets()) {
                assetMessages.push(`${await NisApi.getAmount(asset)} ${asset.assetId.namespaceId}:${asset.assetId.name}`);
            }
            assetMessage = assetMessages.join('\n');
        } else {
            assetMessage = `${transfer.xem().relativeQuantity()} XEM`;
        }

        return new NotificationMessage(
            NotificationType.ADDRESS,
            wrapTransaction.signer.address,
            transfer.recipient,
            assetMessage,
            wrapTransaction.getTransactionInfo().hash.data);
    }

    static async createAssetTransfer(wrapTransaction: Transaction, transfer: TransferTransaction, asset: Asset): Promise<NotificationMessage> {

        return new NotificationMessage(
            NotificationType.ASSET,
            wrapTransaction.signer.address,
            transfer.recipient,
            `${await NisApi.getAmount(asset)} ${asset.assetId.namespaceId}:${asset.assetId.name}`,
            wrapTransaction.getTransactionInfo().hash.data);
    }

    toString(addressTransformation: Map<string, string> ): string {
        const senderLabel = addressTransformation[this.sender.plain()];
        const receiverLabel = addressTransformation[this.receiver.plain()];

        const sender = senderLabel ? senderLabel : this.sender.pretty();
        const receiver = receiverLabel ? receiverLabel : this.receiver.pretty();

        return `from: ${sender}\n`
            + `to: ${receiver}\n`
            + `amount: ${this.assetMessage}`;
    }
}

