import {BlockMonitorApp} from "../src/app";
import {FirestoreStore} from "../src/store";
import {ConsoleLogger} from "../src/logger";
import {NetworkTypes} from "nem-library";
import {CloudMessagingNotifier} from "../src/notifier";
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

const app = new BlockMonitorApp(
    new FirestoreStore(), new CloudMessagingNotifier(), new ConsoleLogger(),
//    [NetworkTypes.MAIN_NET],
//    1932922,
//    1932923,
    [NetworkTypes.TEST_NET],
    //1935659,
    //1885312,
    //1885313,

    //1935507,
//    1935508,

    //1939980,  // Address
    //1939981, //

    //1939988,  // mosaic
    //1939989, //

    //1932922,
    //1932923,

    1746534, // testnet
    1746535, // testnet


    false
);
app.run().then((result) => {
    console.log("end");
});
