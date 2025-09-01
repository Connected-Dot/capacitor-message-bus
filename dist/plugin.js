var capacitorMessageBus = (function (exports, core) {
    'use strict';

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

    return exports;

})({}, capacitorExports);
//# sourceMappingURL=plugin.js.map
