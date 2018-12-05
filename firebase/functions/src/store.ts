
import * as admin from 'firebase-admin';

export interface Store {
    setTargetNetwork(network: string);
    loadLastBlock(): Promise<number | null>;
    saveLastBlock(lastBlock: number): Promise<any>;

    loadWatchedAddresses(): Promise<string[]>;
    loadWatchedAssets(): Promise<string[]>;
    loadWatchersOfAddress(address: string): Promise<AddressWatcher[]>;
    loadWatcherTokensOfAsset(asset: string): Promise<string[]>;
}

export class AddressWatcher {
    constructor(
        readonly userId: string,
        readonly token: string,
        readonly label: string,
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


    async loadWatchersOfAddress(address: string): Promise<AddressWatcher[]> {
        const watchers = await admin.firestore().collection(`${this.network}/addresses/${address}`).get();
        return Promise.all(watchers.docs.map(async (userIdDoc) => {
            const label = userIdDoc.data()['label'] || '';
            let token = '';
            if (userIdDoc.data()['active']) {
                token = await FirestoreStore.loadTokenOfUser(userIdDoc.id)
            }
            return new AddressWatcher(userIdDoc.id, token, label);
        }));
    }

    async loadWatcherTokensOfAsset(asset: string): Promise<string[]> {
        const watchers = await admin.firestore().collection(`${this.network}/assets/${asset}`).get();
        return Promise.all(watchers.docs.map(async (userIdDoc) => {
            return await FirestoreStore.loadTokenOfUser(userIdDoc.id);
        }));
    }

    private static async loadTokenOfUser(userId: string): Promise<string>{
        const userDoc = await admin.firestore().doc(`users/${userId}`).get();
        if (!userDoc.exists) {
            return null;
        }
        return userDoc.data()['token'] as string;
    }

}

