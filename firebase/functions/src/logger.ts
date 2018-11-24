
export interface Logger {
    log(message);
}

export class QueuedLogger implements Logger {
    queuedLog: Array<String> = [];
    log(message) {
        this.queuedLog.push(message);
    }
}

export class ConsoleLogger implements Logger {
    log(message) {
        console.log(message);
    }
}


