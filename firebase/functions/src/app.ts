import {
    Address,
    Asset, AssetHttp,
    Block,
    BlockHeight,
    BlockHttp,
    ChainHttp, MultisigTransaction,
    NEMLibrary,
    NetworkTypes, Transaction,
    TransactionTypes,
    TransferTransaction
} from "nem-library";
import {AddressWatcher, Store} from "./store";
import {Logger} from "./logger";
import {Notifier} from "./notifier";
import {Decimal} from 'decimal.js'

export class BlockMonitorApp {

    constructor(readonly store: Store, readonly notifier: Notifier, readonly logger: Logger ){};

    async run() {
        await this.runWith(NetworkTypes.MAIN_NET);
        await this.runWith(NetworkTypes.TEST_NET);
    }

    private static initializeLibrary(networkType: NetworkTypes) {
        try {
            NEMLibrary.reset();
            NEMLibrary.bootstrap(networkType);
        } catch (e) {
            console.log(e);
        }
    }

    private async runWith(networkType: NetworkTypes) {
        BlockMonitorApp.initializeLibrary(networkType);
        if (networkType === NetworkTypes.MAIN_NET) {
            this.store.setTargetNetwork("mainnet");
        } else {
            this.store.setTargetNetwork("testnet");
        }

        const lastBlock = await this.store.loadLastBlock();
        const currentBlock = await this.getBlockHeight();

        if (lastBlock === null) {
            this.logging(`No last block.`);
            await this.store.saveLastBlock(currentBlock);
            return;
        }

        if (lastBlock === currentBlock) {
            this.logging(`No new block from ${lastBlock}`);
            return;
        }

        const blocks = await this.getBlocksInRange(lastBlock + 1, currentBlock);
        const addresses = await this.store.loadWatchedAddresses();
        const assets = await this.store.loadWatchedAssets();

        await this.notifyIfRelated(blocks, addresses, assets);

        await this.store.saveLastBlock(currentBlock);
    }

    private logging(message) {
        this.logger.log(message);
    }

    private async getBlockHeight(): Promise<BlockHeight> {
        this.logging(`getBlockHeight`);
        const chainHttp = new ChainHttp();
        return chainHttp.getBlockchainHeight().toPromise();
    }

    private async getBlockByHeight(height: BlockHeight): Promise<Block> {
        this.logging(`getBlockByHeight: ${height}`);
        const blockHttp = new BlockHttp();
        return blockHttp.getBlockByHeight(height).toPromise();
    }

    private async getBlocksInRange(startHeight: BlockHeight, endHeight: BlockHeight): Promise<Block[]> {
        this.logging(`getBlocksInRange ${startHeight} .. ${endHeight}`);
        const tasks = Array.from(Array(1 + endHeight - startHeight).keys())
            .map(value => value + startHeight )
            .map( height => this.getBlockByHeight(height));

        return Promise.all(tasks);
    }

    private async notifyIfRelated(blocks: Block[], addresses: string[], assets: string[]) {
        this.logging(`Checking ${blocks.length} blocks, address: ${addresses}`);
        for(const block of blocks) {
            this.logging(`Checking block ${block.height} ....`);
            for (const transaction of block.transactions) {
                let transferTransaction: TransferTransaction = null;
                if (transaction.type === TransactionTypes.MULTISIG) {
                    const multisig = transaction as MultisigTransaction;
                    if (multisig.otherTransaction.type === TransactionTypes.TRANSFER) {
                        transferTransaction = multisig.otherTransaction as TransferTransaction;
                    }
                }

                if (transaction.type === TransactionTypes.TRANSFER) {
                    transferTransaction = transaction as TransferTransaction;
                }

                if (transferTransaction !== null) {
                    const sender = transaction.signer;
                    this.logging(`Sender ${sender.address.plain()}`);

                    const senderIndex = addresses.indexOf(sender.address.plain());
                    let senderWatchers: AddressWatcher[] = [];
                    let receiverWatchers: AddressWatcher[] = [];

                    if (senderIndex >= 0) {
                        const address = addresses[senderIndex];
                        senderWatchers = await this.store.loadWatchersOfAddress(address);
                    }
                    const receiverIndex = addresses.indexOf(transferTransaction.recipient.plain());
                    if (receiverIndex >= 0) {
                        const address = addresses[receiverIndex];
                        receiverWatchers = await this.store.loadWatchersOfAddress(address);
                    }

                    if (senderWatchers.length > 0 || receiverWatchers.length > 0) {
                        const addressMessage = await AddressMessage.create(transaction, transferTransaction);
                        // Label Transform
                        const tasks = senderWatchers.filter(it => it.token.length > 0).map(senderWatcher => {
                            let peerLabel = "";
                            const peerWatcher = receiverWatchers.find(it => it.userId === senderWatcher.userId);
                            if (peerWatcher) {
                                peerLabel = peerWatcher.label
                            }
                            return this.notifier.post([senderWatcher.token],
                                'Outgoing transaction',
                                addressMessage.toString(senderWatcher.label, peerLabel));
                        });

                        tasks.concat(receiverWatchers.filter(it => it.token.length > 0).map(receiverWatcher => {
                            let peerLabel = "";
                            const peerWatcher = senderWatchers.find(it => it.userId === receiverWatcher.userId);
                            if (peerWatcher) {
                                peerLabel = peerWatcher.label
                            }
                            return this.notifier.post([receiverWatcher.token],
                                'Incoming transaction',
                                addressMessage.toString(peerLabel, receiverWatcher.label));
                        }));

                        await Promise.all(tasks);
                    }


                    if (transferTransaction.containAssets()) {
                        for (const asset of transferTransaction.assets()) {
                            const assetFullName = `${asset.assetId.namespaceId}:${asset.assetId.name}`;
                            this.logger.log(assetFullName);
                            const assetIndex = assets.indexOf(assetFullName);
                            if (assetIndex >= 0) {
                                const watchers = await this.store.loadWatcherTokensOfAsset(assetFullName);
                                const message = await BlockMonitorApp.createAssetMessage(transaction, transferTransaction, asset);
                                await this.notifier.post(watchers, `Asset ${assetFullName} transferred`, message);
                            }
                        }
                    }
                }


            }
            this.logging(`Checked block ${block.height}`);
        }
    }


    private static async createAssetMessage(wrapTransaction: Transaction, transfer: TransferTransaction, asset: Asset): Promise<string> {
        let message = "";
        message += `from: ${wrapTransaction.signer.address.pretty()}\n`;
        message += `to: ${transfer.recipient.pretty()}\n`;
        message += `amount: ${await BlockMonitorApp.getAmount(asset)}`;
        return message;
    }

    static async getAmount(asset: Asset): Promise<Decimal>{
        const divisibility = await this.getAssetDivisibility(asset);
        return getDivided(asset.quantity, divisibility);
    }

    private static async getAssetDivisibility(asset: Asset): Promise<number>{
        // TODO: Load cache
        const assetHttp = new AssetHttp();
        const assetDefinition = await assetHttp.getAssetDefinition(asset.assetId).toPromise();
        return assetDefinition.properties.divisibility;
    }

}


function getDivided(value: number, divisibility: number): Decimal {
    return new Decimal(value).div(10 ** divisibility);
}


class AddressMessage {
    constructor(readonly sender: Address, readonly receiver: Address, readonly assetMessage: string){}

    static async create(wrapTransaction: Transaction, transfer: TransferTransaction): Promise<AddressMessage> {
        let assetMessage = "";
        if (transfer.containAssets()) {
            const assetMessages: Array<string> = [];
            for (const asset of transfer.assets()) {
                assetMessages.push(`${await BlockMonitorApp.getAmount(asset)} ${asset.assetId.namespaceId}:${asset.assetId.name}`);
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
