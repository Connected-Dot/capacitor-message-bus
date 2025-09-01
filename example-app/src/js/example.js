import { MessageBus } from 'capacitor-message-bus';

window.testEcho = () => {
    const inputValue = document.getElementById("echoInput").value;
    MessageBus.echo({ value: inputValue })
}
