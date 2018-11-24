import {
    Block,
    BlockHeight,
    BlockHttp,
    ChainHttp,
    NEMLibrary,
    NetworkTypes, Transaction,
    TransactionTypes,
    TransferTransaction
} from "nem-library";
import {Store} from "./store";
import {Logger} from "./logger";
import {Notifier} from "./notifier";

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

        await this.notifyIfRelated(blocks, addresses);

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

    private async notifyIfRelated(blocks: Block[], addresses: string[]) {
        this.logging(`Checking ${blocks.length} blocks, address: ${addresses}`);
        for(const block of blocks) {
            this.logging(`Checking block ${block.height} ....`);
            for (const transaction of block.transactions) {
                if (transaction.type === TransactionTypes.TRANSFER) {
                    const transferTransaction = transaction as TransferTransaction;
                    const sender = transaction.signer;
                    this.logging(`Sender ${sender.address.plain()}`);

                    const senderIndex = addresses.indexOf(sender.address.plain());
                    if (senderIndex >= 0) {
                        const address = addresses[senderIndex];
                        const watchers = await this.store.loadWatcherTokensOfAddress(address);
                        const message = BlockMonitorApp.createMessage(transaction, transferTransaction);
                        await this.notifier.post(watchers, 'Outgoing transaction', message);
                    }

                    const receiverIndex = addresses.indexOf(transferTransaction.recipient.plain());
                    if (receiverIndex >= 0){
                        const address = addresses[receiverIndex];
                        const watchers = await this.store.loadWatcherTokensOfAddress(address);
                        const message = BlockMonitorApp.createMessage(transaction, transferTransaction);
                        await this.notifier.post(watchers, 'Incoming transaction', message);
                    }
                }
            }
            this.logging(`Checked block ${block.height}`);
        }
    }

    private static createMessage(wrapTransaction: Transaction, transfer: TransferTransaction): string {
        let message = "";
        message += `from: ${wrapTransaction.signer.address.pretty()}\n`;
        message += `to: ${transfer.recipient.pretty()}\n`;
        message += 'amount: ';
        if (transfer.containAssets()) {
            message += transfer.assets().map((asset) => `${asset.quantity} ${asset.assetId.namespaceId}:${asset.assetId.name}`).join("\n");
        } else {
            message += `${transfer.xem().relativeQuantity()} XEM`;
        }

        return message;
    }
}


