import {Decimal} from 'decimal.js'
import {Address, Asset, Transaction, TransferTransaction} from "nem-library";
import {NisApi} from "./nisApi";

export enum NotificationType {
    ADDRESS = 1,
    ASSET
}

export class NotificationMessage {
    constructor(
        readonly height: number,
        readonly type: NotificationType,
        readonly sender: Address,
        readonly receiver: Address,
        readonly assetMessage: string,
        readonly signature: string){}


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

export class NotificationMessageFactory {
    private _isCacheDirty = false;

    get isCacheDirty(): Boolean {
        return this._isCacheDirty;
    }

    constructor(readonly divisibilityCache: Map<string, number>){
    }

    async createAddressTransfer(height: number, wrapTransaction: Transaction, transfer: TransferTransaction): Promise<NotificationMessage> {
        let assetMessage = "";

        if (transfer.containAssets()) {
            const assetMessages: Array<string> = [];
            for (const asset of transfer.assets()) {
                assetMessages.push(`${await this.getAmount(asset)} ${asset.assetId.namespaceId}:${asset.assetId.name}`);
            }
            assetMessage = assetMessages.join('\n');
        } else {
            assetMessage = `${transfer.xem().relativeQuantity()} XEM`;
        }

        return new NotificationMessage(
            height,
            NotificationType.ADDRESS,
            wrapTransaction.signer.address,
            transfer.recipient,
            assetMessage,
            wrapTransaction.signature);
    }

    async createAssetTransfer(height: number, wrapTransaction: Transaction, transfer: TransferTransaction, asset: Asset): Promise<NotificationMessage> {

        return new NotificationMessage(
            height,
            NotificationType.ASSET,
            wrapTransaction.signer.address,
            transfer.recipient,
            `${await this.getAmount(asset)} ${asset.assetId.namespaceId}:${asset.assetId.name}`,
            wrapTransaction.signature);
    }

    async getAmount(asset: Asset): Promise<Decimal>{
        const assetFullName = `${asset.assetId.namespaceId}:${asset.assetId.name}`;
        let divisibility: number;
        if (this.divisibilityCache.has(assetFullName)) {
            divisibility = this.divisibilityCache.get(assetFullName);
        } else {
            divisibility = await NisApi.getAssetDivisibility(asset);
            this.divisibilityCache.set(assetFullName, divisibility);
            this._isCacheDirty = true;
        }
        return getDivided(asset.quantity, divisibility);
    }

}

function getDivided(value: number, divisibility: number): Decimal {
    return new Decimal(value).div(10 ** divisibility);
}
