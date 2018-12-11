import {Block, MultisigTransaction, NEMLibrary, NetworkTypes, TransactionTypes, TransferTransaction} from "nem-library";
import {Store} from "./store";
import {Logger} from "./logger";
import {Notifier} from "./notifier";
import {NisApi} from "./nisApi";
import {NotificationMessage, NotificationMessageFactory} from "./notificationMessage";

export class BlockMonitorApp {

    constructor(
        readonly store: Store, readonly notifier: Notifier, readonly logger: Logger,
        readonly networks: Array<NetworkTypes> = [NetworkTypes.MAIN_NET, NetworkTypes.TEST_NET],
        readonly lastHeight: number|null = null,
        readonly currentHeight: number|null = null,
        readonly saveHeight: boolean = true
    ){};

    async run() {
        for (const network of this.networks) {
            await this.runWith(network);
        }
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

        const lastBlock = this.lastHeight || await this.store.loadLastBlock();
        const currentBlock = this.currentHeight || await NisApi.getBlockHeight();

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

        if (this.saveHeight) {
            await this.store.saveLastBlock(currentBlock);
        }
    }

    private logging(message) {
        this.logger.log(message);
    }


    private async notifyIfRelated(blocks: Block[], addresses: string[], assets: string[]) {
        this.logging(`Checking ${blocks.length} blocks, address: ${addresses}`);

        const messageFactory = new NotificationMessageFactory(await this.store.loadDivisibilityCache());

        for(const block of blocks) {
            const notifications = new Map<string, NotificationMessage[]>();
            const tasks: Promise<any>[] = [];

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
                    const receiverIndex = addresses.indexOf(transferTransaction.recipient.plain());

                    if (senderIndex >= 0 || receiverIndex  >= 0) {
                        const message = await messageFactory.createAddressTransfer(block.height, transaction, transferTransaction);
                        const watcherIds: string[] = [];

                        if (senderIndex >= 0) {
                            // Label Transform
                            const address = addresses[senderIndex];
                            const senderWatchers = await this.store.loadWatchersOfAddress(address);
                            tasks.concat(senderWatchers.map(watcher => {
                                return this.notifier.post([watcher.token],
                                    'Outgoing transaction',
                                    message.toString(watcher.labels));
                            }));

                            senderWatchers.map(watcher => {
                                if (!(watcher.userId in watcherIds)) { watcherIds.push(watcher.userId) }
                            });
                        }

                        if (receiverIndex >= 0) {
                            const address = addresses[receiverIndex];
                            const receiverWatchers = await this.store.loadWatchersOfAddress(address);
                            tasks.concat(receiverWatchers.map(watcher => {
                                return this.notifier.post([watcher.token],
                                    'Incoming transaction',
                                    message.toString(watcher.labels));
                            }));

                            receiverWatchers.map(watcher => {
                                if (!(watcher.userId in watcherIds)) { watcherIds.push(watcher.userId) }
                            });
                        }

                        for (const id of watcherIds) {
                            if (notifications.has(id)) {
                                const current: NotificationMessage[] = notifications.get(id);
                                current.push(message);
                                notifications.set(id, current);
                            } else {
                                notifications.set(id, [message]);
                            }
                        }
                    }

                    if (transferTransaction.containAssets()) {
                        for (const asset of transferTransaction.assets()) {
                            const assetFullName = `${asset.assetId.namespaceId}:${asset.assetId.name}`;
                            this.logger.log(assetFullName);
                            const assetIndex = assets.indexOf(assetFullName);
                            if (assetIndex >= 0) {
                                const watchers = await this.store.loadWatchersOfAsset(assetFullName);
                                const message = await messageFactory.createAssetTransfer(block.height, transaction, transferTransaction, asset);

                                tasks.concat(watchers.map (watcher => {
                                    return this.notifier.post([watcher.token],
                                        `Asset ${assetFullName} transferred`,
                                        message.toString(watcher.labels));
                                }));


                                for (const watcher of watchers) {
                                    const id = watcher.userId;
                                    if (notifications.has(id)) {
                                        const current: NotificationMessage[] = notifications.get(id);
                                        current.push(message);
                                        notifications.set(id, current);
                                    } else {
                                        notifications.set(id, [message]);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            for (const entry of notifications.entries()) {

                tasks.concat(this.store.saveNotifications(entry[0], entry[1]));
            }

            if (tasks.length > 0) {
                await Promise.all(tasks);
            }

            this.logging(`Checked block ${block.height}`);
        }

        if (messageFactory.isCacheDirty) {
            await this.store.saveDivisibilityCache(messageFactory.divisibilityCache);
        }

    }
}



