package com.cnctd.plugins.messagebus

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin
import com.getcapacitor.PluginCall
import com.getcapacitor.PluginMethod
import com.getcapacitor.annotation.CapacitorPlugin

@CapacitorPlugin(name = "MessageBus")
class MessageBusPlugin : Plugin() {

    private var globalSub: MessageBus.Subscription? = null

    override fun load() {
        super.load()

        globalSub = MessageBus.shared.subscribeAll { type, payload ->
            activity.runOnUiThread {
                val data = JSObject().apply {
                    put("type", type)
                    when (payload) {
                        is JSObject -> put("payload", payload)
                        null -> put("payload", JSObject.NULL)
                        else -> put("payload", payload)
                    }
                }
                notifyListeners("message", data)
            }
        }
    }

    override fun handleOnDestroy() {
        super.handleOnDestroy()
        globalSub?.cancel()
        globalSub = null
    }

    @PluginMethod
    fun sendMessage(call: PluginCall) {
        val type = call.getString("type") ?: "unknown"
        val payload = call.getObject("payload")

        MessageBus.shared.publish(type, payload)

        call.resolve(JSObject().apply { put("ok", true) })
    }
}
