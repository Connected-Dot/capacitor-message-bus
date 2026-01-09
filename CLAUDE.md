# CLAUDE.md - capacitor-message-bus

> Brief reference for the Capacitor message bus plugin.

## Purpose

Cross-platform Capacitor plugin enabling bidirectional message passing between TypeScript frontend and native backend (Swift/Java) implementations.

## Key Exports

```typescript
// TypeScript interface
import { MessageBusPlugin } from 'capacitor-message-bus';

interface MessageBusPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
```

## Project Structure

```
message-bus/
├── src/               # TypeScript source
│   ├── index.ts      # Plugin registration
│   ├── definitions.ts # Type definitions
│   └── web.ts        # Web implementation
├── ios/              # iOS Swift implementation
├── android/          # Android Java implementation
└── package.json
```

## Usage Example

```typescript
import { MessageBus } from 'capacitor-message-bus';

const result = await MessageBus.echo({ value: 'Hello' });
```

## Ecosystem Role

- **Used by**: cnctd.world client (iOS/Android)
- **Platform**: Capacitor v7

## Version

**0.0.1**

---

*Part of the cnctd monorepo. See `../../../CLAUDE.md` for ecosystem context.*
