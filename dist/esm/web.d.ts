import { WebPlugin } from '@capacitor/core';
import type { MessageBusPlugin } from './definitions';
export declare class MessageBusWeb extends WebPlugin implements MessageBusPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
