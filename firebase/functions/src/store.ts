
import * as admin from 'firebase-admin';

export interface Store {
    setTargetNetwork(network: string);
    loadLastBlock(): Promise<number | null>;
    saveLastBlock(lastBlock: number): Promise<any>;

    loadWatchedAddresses(): Promise<string[]>;
    loadWatcherTokensOfAddress(address: string): Promise<string[]>;
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

    async loadWatcherTokensOfAddress(address: string): Promise<string[]> {
        const watchers = await admin.firestore().collection(`${this.network}/addresses/${address}`).get();
        return Promise.all(watchers.docs.map(async (userIdDoc) => {
            const userDoc = await admin.firestore().doc(`users/${userIdDoc.id}`).get();
            if (!userDoc.exists) {
                return null;
            }
            return userDoc.data()['token'] as string;
        }));
    }
}

