import Foundation

@objc public class MessageBus: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
