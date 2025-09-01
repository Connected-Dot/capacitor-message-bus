import { WebPlugin } from '@capacitor/core';

import type { MessageBusPlugin } from './definitions';

export class MessageBusWeb extends WebPlugin implements MessageBusPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
