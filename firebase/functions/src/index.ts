// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });


import * as functions from 'firebase-functions';

import * as admin from 'firebase-admin';
import {ConsoleLogger, QueuedLogger} from "./logger";
import {BlockMonitorApp} from "./app";
import {FirestoreStore} from "./store";
import {CloudMessagingNotifier} from "./notifier";

admin.initializeApp(functions.config().firebase);

/*
export const monitorNemBlockManual = functions.https.onRequest(async (request, response) => {
    const store = new FirestoreStore();
    const notifier = new CloudMessagingNotifier();
    const logger = new QueuedLogger();

    const app = new BlockMonitorApp(store, notifier, logger);
    await app.run();
    response.send( logger.queuedLog.join('\n') + "\n\n");
});
*/


export const monitorNemBlockFunc = functions.pubsub.topic("monitor-nem-block").onPublish(async (msg) => {
    const store = new FirestoreStore();
    const notifier = new CloudMessagingNotifier();
    const logger = new ConsoleLogger();

    const app = new BlockMonitorApp(store, notifier, logger);
    await app.run();
});


