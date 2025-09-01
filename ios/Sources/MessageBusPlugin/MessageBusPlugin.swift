import Foundation
import Capacitor

@objc(MessageBusPlugin)
public class MessageBusPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MessageBusPlugin"
    public let jsName = "MessageBus"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise)
    ]

    private var globalSub: MessageBus.Subscription?

    public override func load() {
        // Forward every native publish to JS
        globalSub = MessageBus.shared.subscribeAll { [weak self] type, payload in
            // ensure UI/main thread for notifyListeners
            DispatchQueue.main.async {
                self?.notifyListeners("message", data: [
                    "type": type,
                    "payload": payload ?? NSNull()
                ])
            }
        }
    }

    @objc func sendMessage(_ call: CAPPluginCall) {
        let type = call.getString("type") ?? "unknown"
        let payload = call.getObject("payload") // [String: Any]?, JSON-friendly
        MessageBus.shared.publish(type: type, payload: payload)
        call.resolve(["ok": true])
    }
}
