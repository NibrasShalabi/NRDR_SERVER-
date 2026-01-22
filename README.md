# 🌐 Nrdr Protocol

**Network Resource Discovery & Routing Protocol**

A custom TCP-based protocol with DNS capabilities for distributed data storage and retrieval, built from scratch in Dart.

[![Dart](https://img.shields.io/badge/Dart-3.5.0-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
- [Protocol Specification](#protocol-specification)
- [DNS System](#dns-system)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 Overview

Nrdr is a **custom network protocol** designed for efficient data storage and retrieval across distributed systems. It features:

- **Custom TCP Protocol** with HTTP-style status codes (200, 404, etc.)
- **DNS System** for domain name resolution (.nrdr domains)
- **Clean Architecture** with separation of concerns
- **Type-safe Models** for requests and responses
- **Professional CLI** for easy interaction

---

## ✨ Features

### Core Protocol
- ✅ **PING** - Connection testing
- ✅ **PUBLISH** - Store key-value data
- ✅ **FETCH** - Retrieve stored data
- ✅ **LIST** - View all stored keys
- ✅ **DELETE** - Remove data

### DNS System
- ✅ **Domain Resolution** - Resolve .nrdr domains to IP:Port
- ✅ **Domain Registration** - Register custom domains
- ✅ **Domain Listing** - View all registered domains
- ✅ **Automatic Resolution** - Client automatically resolves domains

### Architecture
- ✅ **Clean Architecture** - Layers: Models, Services, Core
- ✅ **Protocol Handler** - Separate business logic
- ✅ **Type Safety** - Models for all data structures
- ✅ **Error Handling** - Comprehensive error management

---

## 🏗️ Architecture
```
┌─────────────────────────────────────────┐
│           Nrdr Protocol Stack           │
├─────────────────────────────────────────┤
│  Client CLI / Applications              │
├─────────────────────────────────────────┤
│  Nrdr Client (lib/core/nrdr_client.dart)│
│     ↓                                   │
│  DNS Resolver (if enabled)              │
│     ↓                                   │
│  TCP Connection                         │
│     ↓                                   │
│  Nrdr Server (lib/core/nrdr_server.dart)│
│     ↓                                   │
│  Protocol Handler                       │
│     ↓                                   │
│  In-Memory Storage (Map)                │
└─────────────────────────────────────────┘

DNS System (Parallel):
┌─────────────────────┐
│  DNS Server         │
│  (Port 1112)        │
│     ↓               │
│  DNS Registry       │
│  (.nrdr domains)    │
└─────────────────────┘
```

---

## 📦 Installation

### Prerequisites
- Dart SDK 3.5.0 or higher
- Git

### Steps

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/nrdr.git
cd nrdr
```

2. **Install dependencies:**
```bash
dart pub get
```

3. **Run tests (optional):**
```bash
dart run test/test_nrdr_response.dart
dart run test/test_dns_record.dart
```

---

## 🚀 Quick Start

### 1. Start the Nrdr Server
```bash
dart run bin/server.dart
```

**Output:**
```
✅ Nrdr Server running!
📍 Address: localhost:1413
📋 Protocol: Nrdr v1.0.0
📡 Waiting for clients...
```

### 2. Use the Client
```bash
# Test connection
dart run bin/client.dart ping

# Store data
dart run bin/client.dart publish name Nibras
dart run bin/client.dart publish age 23

# Retrieve data
dart run bin/client.dart fetch name

# List all keys
dart run bin/client.dart list

# Delete data
dart run bin/client.dart delete age
```

### 3. Start DNS Server (Optional)
```bash
dart run bin/dns_server.dart
```

### 4. Use DNS Resolution
```bash
# Fetch using domain name
dart run bin/client.dart fetch --dns mysite.nrdr/homepage
```

---

## 📖 Usage

### Basic Commands

#### PING - Test Connection
```bash
dart run bin/client.dart ping
```

#### PUBLISH - Store Data
```bash
dart run bin/client.dart publish <key> <value>

# Example:
dart run bin/client.dart publish username "Nibras Shalabi"
dart run bin/client.dart publish email nibras@example.com
```

#### FETCH - Retrieve Data
```bash
dart run bin/client.dart fetch <key>

# Example:
dart run bin/client.dart fetch username
```

#### LIST - View All Keys
```bash
dart run bin/client.dart list
```

#### DELETE - Remove Data
```bash
dart run bin/client.dart delete <key>

# Example:
dart run bin/client.dart delete email
```

### DNS Commands

#### Using Domains
```bash
dart run bin/client.dart fetch --dns <domain.nrdr/key>

# Example:
dart run bin/client.dart fetch --dns storage.nrdr/user_data
```

---

## 📡 Protocol Specification

### Request Format
```
<COMMAND> [arguments]\n
```

### Response Format
```
<STATUS_CODE> <STATUS_NAME>\n
<BODY>\n
END\n
```

### Status Codes

| Code | Name | Description |
|------|------|-------------|
| 200 | OK | Success |
| 201 | CREATED | Resource created |
| 204 | NO_CONTENT | Success, no content |
| 400 | BAD_REQUEST | Invalid request |
| 404 | NOT_FOUND | Resource not found |
| 409 | CONFLICT | Resource already exists |
| 413 | PAYLOAD_TOO_LARGE | Data exceeds limit |
| 500 | INTERNAL_ERROR | Server error |

### Commands

#### PING
```
Request:  PING
Response: 200 OK
          <timestamp>
          END
```

#### PUBLISH
```
Request:  PUBLISH <key> <value>
Response: 201 CREATED
          Successfully stored "<key>"
          END
```

#### FETCH
```
Request:  FETCH <key>
Response: 200 OK
          <value>
          END
```

#### LIST
```
Request:  LIST
Response: 200 OK
          key1
          key2
          key3
          END
```

#### DELETE
```
Request:  DELETE <key>
Response: 200 OK
          Deleted "<key>"
          END
```

---

## 🌐 DNS System

### DNS Commands

#### RESOLVE - Resolve Domain
```
Request:  RESOLVE mysite.nrdr
Response: 200 OK
          127.0.0.1:1413
          END
```

#### REGISTER - Register Domain
```
Request:  REGISTER mysite.nrdr 127.0.0.1 1413 web
Response: 201 CREATED
          Registered: mysite.nrdr
          END
```

#### LIST - List Domains
```
Request:  LIST
Response: 200 OK
          mysite.nrdr → 127.0.0.1:1413
          storage.nrdr → 127.0.0.1:1413
          END
```

---

## 📚 API Reference

### NrdrClient
```dart
import 'package:nrdr/core/nrdr_client.dart';

// Create client
final client = NrdrClient(
  host: 'localhost',
  port: 1413,
  enableDns: true,
);

// Connect
await client.connect();

// Commands
await client.ping();
await client.publish('key', 'value');
await client.fetch('key');
await client.list();
await client.delete('key');

// Disconnect
await client.disconnect();
```

### NrdrServer
```dart
import 'package:nrdr/core/nrdr_server.dart';

final server = NrdrServer();
await server.start(host: 'localhost', port: 1413);
```

### DnsServer
```dart
import 'package:nrdr/core/dns_server.dart';

final dnsServer = DnsServer();
await dnsServer.start(host: 'localhost', port: 1112);
```

---

## 💡 Examples

### Example 1: Simple Key-Value Storage
```bash
# Start server
dart run bin/server.dart

# Store configuration
dart run bin/client.dart publish db_host localhost
dart run bin/client.dart publish db_port 5432
dart run bin/client.dart publish db_name myapp

# Retrieve config
dart run bin/client.dart fetch db_host
```

### Example 2: Multi-Domain System
```bash
# Start DNS server
dart run bin/dns_server.dart

# Start multiple Nrdr servers on different ports
dart run bin/server.dart localhost 1413
dart run bin/server.dart localhost 1414

# Register domains (using telnet or custom client)
REGISTER api.nrdr 127.0.0.1 1413 api
REGISTER storage.nrdr 127.0.0.1 1414 storage

# Access via domains
dart run bin/client.dart fetch --dns api.nrdr/users
dart run bin/client.dart fetch --dns storage.nrdr/files
```

---

## 📁 Project Structure
```
nrdr/
├── lib/
│   ├── models/
│   │   ├── nrdr_response.dart      # Response model
│   │   └── dns_record.dart         # DNS record model
│   ├── services/
│   │   ├── protocol_handler.dart   # Protocol logic
│   │   └── dns_resolver.dart       # DNS resolution
│   ├── utils/
│   │   └── constants.dart          # Constants
│   └── core/
│       ├── nrdr_server.dart        # Main server
│       ├── nrdr_client.dart        # Main client
│       └── dns_server.dart         # DNS server
├── bin/
│   ├── server.dart                 # Server executable
│   ├── client.dart                 # Client executable
│   └── dns_server.dart             # DNS server executable
├── test/
│   ├── test_nrdr_response.dart
│   ├── test_dns_record.dart
│   └── test_protocol_handler.dart
├── examples/
│   ├── 1_simple_server.dart        # Learning examples
│   ├── 2_echo_server.dart
│   ├── 3_command_server.dart
│   └── 4_storage_server.dart
├── pubspec.yaml
└── README.md
```

---

## 🎓 Learning Path

This project was built progressively:

1. **Week 1**: Socket programming basics (examples/)
2. **Week 2**: Protocol design and implementation
3. **Week 3**: DNS system integration

Each phase builds upon the previous, demonstrating clean architecture principles.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Nibras Shalabi**
- GitHub: [@NibrasShalabi](https://github.com/NibrasShalabi)
- Email: nibras.shalabi0@gmail.com

---

## 🙏 Acknowledgments

- Inspired by HTTP, Redis, and DNS protocols
- Built as a learning project to understand network programming
- Special thanks to the Dart community

---

## 📊 Statistics

- **Lines of Code**: ~3,000+
- **Files**: 20+
- **Test Coverage**: Models and core logic
- **Development Time**: 3 weeks

---

## 🔮 Future Enhancements

- [ ] Persistent storage (database integration)
- [ ] Authentication & authorization
- [ ] Encryption (TLS/SSL)
- [ ] Clustering support
- [ ] Web dashboard
- [ ] Metrics and monitoring
- [ ] Binary protocol for performance

---

## 📞 Support

If you have any questions or issues, please:
1. Check the [documentation](#usage)
2. Search existing [issues](https://github.com/yourusername/nrdr
