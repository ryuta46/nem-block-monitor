import {
    Asset,
    Block,
    MultisigTransaction,
    NEMLibrary,
    NetworkTypes, Transaction,
    TransactionTypes,
    TransferTransaction
} from "nem-library";
import {AddressWatcher, Store} from "./store";
import {Logger} from "./logger";
import {Notifier} from "./notifier";
import {NisApi} from "./nisApi";
import {AddressMessage} from "./addressMessage";

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
        const currentBlock = await NisApi.getBlockHeight();

        this.logging(`Last block   :${lastBlock}`);
        this.logging(`Current block:${currentBlock}`);

        if (lastBlock === null) {
            this.logging(`No last block.`);
            await this.store.saveLastBlock(currentBlock);
            return;
        }

        if (lastBlock === currentBlock) {
            this.logging(`No new block from ${lastBlock}`);
            return;
        }

        const blocks = await NisApi.getBlocksInRange(lastBlock + 1, currentBlock);

        const addresses = await this.store.loadWatchedAddresses();
        const assets = await this.store.loadWatchedAssets();

        await this.notifyIfRelated(blocks, addresses, assets);

        await this.store.saveLastBlock(currentBlock);
    }

    private logging(message) {
        this.logger.log(message);
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
        message += `amount: ${await NisApi.getAmount(asset)}`;
        return message;
    }
}



