import { registerPlugin } from '@capacitor/core';

import type { MessageBusPlugin } from './definitions';

const MessageBus = registerPlugin<MessageBusPlugin>('MessageBus', {
  web: () => import('./web').then((m) => new m.MessageBusWeb()),
});

export * from './definitions';
export { MessageBus };
