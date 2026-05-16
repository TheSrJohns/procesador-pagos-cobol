# procesador-pagos-cobol

> **Clean Architecture COBOL Payment Processor**  
> A modern, layered event-driven payment authorization system written in GnuCOBOL.

---

## Author

**Jhon Hanco** — [@TheSrJohns](https://github.com/TheSrJohns)  
📧 TheSrJohns

---

## Architecture Overview

This project demonstrates how to apply **Clean Architecture / Layered Architecture** principles to COBOL. Each directory represents a distinct architectural layer with a single responsibility.

```
procesador-pagos-cobol/
│
├── copybooks/                 <-- Models / DTOs Layer
│   └── AUTH-DTO.cpy           Pure data definitions. Zero logic.
│
├── controlador/               <-- Presentation / Orchestration Layer
│   └── EVENT-DAEMON.cbl       The "Boss". Event loop, clock, delegation.
│
├── servicios/                 <-- Business Logic / Core Layer
│   └── SECURITY-SERVICE.cbl   Pure rules (card masking, validation).
│
├── infraestructura/           <-- Data Access & File Adapters Layer
│   ├── JSON-SERVICE.cbl       Input adapter: reads physical JSON files.
│   └── AUDIT-REPO.cbl         Output adapter: writes physical audit logs.
│
├── data/                      <-- Test Data / Environment
│   ├── input/
│   │   └── auth-request.json
│   └── logs/
│       └── audit.log
│
└── run-daemon.sh              <-- Build & run script
```

### Layer Responsibilities

| Layer | File(s) | Responsibility |
|-------|---------|----------------|
| **Models / DTOs** | `AUTH-DTO.cpy` | Pure data structures shared across all layers. |
| **Controller** | `EVENT-DAEMON.cbl` | Orchestrates the main event loop, timestamps, and delegates work downward. |
| **Services** | `SECURITY-SERVICE.cbl` | Contains domain rules: mask PANs, validate amounts, enrich status. |
| **Infrastructure** | `JSON-SERVICE.cbl` | Reads external JSON payloads from the filesystem. |
| **Infrastructure** | `AUDIT-REPO.cbl` | Persists masked audit records to a physical log file. |

---

## Prerequisites

- [GnuCOBOL](https://gnucobol.sourceforge.io/) (`cobc`) 3.x or later
- Bash (for the build script)
- Linux / macOS / WSL

---

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/TheSrJohns/procesador-pagos-cobol.git
cd procesador-pagos-cobol

# 2. Build & run
chmod +x run-daemon.sh
./run-daemon.sh
```

The daemon will:
1. Initialize all subsystems.
2. Enter a polling loop every 5 seconds.
3. Read `data/input/auth-request.json`.
4. Mask the card number (show only last 4 digits).
5. Validate the amount against the business limit.
6. Append a masked audit line to `data/logs/audit.log`.

---

## Data Flow

```
┌─────────────────┐
│  auth-request   │
│    .json        │
└────────┬────────┘
         │ read
         ▼
┌─────────────────┐
│  JSON-SERVICE   │  <-- Infrastructure / Input Adapter
│   (parse JSON)  │
└────────┬────────┘
         │ DTO
         ▼
┌─────────────────┐
│ EVENT-DAEMON    │  <-- Controller / Orchestrator
│  (delegate)     │
└────────┬────────┘
         │ DTO
         ▼
┌─────────────────┐
│ SECURITY-SERVICE│ <-- Business Logic / Core
│ (mask & validate)│
└────────┬────────┘
         │ DTO (masked)
         ▼
┌─────────────────┐
│  AUDIT-REPO     │  <-- Infrastructure / Output Adapter
│  (write log)    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   audit.log     │
└─────────────────┘
```

---

## Key Design Decisions

1. **Copybooks as DTOs** — `AUTH-DTO.cpy` is a pure data definition with no `PROCEDURE DIVISION`. It acts as the contract between layers.
2. **CALL-based dependency** — Layers communicate via `CALL "PROGRAM-NAME"` using the DTO as the shared payload. This mimics micro-service boundaries inside a single runtime.
3. **File adapters** — `JSON-SERVICE` and `AUDIT-REPO` isolate I/O concerns. If tomorrow the input comes from MQ or a REST API, only the adapter changes.
4. **Masking in the core** — PCI-sensitive logic (card masking) lives in `SECURITY-SERVICE`, never in the controller or the infrastructure.

---

## License

MIT © Jhon Hanco ([@TheSrJohns](https://github.com/TheSrJohns))
