
import * as admin from "firebase-admin";
import MessagingPayload = admin.messaging.MessagingPayload;

export interface Notifier {
    post(receivers: string[], title: string, text: string): Promise<any>;
}


export class ConsoleNotifier implements Notifier {
    async post(receivers: string[], title: string, text: string): Promise<any> {
        console.log(`${title}: ${text}`);
        return;
    }
}


export class CloudMessagingNotifier implements Notifier {
    async post(receivers: string[], title: string, text: string): Promise<any> {
        const message: MessagingPayload = {
            notification: {
                body: text,
                title: title,
                sound: 'default',
                click_action: 'FLUTTER_NOTIFICATION_CLICK'
            },
            data: {
                body: text,
                title: title
            }
        };
        await admin.messaging().sendToDevice(receivers, message);
    }


}
