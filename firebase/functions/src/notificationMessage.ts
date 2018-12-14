import {Decimal} from 'decimal.js'
import {Address, Asset, Transaction, TransferTransaction} from "nem-library";
import {NisApi} from "./nisApi";

export enum NotificationType {
    ADDRESS = 1,
    ASSET
}

class NotificationAsset {
    constructor(
        readonly namespaceId: string,
        readonly name: string,
        readonly quantity: number,
        readonly divisibility: number){}

    get amount(): Decimal {
        return getDivided(this.quantity, this.divisibility);
    }

    toString(): string {
        if ((this.namespaceId === "nem") && (this.name === "xem")) {
            return `${this.amount} XEM`;
        } else {
            return `${this.amount} ${this.namespaceId}:${this.name}`;
        }
    }
    toObject(): Object {
        return {
            "namespaceId": this.namespaceId,
            "name": this.name,
            "quantity": this.quantity,
            "divisibility": this.divisibility
        };
    }
}

export class NotificationMessage {
    constructor(
        readonly network: string,
        readonly timestamp: number,
        readonly height: number,
        readonly type: NotificationType,
        readonly sender: Address,
        readonly receiver: Address,
        readonly assets: NotificationAsset[],
        readonly signature: string){}


    toString(addressTransformation: Map<string, string> ): string {
        const senderLabel = addressTransformation[this.sender.plain()];
        const receiverLabel = addressTransformation[this.receiver.plain()];

        const sender = senderLabel ? senderLabel : this.sender.pretty();
        const receiver = receiverLabel ? receiverLabel : this.receiver.pretty();

        return `from: ${sender}\n`
            + `to: ${receiver}\n`
            + `amount: ${this.assets.map(asset => asset.toString()).join('\n')}`;
    }

    toObject() {
        return {
            "network": this.network,
            "timestamp": this.timestamp,
            "height": this.height,
            "type": this.type,
            "sender": this.sender.plain(),
            "receiver": this.receiver.plain(),
            "assets": this.assets.map(asset => asset.toObject()),
            "signature": this.signature
        }
    }

}

export class NotificationMessageFactory {
    private _isCacheDirty = false;

    get isCacheDirty(): Boolean {
        return this._isCacheDirty;
    }

    constructor(readonly divisibilityCache: Map<string, number>){
    }

    async createAddressTransfer(network: string, height: number, wrapTransaction: Transaction, transfer: TransferTransaction): Promise<NotificationMessage> {
        const assets: NotificationAsset[] = [];

        if (transfer.containAssets()) {
            for (const asset of transfer.assets()) {
                assets.push(new NotificationAsset(asset.assetId.namespaceId, asset.assetId.name, asset.quantity, await this.getDivisibility(asset)));
            }
        } else {
            assets.push(new NotificationAsset("nem", "xem", Math.round(transfer.xem().absoluteQuantity()), 6));
        }

        return new NotificationMessage(
            network,
            wrapTransaction.toDTO().timeStamp,
            height,
            NotificationType.ADDRESS,
            wrapTransaction.signer.address,
            transfer.recipient,
            assets,
            wrapTransaction.signature);
    }

    async createAssetTransfer(network: string, height: number, wrapTransaction: Transaction, transfer: TransferTransaction, asset: Asset): Promise<NotificationMessage> {

        return new NotificationMessage(
            network,
            wrapTransaction.toDTO().timeStamp,
            height,
            NotificationType.ASSET,
            wrapTransaction.signer.address,
            transfer.recipient,
            [ new NotificationAsset(asset.assetId.namespaceId, asset.assetId.name, asset.quantity, await this.getDivisibility(asset)) ],
            wrapTransaction.signature);
    }

    async getDivisibility(asset: Asset): Promise<number>{
        if ((asset.assetId.namespaceId === "nem") && (asset.assetId.name === "xem")) {
            return 6;
        }
        const assetFullName = `${asset.assetId.namespaceId}:${asset.assetId.name}`;
        let divisibility: number;
        if (this.divisibilityCache.has(assetFullName)) {
            return this.divisibilityCache.get(assetFullName);
        } else {
            divisibility = await NisApi.getAssetDivisibility(asset);
            this.divisibilityCache.set(assetFullName, divisibility);
            this._isCacheDirty = true;
            return divisibility;
        }
    }

}

function getDivided(value: number, divisibility: number): Decimal {
    return new Decimal(value).div(10 ** divisibility);
}
