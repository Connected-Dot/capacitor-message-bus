import Foundation
import Capacitor

@objc(MessageBusPlugin)
public class MessageBusPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MessageBusPlugin"
    public let jsName = "MessageBus"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise)
    ]

    public override func load() {
        // Example: forward all "done" messages to JS
        _ = MessageBus.shared.subscribe(type: "done") { [weak self] payload in
            self?.notifyListeners("message", data: [
                "type": "done",
                "payload": payload ?? NSNull()
            ])
        }
    }

    @objc func sendMessage(_ call: CAPPluginCall) {
        let type = call.getString("type") ?? "unknown"
        let payload = call.getObject("payload")
        MessageBus.shared.publish(type: type, payload: payload)
        call.resolve(["ok": true])
    }
}

