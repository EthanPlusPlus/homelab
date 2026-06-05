---
id: "034"
title: Phase 6 — observability layer architecture and infra/application metrics boundary
status: active
record_type: canonical
category: architecture
date: 2026-06-05
---

# Decision 034 — Phase 6 observability layer architecture and infra/application metrics boundary

## Status
Active — shipped 2026-06-05.

## Date
2026-06-05

## Context

Phases 0–5 are complete. Decision 031 named Phase 6 as a background track alongside
Phase 5 (web UI), with Prometheus / Grafana / Loki as the named stack. Decision 032
established the single docker-compose constraint and portability requirements.

The Phase 6 technology choices were already made. What was missing was the architectural
boundary: what Prometheus observes vs what `GET /workflow/metrics` observes. Without
naming this boundary, infra alerting and cognitive health monitoring would silently merge
— a Law 1 / Law 2 violation (structural truth is deterministic; interpretation is
probabilistic).

## Decision

### The infra / application metrics boundary is a hard layer separation

**Infrastructure metrics (Prometheus):** Is the service up? Is latency acceptable?
Are error rates spiking? These are purely Law 1 — deterministic thresholds, no
interpretation. Prometheus owns this layer.

**Application metrics (`GET /workflow/metrics`, web UI):** Is the synthesis loop
working? What is the ReviewItem approval rate? What is the capture emission cadence?
These are operational cognition measurements. They are Law 1-safe as counts and ratios,
but they answer questions about Prismo's cognitive health, not its infrastructure health.
The web UI is the right consumer — not Prometheus.

**The violation to prevent:** Alerting on synthesis emission rate, ReviewItem approval
rate, or doctrine violation counts via Prometheus threshold rules embeds judgment
(what is "low enough" to be anomalous?) into infrastructure alerting. This belongs in
synthesis-service (Law 2), not alerting rules. Phase 6 does not cross this boundary.

### Phase 6 slice 1 — build specification

#### 1. `/metrics` endpoint on context-server

`prometheus-fastapi-instrumentator` added to `requirements.txt`. Auto-instruments all
FastAPI routes with standard metrics. One integration point in `main.py` — no coupling
to domain modules (synthesis, doctrine, pipeline, workflow).

Metrics exposed:
- `http_requests_total` — labeled by route, method, status code
- `http_request_duration_seconds` — histogram, labeled by route

Exempt from Service Rule enforcement (metrics endpoint is infrastructure, not a
capability-contract route).

#### 2. Prometheus in docker-compose

`prom/prometheus` service added to `context-server/docker-compose.yml`. Configuration
file (`prometheus.yml`) committed to the context-server repo — no machine-specific
setup, portability preserved. Scrapes `api:8000/metrics` on 15s interval.

#### 3. Loki + Promtail in docker-compose

`grafana/loki` + `grafana/promtail` services. Promtail reads Docker container logs
via Docker socket — zero code changes in any application service. Captures logs from
all compose services: api, mcp, ui, postgres, and the observability services themselves.

#### 4. Grafana in docker-compose

`grafana/grafana` service. Datasources (Prometheus + Loki) and starter dashboard
provisioned via config files committed to the repo. Fresh `docker compose up` produces
a working Grafana instance with no manual setup.

Starter dashboard panels:
- Request rate by route (top 10)
- Latency p50 / p95 / p99 by route
- Error rate (5xx) by route
- Log stream (all services, filterable by service label)

#### 5. Alerting — Grafana alert rules

Alertmanager is not used at this scale. Grafana alert rules are sufficient for
single-server, single-operator operation.

Initial alert rules (all threshold-based, Law 1 safe):
- API service unreachable — Prometheus scrape fails >2 minutes
- Error rate >5% on any route — 5-minute window
- p99 latency >2s on any route — 5-minute window

### What is explicitly out of scope for Phase 6

- Prometheus metrics for synthesis emission rate, ReviewItem approval rates, doctrine
  violation counts — these stay at `GET /workflow/metrics`, consumed by the web UI
- Alertmanager — premature overhead for current operational scale
- Custom Prometheus exporters — `prometheus-fastapi-instrumentator` + Promtail cover
  the required signal without app-layer coupling
- Cognitive health alerting — "synthesis loop is underperforming" is a judgment,
  not a threshold. Out of scope until synthesis-service can express its own health signal

## Rationale

- Law 1 / Law 2 boundary requires infra metrics and cognitive health metrics to live
  at different layers and be consumed by different surfaces
- Prometheus + Grafana + Loki is already the named stack (Decision 031) — this decision
  records the boundary and build spec, not the technology choice
- All Phase 6 services join the single docker-compose (Decision 032 step 3) — no
  parallel compose, no machine-specific setup
- Portability preserved: all config files committed to repo, env-var-driven,
  Tailscale-independent

## Consequences

- `prometheus-fastapi-instrumentator` added to context-server dependencies
- `prometheus.yml`, Loki config, Promtail config, and Grafana provisioning files
  committed under `context-server/observability/`
- docker-compose gains 4 new services: prometheus, loki, promtail, grafana
- Grafana accessible at port 3001 (3000 is prismo-ui)
- `/metrics` route exempt from Service Rule enforcement — documented in
  `capability-contracts.md` with an explicit infra-exemption note
- Future cognitive health alerting (if needed) goes through synthesis-service, not
  Prometheus — a capture should be created if this becomes a recurring ask

## Related

- [[031-web-ui-operational-visibility-forcing-function|Decision 031]] — named Phase 6
  as a background track; web UI as primary visibility layer
- [[032-portability-as-commercial-grade-constraint|Decision 032]] — single compose,
  portability requirements
- [[017-three-architectural-laws|Decision 017]] — Law 1 (deterministic) vs Law 2
  (probabilistic) boundary that this decision enforces in alerting
- [[025-runtime-intelligence-layer-topology|Decision 025]] — runtime topology; infra
  health and runtime cognition health are different concerns
