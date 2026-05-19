## Prior Art Analysis — chatgpt and claude prompt forwarding and switching

**Recommendation:** `adopt`

The core problem of forwarding and switching prompts between ChatGPT and Claude APIs is comprehensively solved by LiteLLM (open-source, 40K stars, battle-tested in production at scale) and OpenRouter (managed, 400+ models, Auto Router with NotDiamond). Building a custom solution would replicate years of community hardening around fallback logic, API schema translation, streaming support, cost tracking, and security. The only justifiable reasons to build would be (1) requiring auditable/deterministic intelligent routing beyond what existing tools offer, (2) needing real-time stateful context synchronization across providers, or (3) proprietary prompt-style translation logic — none of which constitutes prompt forwarding/switching itself, but rather an extension layer on top of existing gateways.

## Findings

## Prior Art Analysis: ChatGPT & Claude Prompt Forwarding and Switching

### 1. Problem Space Definition

This capability covers two overlapping concerns:
- **Programmatic prompt forwarding/switching**: Routing prompts dynamically between OpenAI (ChatGPT) and Anthropic (Claude) APIs at the infrastructure or application layer.
- **User-level context/memory migration**: Transferring conversation context, memory, and system prompts from one platform to the other.

Both sub-problems are **heavily solved** with a rich ecosystem of existing tools, hosted services, academic research, and first-party provider features.

---

### 2. Existing Tools & Libraries

#### LiteLLM (Most Dominant OSS Solution)
- Open-source Python SDK and self-hosted AI Gateway providing a **single OpenAI-compatible interface to 140+ LLM providers**, including OpenAI and Anthropic. Handles model routing, fallbacks, cost tracking, load balancing, caching, and observability while eliminating vendor-specific code.
- As of March 2026, ~40K GitHub stars, 1,300+ contributors, 240M+ Docker pulls, and has powered over 1 billion production requests.
- Supports fallback chains (e.g., Anthropic → OpenAI → Ollama), latency-based routing, budget limits per team/key, and a full admin dashboard.
- Known failure mode: A documented supply chain security incident required network isolation as a mitigation. Self-hosting means teams own deployment, scaling, and monitoring.

#### OpenRouter
- Managed hosted gateway that provides a unified API endpoint across 400+ models. Includes an **Auto Router** (`openrouter/auto`) powered by NotDiamond that analyzes each prompt and selects the optimal model based on complexity and task type, routing transparently between Claude, GPT, Gemini, DeepSeek, and others.
- Also offers a **Pareto Router** for coding-specific model selection and **Presets** (named configurations that decouple LLM config from application code, covering system prompts, provider routing, and model selection).
- Known failure mode: Auto-routing is stochastic — routing decisions cannot be audited, reproduced, or easily debugged in production. The router's internal logic can drift silently.

#### Bifrost (Go-based alternative to LiteLLM)
- Go-based LLM gateway focused on ultra-high concurrency; benchmarked as significantly faster than LiteLLM under load. Implements ordered provider fallback (OpenAI → Anthropic → OpenRouter) with standard OpenAI-compatible response format including a metadata field indicating which provider actually handled the request.

#### lm-proxy / LLM-API-Key-Proxy (Lightweight OSS proxies)
- OpenAI-compatible HTTP proxies built on FastAPI/Python that route requests to OpenAI, Anthropic, or Google based on model name patterns in the request. Support virtual API key management and drop-in replacement for OpenAI client libraries.

#### openziti/llm-gateway (Zero-trust semantic routing)
- OpenAI-compatible proxy implementing a **three-layer cascade** (keyword heuristics → embedding similarity → LLM classifier) to select the best model when the client omits the model field. Designed for air-gapped and NAT-traversal environments.

---

### 3. First-Party Provider Features

#### Anthropic's Native Import Tool
- Anthropic launched `claude.com/import-memory` — a first-party memory import feature that generates a prompt users paste into ChatGPT, which produces a context summary that is then pasted back into Claude's memory system. Available to free-tier users as of March 2026.

#### OpenAI's GPT-5 Internal Model Router
- GPT-5 within ChatGPT runs on a system of models coordinated by a behind-the-scenes router that switches to deeper reasoning when needed, with multiple model variants (gpt-5-main, gpt-5-main-mini, gpt-5-thinking, etc.) and automatic routing between them — setting a precedent for opaque internal model switching.

#### AI Context Flow / AI Migrator (Third-party portability tools)
- Browser extensions and MCP-server-based tools (e.g., AI Context Flow, AI Migrator) that create portable context profiles transferable across Claude, ChatGPT, Gemini, and Perplexity — addressing user-level prompt and memory forwarding across providers.

---

### 4. Academic / Research Landscape

- **RouteLLM** (LMSYS/Chatbot Arena): Pre-trained routers for directing prompts between strong and weak models to cut cost; effectively deprecated as of August 2024, with the team shifting focus to Chatbot Arena benchmarks.
- **LLMRank** (Zeno AI, Sep 2025): Prompt-aware routing framework using human-readable features (task type, reasoning complexity, syntactic cues) extracted from prompts to select among models.
- **ZOOTER**: Uses reward distillation to train a routing function predicting which model is optimal per query without generating outputs from all candidates.
- **UniRoute** (ICLR 2025): Cluster-based and learned-cluster-map routing that generalizes to 30+ unseen LLMs without task labels.
- **NadirClaw** (May 2026): Local prompt classification using centroid vectors/encoders to avoid high-cost model calls for simple tasks, with demonstrated cost savings over always-using-the-largest-model.
- Academic consensus: Routing is a well-formalized subproblem with open challenges in **interpretability, generalization across new models, and cost-awareness**.

---

### 5. Established Patterns & Best Practices

- **Unified OpenAI-compatible endpoint**: The de facto standard — all major gateways (LiteLLM, OpenRouter, Bifrost, lm-proxy) expose an OpenAI-format `/chat/completions` endpoint, meaning migration requires only changing `base_url` and `api_key`.
- **API schema fragmentation is the core problem**: OpenAI uses `messages` with `role/content`; Anthropic uses `messages` with a separate `system` parameter; Google Gemini uses `contents` with `parts`. Any forwarding/switching layer must handle this translation.
- **Routing strategies**: Three tiers are well-documented — (1) rule-based (keyword/length heuristics, fast but brittle); (2) embedding/semantic similarity (moderate latency, better generalization); (3) LLM-as-classifier (highest accuracy, adds latency and cost).
- **Fallback chains**: Production best practice is ordered fallback (e.g., Anthropic 429/500 → GPT-4o → local Ollama) with cooldown periods to prevent cascade failures.
- **Context portability**: Best practice for users running both models is a portable context document (system prompt / project instructions) uploaded to whichever provider is in use, rather than relying on platform-native memory.
- **Cost-based routing threshold**: Below ~1,000 queries/day, routing complexity often exceeds savings. Above ~10,000 queries/day, routing saves real money and forces architectural clarity.

---

### 6. Known Failure Modes & Lessons from Others

- **Cold-start latency misconfiguration**: Local model fallback triggered unnecessary cloud escalations because default timeouts (5s) didn't account for Ollama cold-start (5–10s). Fix: increase timeout to 15s or implement warm-up cron jobs.
- **Stochastic auto-routing in production**: OpenRouter's Auto Router is convenient but routing decisions are non-deterministic, non-auditable, and subject to drift. Recommended production alternative: benchmark task categories and build a deterministic routing map.
- **Context migration is lossy**: Anthropic's import tool produces a surface-level summary. Full conversation history exports from ChatGPT are not directly ingestable by Claude without preprocessing. Platform-native memories are often stale (users retain only 20–30% as accurate).
- **Supply chain risk on shared gateway infrastructure**: LiteLLM experienced a documented supply chain attack. Mitigation: network isolation, egress filtering to LLM provider domains only.
- **MLP routers overfit on small validation samples**: Static routers trained on small labeled sets are prone to overfitting and require frequent, expensive retraining when new models are added.
- **Prompt style incompatibility**: Claude responds differently to certain instruction styles than GPT models; prompts cannot be copied directly across providers without adaptation, especially around word count targets, format instructions, and system prompt structure.

---

### 7. Novelty Assessment

**The space is crowded.** Programmatic prompt forwarding and switching between ChatGPT and Claude is thoroughly solved at the infrastructure layer (LiteLLM, OpenRouter, Bifrost, lm-proxy), at the managed service layer (OpenRouter, Portkey, Inworld Router), and increasingly at the first-party provider layer (Anthropic's native import, OpenAI's internal GPT-5 router). Academic routing research (RouteLLM, LLMRank, ZOOTER, UniRoute, NadirClaw) addresses intelligent prompt-based model selection with increasing sophistication. The only areas with remaining open problems are: (1) production-grade interpretable/auditable auto-routing, (2) prompt-style-aware translation between model families (not just API format translation), and (3) stateful context synchronization across providers in real-time (as opposed to one-time migration).

## Sources

- https://github.com/BerriAI/litellm
- https://a2a-mcp.org/blog/what-is-litellm
- https://openrouter.ai/docs/guides/routing/routers/auto-router
- https://openrouter.zendesk.com/hc/en-us/articles/47463293706395-What-is-the-Auto-Router-and-how-does-it-choose-a-model
- https://openrouter.ai/docs/guides/features/presets
- https://inworld.ai/resources/best-llm-router-ai-gateway
- https://www.morphllm.com/llm-gateway
- https://github.com/openziti/llm-gateway
- https://github.com/Nayjest/lm-proxy
- https://github.com/Mirrowel/LLM-API-Key-Proxy
- https://dev.to/crosspostr/implementing-automatic-llm-provider-fallback-in-ai-agents-using-an-llm-gateway-openai-anthropic-kg2
- https://medium.com/@michael.hannecke/implementing-llm-model-routing-a-practical-guide-with-ollama-and-litellm-b62c1562f50f
- https://www.swfte.com/blog/intelligent-llm-routing-multi-model-ai
- https://www.mindstudio.ai/blog/what-is-ai-model-router-optimize-cost-llm-providers
- https://medium.com/google-cloud/a-developers-guide-to-model-routing-1f21ecc34d60
- https://fortune.com/2025/08/12/openai-gpt-5-model-router-backlash-ai-future/
- https://www.inc.com/ben-sherry/how-to-switch-from-chatgpt-to-claude-with-just-one-simple-prompt/91311046
- https://plurality.network/blogs/switch-from-chatgpt-to-claude/
- https://www.mindstudio.ai/blog/switch-from-chatgpt-to-claude-migration-guide
- https://openrouter.ai/state-of-ai
- https://arxiv.org/pdf/2506.06579
- https://arxiv.org/pdf/2502.08773
- https://openreview.net/pdf?id=ka82fvJ5f1
- https://earezki.com/ai-news/2026-05-10-how-to-build-a-cost-aware-llm-routing-system-with-nadirclaw-using-local-prompt-classification-and-gemini-model-switching/
- https://vllm-semantic-router.com/
- https://developers.redhat.com/articles/2025/05/20/llm-semantic-router-intelligent-request-routing
- https://openmark.ai/choose-ai-model-openrouter
- https://botmonster.com/posts/serve-multiple-llms-single-openai-compatible-api/

*confidence: 0.93 | analysis_type: prior_art*