'use strict';

var core = require('@capacitor/core');

const MessageBus = core.registerPlugin('MessageBus', {
    web: () => Promise.resolve().then(function () { return web; }).then((m) => new m.MessageBusWeb()),
});

class MessageBusWeb extends core.WebPlugin {
    async echo(options) {
        console.log('ECHO', options);
        return options;
    }
}

var web = /*#__PURE__*/Object.freeze({
    __proto__: null,
    MessageBusWeb: MessageBusWeb
});

exports.MessageBus = MessageBus;
//# sourceMappingURL=plugin.cjs.js.map
