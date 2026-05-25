## Trade-Off Analysis — WebSearchProvider abstraction: Tavily vs SearXNG to decouple web search from Ant...

**Recommendation:** `hybrid: Tavily as primary WebSearchProvider, SearXNG as registered fallback provider`

For Prismo's prior-art and feasibility research use case, Tavily's LLM-optimized structured output, 93.3% SimpleQA accuracy, built-in relevance scoring, and zero CAPTCHA failure modes make it the far stronger primary provider — the abstraction boundary goal is still fully achieved since Tavily integrates as a thin REST adapter with no Anthropic coupling. SearXNG should be implemented as a second concrete `WebSearchProvider` registered in the provider registry for cost fallback when Tavily rate limits are hit, for privacy-sensitive queries, and to leverage its academic engine categories (Semantic Scholar, arXiv) that Tavily's general web index under-weights. The hybrid also future-proofs against the Nebius acquisition uncertainty: if Tavily pricing shifts post-acquisition, SearXNG on the existing Proxmox VM becomes the zero-cost primary with no interface changes required. CAPTCHA risk is mitigated by keeping SearXNG as a secondary path at low query volume.

## Findings

## WebSearchProvider Abstraction: Tavily vs SearXNG

### Context: Why This Matters for Prismo
Prismo's `/synthesis/analyze` currently uses Anthropic's native `web_search_20250305` tool, which violates the SynthesisProvider abstraction boundary (Decision 015). A proper `WebSearchProvider` abstraction mirrors the `EmbeddingProvider`/`SynthesisProvider` patterns: a typed interface with `search(query, options) -> SearchResult[]` contracts, swappable concrete implementations, and no Anthropic API coupling.

---

### Option 1: Tavily

#### Strengths
- **Purpose-built for AI RAG pipelines.** Tavily returns clean, structured, LLM-ready results with per-result relevance scores, full-text extraction, and citations in a single API call — unlike raw SERP APIs that require a separate extraction layer. It is explicitly described as returning "content snippets, summaries, and citations ready for AI consumption."
- **Benchmarked retrieval quality.** Tavily achieved 93.3% accuracy on OpenAI's SimpleQA benchmark using only real-time web retrieval, claiming state-of-the-art (SOTA) performance on that benchmark as well as GAIA and DeepResearch benchmarks.
- **Production-scale SLAs.** Tavily handles 100M+ monthly requests at 99.99% uptime with a p50 latency of 180ms on search. The Production tier supports up to 1,000 RPM.
- **SOC 2 certified, zero data retention.** Enterprise compliance artifacts are available. Tavily's credit model and rate limits are explicit and operationally transparent.
- **Strong ecosystem integration.** Trusted by 1M+ developers; native integrations in LangChain (`TavilySearchResults`), IBM WatsonX, AWS Bedrock Strands Agents, Databricks MCP Marketplace, and MCP protocol. This makes the `WebSearchProvider` adapter trivially thin.
- **search_depth parameter.** The `search_depth='advanced'` parameter retrieves higher-quality, contextually aligned content optimized for LLM consumption — directly relevant for prior-art and feasibility use cases.

#### Weaknesses
- **Vendor dependency + acquisition risk.** Nebius acquired Tavily in February 2026, raising "questions about the platform's future roadmap, pricing stability, and data handling under new ownership."
- **Cost at scale.** Paid plans start at $30/month for 10K credits (~$0.003/search at volume), scaling to $500/month for 500K credits. The free tier of 1,000 credits/month depletes quickly in research-heavy workflows: one real user reported "Tavily's free tier ran out fast when I was doing extensive research on multiple topics."
- **No content extraction bundled at free tier.** Tavily's built-in URL extraction (`Extract`) is a separate credit charge.
- **Weaker on very-recent/local queries.** In one small benchmark (8 factual questions about recent events), Tavily finished last behind Perplexity, Exa, and Gemini. The methodology note: "Tavily and Exa are often stronger on broader research tasks (multi-hop questions, technical docs, long-form summarization)" — precisely what prior-art and feasibility analysis requires.

---

### Option 2: SearXNG (Self-Hosted on Proxmox)

#### Strengths
- **Zero per-query cost.** The API fee is zero — you pay only for the VPS/VM, typically $5–10/month on shared infrastructure. On a Proxmox VM already provisioned, marginal cost is near-zero.
- **No vendor lock-in or acquisition risk.** AGPL-licensed, community-maintained, no external dependency beyond your own infrastructure.
- **Aggregates 70–230+ sources.** Queries Google, Bing, DuckDuckGo, Brave, Wikipedia, Semantic Scholar, GitHub, and many others simultaneously. Academic and science categories are particularly relevant for prior-art research.
- **JSON API is first-class.** Enabling `format: json` in `settings.yml` exposes a clean REST endpoint: `GET /search?q=...&format=json`. LangChain ships a `SearxSearchWrapper`. Migration from Tavily requires "a few lines."
- **Minimal hardware footprint.** Requires 512MB RAM minimum (2GB recommended), ~300MB Docker image, runs fine as a single container + Redis (Valkey) sidecar. Proxmox LXC container or lightweight VM is sufficient.
- **Provider-agnosticism.** SearXNG is already a native `web_search` provider in agent frameworks like OpenClaw, and is used as a Tavily fallback in multi-provider setups.
- **Community evidence of quality parity.** At least one production team reported: "using searXNG and crawl4AI has amazing network search results, sometimes even better than Tavily" — specifically in contexts where private deployment was required.

#### Weaknesses
- **CAPTCHA/rate-limiting is the primary production failure mode.** SearXNG proxies requests through upstream engines. Google, Bing, and DuckDuckGo actively block scraping: "SearXNG passes through requests from bots and is thus classified as a bot itself" — triggering CAPTCHAs. A real GitHub issue from an AI agent project (AgenticSeek) documents SearXNG encountering CAPTCHA challenges across DuckDuckGo and Qwant, "severely impacting search functionality." The production guidance is explicit: "If your SearXNG instance works beautifully for a week and then slowly turns into a CAPTCHA magnet...the problem is that private metasearch only stays private and useful when three layers stay disciplined at the same time."
- **Ongoing operational overhead.** Requires configuring Valkey/Redis, a reverse proxy (Nginx/Caddy), HTTPS, rate limit tuning, engine suspension policies, and periodic CAPTCHA remediation via SSH SOCKS tunneling. This is documented in SearXNG's own admin guides as necessary, not optional.
- **No LLM-optimized output preprocessing.** SearXNG returns raw aggregated SERP snippets. The `WebSearchProvider` implementation must normalize, deduplicate, score relevance, and format results for LLM consumption — work Tavily does automatically.
- **No content extraction.** Unlike Tavily's `Extract`, SearXNG only returns SERP snippets and URLs. Full-page content retrieval requires a separate tool (Crawl4AI, Firecrawl, Jina Reader), adding pipeline complexity.
- **AGPL license implications.** Integrating SearXNG in a proprietary product may require legal review of AGPL copyleft obligations, depending on how the service boundary is drawn.

---

### WebSearchProvider Interface Design

The ideal provider-agnostic interface mirrors the pattern proposed in LangChain's community discussions for a `SearchAPIWrapperBase`:

```python
# core/providers/web_search.py
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional

@dataclass
class WebSearchResult:
    title: str
    url: str
    snippet: str
    score: Optional[float] = None  # relevance score, provider-dependent
    raw_content: Optional[str] = None  # full extracted text, if available

@dataclass
class WebSearchOptions:
    max_results: int = 5
    search_depth: str = "basic"  # "basic" | "advanced"
    include_domains: list[str] = None
    exclude_domains: list[str] = None
    topic: str = "general"  # "general" | "news" | "academic"

class WebSearchProvider(ABC):
    """Provider-agnostic interface for web search retrieval."""

    @abstractmethod
    async def search(
        self,
        query: str,
        options: WebSearchOptions | None = None
    ) -> list[WebSearchResult]:
        """Execute a search query and return structured results."""
        ...

    @property
    @abstractmethod
    def provider_name(self) -> str:
        """Returns the canonical provider identifier (e.g., 'tavily', 'searxng')."""
        ...

# Concrete adapters:
# providers/web_search/tavily.py  -> TavilyWebSearchProvider(WebSearchProvider)
# providers/web_search/searxng.py -> SearXNGWebSearchProvider(WebSearchProvider)
# providers/web_search/anthropic_native.py -> AnthropicNativeWebSearchProvider(WebSearchProvider)  [legacy shim]
```

This follows the exact pattern of `EmbeddingProvider`/`SynthesisProvider` — a dataclass for options, a dataclass for results, an abstract base with a single `search()` method, and concrete implementations per backend. The `synthesis/analyze` handler calls `self.web_search_provider.search(query, options)` with no awareness of which backend is active.

---

### Head-to-Head Summary

| Dimension | Tavily | SearXNG |
|---|---|---|  
| Retrieval quality for prior-art/feasibility | ★★★★★ Structured, LLM-optimized, SOTA benchmarks | ★★★☆☆ Raw SERP snippets, no relevance scoring |
| Operational reliability | ★★★★★ 99.99% SLA, managed infrastructure | ★★☆☆☆ CAPTCHA/blocking is a documented persistent failure mode |
| Cost structure | ~$0.003–0.01/search at volume; free tier thin | ~$0 per query; Proxmox VM already provisioned |
| Integration effort | ★★★★★ Thin adapter, existing LangChain wrapper | ★★★☆☆ Requires output normalization, separate extraction layer |
| Provider agnosticism | Full (REST API, no Anthropic coupling) | Full (REST API, no Anthropic coupling) |
| Self-sovereignty / no vendor lock-in | ★★☆☆☆ Acquired by Nebius Feb 2026 | ★★★★★ AGPL, fully self-hosted |
| Proxmox deployment complexity | N/A (SaaS) | Low hardware req, medium ops burden (Valkey + reverse proxy + CAPTCHA mgmt) |
| Content extraction | Built-in (Extract API) | Requires separate tool |
| Academic/prior-art source depth | Web-focused | ★★★★☆ Semantic Scholar, Google Scholar, Wikipedia, arXiv via engine config |

## Sources

- https://blog.tavily.com/tavily-evaluation-part-1-tavily-achieves-sota-on-simpleqa-benchmark/
- https://www.everydev.ai/tools/tavily
- https://websearchapi.ai/blog/compare-tavily-google-search-exa-perplexity
- https://websearchapi.ai/blog/tavily-alternatives
- https://alphacorp.ai/blog/perplexity-search-api-vs-tavily-the-better-choice-for-rag-and-agents-in-2025
- https://www.humai.blog/tavily-vs-exa-vs-perplexity-vs-you-com-the-complete-ai-search-api-comparison-2025/
- https://codenote.net/en/posts/tavily-alternatives-cost-comparison-search-extract-api/
- https://docs.bswen.com/blog/2026-03-26-tavily-vs-searxng-opencode/
- https://github.com/searxng/searxng/discussions/4637
- https://railway.com/deploy/searxng-search-api
- https://medium.com/@rosgluk/selfhosting-searxng-a3cb66a196e9
- https://dasroot.net/posts/2026/03/self-hosted-search-searxng-installation-configuration/
- https://www.serverspan.com/en/blog/searxng-on-a-vps-how-to-run-private-search-without-getting-rate-limited-into-uselessness
- https://github.com/Fosowl/agenticSeek/issues/410
- https://docs.searxng.org/admin/searx.limiter.html
- https://github.com/langchain-ai/langchain/discussions/19782
- https://www.firecrawl.dev/blog/best-openclaw-search-providers
- https://sparkco.ai/blog/tavily-ai-search
- https://exa.ai/versus/tavily

*confidence: 0.88 | analysis_type: trade_off*