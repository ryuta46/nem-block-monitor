import * as admin from 'firebase-admin';
import {NotificationMessage} from "./notificationMessage";

export interface Store {
    setTargetNetwork(network: string);
    loadLastBlock(): Promise<number | null>;
    saveLastBlock(lastBlock: number): Promise<any>;

    loadWatchedAddresses(): Promise<string[]>;
    loadWatchedAssets(): Promise<string[]>;
    loadWatchersOfAddress(address: string): Promise<Watcher[]>;
    loadWatchersOfAsset(asset: string): Promise<Watcher[]>;

    loadDivisibilityCache(): Promise<Map<string, number>>;
    saveDivisibilityCache(divisibility: Map<string, number>): Promise<any>;

    saveNotifications(userId: string, notifications: NotificationMessage[])
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
    private asstWatcherCache = new Map<string, Watcher[]>();
    private addressWatcherCache = new Map<string, Watcher[]>();

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
        if (this.addressWatcherCache.has(address)) {
            return this.addressWatcherCache.get(address);
        }
        else {
            const watchers = await admin.firestore().collection(`${this.network}/addresses/${address}`).get();
            const watcherData = await Promise.all(watchers.docs.map(async (userIdDoc) => {
                return await this.loadWatcher(userIdDoc.id);
            }));
            this.addressWatcherCache.set(address, watcherData);
            return watcherData;
        }
    }

    async loadWatchersOfAsset(asset: string): Promise<Watcher[]> {
        if (this.asstWatcherCache.has(asset)) {
            return this.asstWatcherCache.get(asset);
        }
        else {
            const watchers = await admin.firestore().collection(`${this.network}/assets/${asset}`).get();
            const watcherData = await Promise.all(watchers.docs.map(async (userIdDoc) => {
                return await this.loadWatcher(userIdDoc.id);
            }));
            this.asstWatcherCache.set(asset, watcherData);
            return watcherData
        }
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
                labels[key] = data[key] as string
            }
        }
        return new Watcher(userId, token, labels);
    }

    async loadDivisibilityCache(): Promise<Map<string, number>>{
        const divisibilityDoc = await admin.firestore().doc(`${this.network}/divisibility`).get();

        const divisibility = new Map<string, number>();
        if (divisibilityDoc.exists) {
            const data = divisibilityDoc.data();

            for(const key of Object.keys(data)) {
                divisibility[key] = data[key] as number
            }
        }
        return divisibility;
    }

    async saveDivisibilityCache(divisibility: Map<string, number>): Promise<any> {
        const divisibilityObject = {};
        for (const entry of divisibility.entries()){
            divisibilityObject[entry[0]] = entry[1];
        }

        const divisibilityRef = admin.firestore().doc(`${this.network}/divisibility`);
        return divisibilityRef.set(
            divisibilityObject
        );
    }

    async saveNotifications(userId: string, notifications: NotificationMessage[]): Promise<any> {
        const docRef = admin.firestore().doc(`users/${userId}/notification/${this.network}`);
        const doc = await docRef.get();

        const notificationObjects: Object[] = notifications.map(notification => notification.toObject());
        if (!doc.exists) {
            if (notificationObjects.length > 50) {
                notificationObjects.splice(0, notificationObjects.length - 50);
            }
            return docRef.set({
                "data": notificationObjects
            });
        } else {
            const docData = doc.data();
            const currentData = docData["data"] as Object[];
            notificationObjects.push(...notificationObjects);
            if (currentData.length > 50) {
                currentData.splice(0, currentData.length - 50);
            }

            return docRef.set({"data": currentData});
        }
    }

}

