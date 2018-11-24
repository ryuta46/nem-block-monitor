import {BlockMonitorApp} from "../src/app";
import {FirestoreStore, Store} from "../src/store";
import {ConsoleLogger} from "../src/logger";
import {NEMLibrary, NetworkTypes} from "nem-library";
import {CloudMessagingNotifier, ConsoleNotifier} from "../src/notifier";
import * as admin from "firebase-admin";


const serviceAccount = require("../serviceAccount.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://nemblockmonitor.firebaseio.com"

});


/*
class DummyStore implements Store {
    async loadLastBlock(): Promise<number | null> {
        return 1722720;
    }

    async saveLastBlock(lastBlock: number): Promise<any> {
        return 0;
    }

    async loadWatchedAddresses(): Promise<string[]> {
        return ["TCRUHA3423WEYZN64CZ62IVK53VQ5JGIRJT5UMAE"];
    }

    async loadWatcherTokensOfAddress(address: string): Promise<string[]> {
        return undefined;
    }
}
*/



const app = new BlockMonitorApp(new FirestoreStore(), new CloudMessagingNotifier(), new ConsoleLogger());
app.run().then((result) => {
    console.log("end");
});
