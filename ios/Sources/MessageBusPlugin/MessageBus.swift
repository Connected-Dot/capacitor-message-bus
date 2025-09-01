final class MessageBus {
    static let shared = MessageBus()

    typealias Payload = Any?
    typealias Handler = (Payload) -> Void
    typealias GlobalHandler = (_ type: String, _ payload: Payload) -> Void

    final class Subscription {
        private let cancelClosure: () -> Void
        private var isActive = true
        init(cancel: @escaping () -> Void) { self.cancelClosure = cancel }
        public func cancel() { guard isActive else { return }; isActive = false; cancelClosure() }
        deinit { cancel() }
    }

    private var handlers: [String: [UUID: Handler]] = [:]
    private var globalHandlers: [UUID: GlobalHandler] = [:]
    private let queue = DispatchQueue(label: "MessageBus.queue", qos: .default)

    private init() {}

    @discardableResult
    func subscribe(type: String, _ handler: @escaping Handler) -> Subscription {
        let token = UUID()
        queue.sync {
            var bucket = handlers[type, default: [:]]
            bucket[token] = handler
            handlers[type] = bucket
        }
        return Subscription { [weak self] in self?.remove(type: type, token: token) }
    }

    @discardableResult
    func subscribeAll(_ handler: @escaping GlobalHandler) -> Subscription {
        let token = UUID()
        queue.sync { globalHandlers[token] = handler }
        return Subscription { [weak self] in self?.removeGlobal(token: token) }
    }

    func publish(type: String, payload: Payload) {
        var callbacks: [Handler] = []
        var globals: [GlobalHandler] = []
        queue.sync {
            callbacks = Array(handlers[type]?.values ?? [])
            globals = Array(globalHandlers.values)
        }
        callbacks.forEach { $0(payload) }
        globals.forEach { $0(type, payload) }
    }

    private func remove(type: String, token: UUID) {
        queue.sync {
            guard var bucket = handlers[type] else { return }
            bucket.removeValue(forKey: token)
            if bucket.isEmpty { handlers.removeValue(forKey: type) } else { handlers[type] = bucket }
        }
    }

    private func removeGlobal(token: UUID) {
        queue.sync { globalHandlers.removeValue(forKey: token) }
    }

    func removeAll(for type: String? = nil) {
        queue.sync {
            if let t = type { handlers.removeValue(forKey: t) }
            else { handlers.removeAll(); globalHandlers.removeAll() }
        }
    }
}
