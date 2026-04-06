# Hardware

## Machine

| Component | Detail |
|-----------|--------|
| Model | 2017 iMac 21.5" Retina 4K (A1418) |
| CPU | Intel Core i5 Quad-Core 3GHz |
| RAM | 8GB DDR4 2400MHz |
| GPU | Radeon Pro 555 2GB |

## RAM Upgrade Path

- 2 SO-DIMM slots, upgradeable to 32GB (2×16GB)
- Required before deploying Ollama / local LLM inference
- Not needed for indexing, retrieval API, or MCP server

## Network Interfaces

| Interface | Role |
|-----------|------|
| wlp2s0 | WiFi — active, static 192.168.1.9 |
| nic0 | Ethernet — unused, available as fallback |
| nic1 | Physical — unused |
| vmbr0 | Virtual bridge — 192.168.100.2/24, internal VM network |
