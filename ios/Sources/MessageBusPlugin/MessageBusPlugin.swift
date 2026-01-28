import Foundation
import Capacitor

extension Notification.Name {
    static let capMessageBusPublish = Notification.Name("capMessageBusPublish")
}

@objc(MessageBusPlugin)
public class MessageBusPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "MessageBusPlugin"
    public let jsName = "MessageBus"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "sendMessage", returnType: CAPPluginReturnPromise)
    ]

    private var globalSub: MessageBus.Subscription?

    public override func load() {
        super.load()

        // Forward every native publish to JS
        globalSub = MessageBus.shared.subscribeAll { [weak self] type, payload in
            DispatchQueue.main.async {
                self?.notifyListeners("message", data: [
                    "type": type,
                    "payload": payload ?? NSNull()
                ])
            }
        }

        // NEW: listen for app-level posts and inject into the bus
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExternalPublish(_:)),
            name: .capMessageBusPublish,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleExternalPublish(_ note: Notification) {
        let userInfo = note.userInfo as? [String: Any]
        let type = userInfo?["type"] as? String ?? "unknown"
        let payload = userInfo?["payload"]
        MessageBus.shared.publish(type: type, payload: payload)
    }

    @objc func sendMessage(_ call: CAPPluginCall) {
        let type = call.getString("type") ?? "unknown"
        let payload = call.getObject("payload")

        // Publish to internal MessageBus (for JS listeners via globalSub)
        MessageBus.shared.publish(type: type, payload: payload)

        // Also post to NotificationCenter so native code can listen
        // This enables native modules like MediaPickers to receive JS messages
        NotificationCenter.default.post(
            name: .capMessageBusPublish,
            object: nil,
            userInfo: [
                "type": type,
                "payload": payload as Any
            ]
        )

        call.resolve(["ok": true])
    }
}
