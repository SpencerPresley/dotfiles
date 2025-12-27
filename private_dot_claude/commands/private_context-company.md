---
description: Load CrunchAtlas company and product context when business decisions matter
allowed-tools: Read
---

# CrunchAtlas Company Context

Use this context when making architectural decisions, writing documentation, or when business context affects technical choices.

## Company

**CrunchAtlas** - Cybersecurity technology company (Portsmouth, NH). Founded 2024. AI-powered threat hunting and collaborative cyber defense for critical infrastructure, defense, and commercial sectors.

## Products

### AtlasCyber (Blue Team)
Primary product. AI-powered threat detection and investigation.

- **Deployment**: Edge boxes in SCIFs (air-gapped), plus hosted SaaS for commercial
- **Capabilities**: Network traffic capture, detection algorithms (graph theory + behavioral patterns), PCAP parsing, Snort integration, tshark-based investigation
- **Key constraint**: SCIF deployments are air-gapped - no call-home, everything local, only metadata returns

### PurpleHaze (Red Team)
Platform extension to AtlasCyber for offensive operations.

- **Commercial customers**: Internal pentesting only
- **Government/DoD**: Active attack capability for 3-letter agencies
- **Pipeline**: detect → investigate → classify → assess reachability → assess vulnerability → attack → persist
- **Current approach**: Orchestrating existing tools (metasploit, nmap, tshark). Custom tooling (implants, C2) is future state.

### CrunchSense
Electron-based packet capture tool for on-prem deployments. Captures network packets, auto-uploads to APIs, scheduled jobs.

## This Repository (ac-agents)

Collection of Python libraries for building AI agents. Used via GitHub PAT in:
- `atlascyber` backend (blue team agents)
- `purple-haze-backend` (atlascyber + red team agents)

**Library structure:**
- `libs/core` - Shared agent framework (state, factory, middleware, streaming)
- `libs/atlas` - Blue team prebuilt agents (tshark analyst)
- `libs/purplehaze` - Red team prebuilt agents (nmap, metasploit)

PurpleHaze is a superset of AtlasCyber (has everything Atlas has + offensive capabilities).

## AtlasCyber Platform Integration Points

When thinking about what agents can access or integrate with:

**API Endpoints** (REST, auth via session):
- `/api/v1/auth/login` - Authentication
- `/api/v1/firm/document/upload` - Upload PCAP/CSV/Zeek files for analysis
- `/api/v1/firm/documents` - List/fetch documents
- `/api/v1/firm/documents/{id}/details` - Document status and details
- `/api/v1/firm/document/{id}/graphite` - Graphite visualization
- `/api/v1/graphite/launch` - Fast graphite analysis job

**Data Types Supported**:
- PCAP (packet capture)
- NetFlow
- CSV (specific format required)
- Zeek files

**Platform Modules** (potential agent interaction points):
- **Cases** - Create, manage, track investigations (MITRE ATT&CK aligned)
- **Graphite** - Graph-theory based anomaly detection for suspicious communication patterns
- **IOCs** - Indicators of Compromise management (create, share, view)
- **ClemAI** - Existing AI engine for threat analysis and natural language interaction
- **Raw Sensor Data** - Upload and review, create cases from alerts
- **SOAR Dashboard** - Case data tracking
- **Infrastructure** - Network device tracking

**Workflow**: Upload data → AI analysis → Case creation → Investigation → IOC sharing

## When This Context Matters

- Deciding what goes in `libs/atlas` vs `libs/purplehaze`
- Understanding deployment constraints (air-gapped SCIFs)
- Writing user-facing documentation
- Architectural decisions that depend on trust models (gov vs commercial)
- Understanding why certain security constraints exist
- **Designing agent tools that integrate with AtlasCyber platform**

$ARGUMENTS
