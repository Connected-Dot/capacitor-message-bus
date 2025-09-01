export interface MessageBusPlugin {
    echo(options: {
        value: string;
    }): Promise<{
        value: string;
    }>;
}
