package com.cnctd.plugins.messagebus;

import com.getcapacitor.Logger;

public class MessageBus {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
