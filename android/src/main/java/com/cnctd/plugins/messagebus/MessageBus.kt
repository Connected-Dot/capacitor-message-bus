package com.cnctd.plugins.messagebus

import java.util.UUID

class MessageBus private constructor() {
    companion object {
        val shared = MessageBus()
    }

    fun interface Handler {
        fun onMessage(payload: Any?)
    }

    fun interface GlobalHandler {
        fun onMessage(type: String, payload: Any?)
    }

    class Subscription(private val cancelAction: () -> Unit) {
        private var isActive = true

        @Synchronized
        fun cancel() {
            if (!isActive) return
            isActive = false
            cancelAction()
        }
    }

    private val lock = Any()
    private val handlers = mutableMapOf<String, MutableMap<String, Handler>>()
    private val globalHandlers = mutableMapOf<String, GlobalHandler>()

    fun subscribe(type: String, handler: Handler): Subscription {
        val token = UUID.randomUUID().toString()
        synchronized(lock) {
            handlers.getOrPut(type) { mutableMapOf() }[token] = handler
        }
        return Subscription { remove(type, token) }
    }

    fun subscribeAll(handler: GlobalHandler): Subscription {
        val token = UUID.randomUUID().toString()
        synchronized(lock) {
            globalHandlers[token] = handler
        }
        return Subscription { removeGlobal(token) }
    }

    fun publish(type: String, payload: Any? = null) {
        val callbacks: List<Handler>
        val globals: List<GlobalHandler>

        synchronized(lock) {
            callbacks = handlers[type]?.values?.toList() ?: emptyList()
            globals = globalHandlers.values.toList()
        }

        for (cb in callbacks) cb.onMessage(payload)
        for (g in globals) g.onMessage(type, payload)
    }

    private fun remove(type: String, token: String) {
        synchronized(lock) {
            val bucket = handlers[type] ?: return
            bucket.remove(token)
            if (bucket.isEmpty()) handlers.remove(type)
        }
    }

    private fun removeGlobal(token: String) {
        synchronized(lock) { globalHandlers.remove(token) }
    }

    fun removeAll(type: String? = null) {
        synchronized(lock) {
            if (type != null) {
                handlers.remove(type)
            } else {
                handlers.clear()
                globalHandlers.clear()
            }
        }
    }
}
