import Foundation

final class MessageBus {

    static let shared = MessageBus()

    typealias Payload = Any?
    typealias Handler = (Payload) -> Void

    // Subscription handle
    final class Subscription {
        private let cancelClosure: () -> Void
        private var isActive = true
        init(cancel: @escaping () -> Void) {
            self.cancelClosure = cancel
        }
        public func cancel() {
            guard isActive else { return }
            isActive = false
            cancelClosure()
        }
        deinit {
            cancel()
        }
    }

    // MARK: - Storage

    // [messageType: [token: Handler]]
    private var handlers: [String: [UUID: Handler]] = [:]
    // Wildcard handlers (for any message)
    private let wildcardKey = "*"

    // Serial queue for thread safety
    private let queue = DispatchQueue(label: "MessageBus.queue", qos: .default)

    private init() {}

    // MARK: - Subscribe

    /// Subscribe to a specific message type. Use "*" to receive all messages.
    @discardableResult
    func subscribe(type: String, _ handler: @escaping Handler) -> Subscription {
        let token = UUID()
        queue.sync {
            var bucket = handlers[type, default: [:]]
            bucket[token] = handler
            handlers[type] = bucket
        }
        return Subscription { [weak self] in
            self?.remove(type: type, token: token)
        }
    }

    /// Subscribe to all message types.
    @discardableResult
    func subscribeAll(_ handler: @escaping (String, Payload) -> Void) -> Subscription {
        // Wrap to adjust signature
        return subscribe(type: wildcardKey) { payload in
            // We don't know actual type here; publish will inject real type separately
            // so we handle that during publish.
            // No-op; actual invocation is handled specially in publish.
            handler(self.wildcardKey, payload)
        }
    }

    // MARK: - Publish

    func publish(type: String, payload: Payload) {
        // Snapshot handlers to call outside lock
        var callbacks: [Handler] = []
        var wildcardCallbacks: [Handler] = []

        queue.sync {
            if let specific = handlers[type] {
                callbacks.append(contentsOf: specific.values)
            }
            if let any = handlers[wildcardKey] {
                wildcardCallbacks.append(contentsOf: any.values)
            }
        }

        // Call without holding queue
        callbacks.forEach { $0(payload) }
        // For wildcard, re-wrap so subscriber can know real type if desired.
        wildcardCallbacks.forEach { $0(["__type": type, "payload": payload ?? NSNull()]) }
    }

    // MARK: - Helpers

    private func remove(type: String, token: UUID) {
        queue.sync {
            guard var bucket = handlers[type] else { return }
            bucket.removeValue(forKey: token)
            if bucket.isEmpty {
                handlers.removeValue(forKey: type)
            } else {
                handlers[type] = bucket
            }
        }
    }

    func removeAll(for type: String? = nil) {
        queue.sync {
            if let t = type {
                handlers.removeValue(forKey: t)
            } else {
                handlers.removeAll()
            }
        }
    }
}