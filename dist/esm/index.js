import { registerPlugin } from '@capacitor/core';
const MessageBus = registerPlugin('MessageBus', {
    web: () => import('./web').then((m) => new m.MessageBusWeb()),
});
export * from './definitions';
export { MessageBus };
//# sourceMappingURL=index.js.map