
import * as admin from 'firebase-admin';

export interface Store {
    setTargetNetwork(network: string);
    loadLastBlock(): Promise<number | null>;
    saveLastBlock(lastBlock: number): Promise<any>;

    loadWatchedAddresses(): Promise<string[]>;
    loadWatchedAssets(): Promise<string[]>;
    loadWatchersOfAddress(address: string): Promise<Watcher[]>;
    loadWatchersOfAsset(asset: string): Promise<Watcher[]>;
}

export class Watcher {
    constructor(
        readonly userId: string,
        readonly token: string,
        readonly labels: Map<string, string>
        ){}
}


export class FirestoreStore implements Store {
    private network: string = 'testnet';

    setTargetNetwork(network: string) {
        this.network = network;
    }

    async loadLastBlock(): Promise<number | null> {
        const blockHeight = await admin.firestore().doc(`${this.network}/height`).get();
        if (!blockHeight.exists) {
            return null;
        }
        const blockHeightData = blockHeight.data();
        return blockHeightData['last'];
    }

    async saveLastBlock(lastBlock: number): Promise<any> {
        const blockHeightRef = admin.firestore().doc(`${this.network}/height`);
        return blockHeightRef.set({
            last: lastBlock
        });
    }

    async loadWatchedAddresses(): Promise<string[]> {
        const addresses = await admin.firestore().doc(`${this.network}/addresses`).getCollections();
        return addresses.map(collection => collection.id);
    }

    async loadWatchedAssets(): Promise<string[]> {
        const assets = await admin.firestore().doc(`${this.network}/assets`).getCollections();
        return assets.map(collection => collection.id);
    }


    async loadWatchersOfAddress(address: string): Promise<Watcher[]> {
        const watchers = await admin.firestore().collection(`${this.network}/addresses/${address}`).get();
        return Promise.all(watchers.docs.map(async (userIdDoc) => {
            return await this.loadWatcher(userIdDoc.id);
        }));
    }

    async loadWatchersOfAsset(asset: string): Promise<Watcher[]> {
        const watchers = await admin.firestore().collection(`${this.network}/assets/${asset}`).get();
        return Promise.all(watchers.docs.map(async (userIdDoc) => {
            return await this.loadWatcher(userIdDoc.id);
        }));
    }

    private async loadWatcher(userId: string): Promise<Watcher>{
        const userDoc = await admin.firestore().doc(`users/${userId}`).get();

        if (!userDoc.exists) {
            return null;
        }
        const token = userDoc.data()['token'] as string;

        const labelDoc = await admin.firestore().doc(`users/${userId}/label/${this.network}`).get();
        const labels = new Map<string, string>();
        if (labelDoc.exists) {
            const data = labelDoc.data();

            for(const key of Object.keys(data)) {
                labels[key] = labelDoc.data()[key] as string
            }
        }
        return new Watcher(userId, token, labels);
    }

}

