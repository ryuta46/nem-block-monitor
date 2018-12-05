import {Address, Transaction, TransferTransaction} from "nem-library";
import {NisApi} from "./nisApi";


export class AddressMessage {
    constructor(readonly sender: Address, readonly receiver: Address, readonly assetMessage: string){}

    static async create(wrapTransaction: Transaction, transfer: TransferTransaction): Promise<AddressMessage> {
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

        return new AddressMessage(wrapTransaction.signer.address, transfer.recipient, assetMessage);
    }

    toString(senderLabel: string, receiverLabel: string ): string {
        const sender = senderLabel === "" ? this.sender.pretty() : senderLabel;
        const receiver = receiverLabel === "" ? this.receiver.pretty() : receiverLabel;

        return `from: ${sender}\n`
            + `to: ${receiver}\n`
            + `amount: ${this.assetMessage}`;
    }
}

