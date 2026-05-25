## Feasibility Analysis — DSPy for prompt optimization in synthesis-service

**Recommendation:** `feasible_with_constraints`

DSPy integrates natively with Anthropic Claude (confirmed in official docs and multiple production examples), and classification/artifact-type routing is one of DSPy's strongest demonstrated use cases — making the core technical approach sound. However, the team's primary blocker is dataset size: with only 2 labeled wrong-artifact-type examples from one observation week, the team is well below the 30-example minimum recommended for reliable optimization, and must either expand the labeling window, use BootstrapFewShot with synthetic augmentation, or accept that early-stage optimization will be noisy. The ReviewItem human-judgment architecture is not in conflict with DSPy — in fact the Explosion AI / Prodigy workflow proves that human review labels feeding DSPy Examples is a best-practice pattern — but it requires formalizing the metric function to map ReviewItem rejection reasons to a scalar optimization signal before any compiler run can proceed.

## Findings

## What Others Have Built

### Anthropic/Claude + DSPy Integration
DSPy's native `dspy.LM` interface supports Anthropic Claude directly out of the box. Official DSPy docs show `dspy.LM('anthropic/claude-sonnet-4-6', api_key='...')` as a first-class configuration path, with `ANTHROPIC_API_KEY` as an accepted env var. Production examples (Towards Data Science, Databricks notebooks, dbreunig blog) all confirm working Claude integrations via `dspy.configure(lm=dspy.LM('anthropic/claude-3-5-sonnet-...'))`. DSPy routes through LiteLLM internally, so the native Anthropic Python SDK is **not** called directly — DSPy manages its own HTTP layer. This means the `anthropic` SDK running in synthesis-service and DSPy can coexist without conflict as long as they don't share client state. One historical caveat: an older GitHub issue (#1150) noted DSPy didn't support Claude 3+ on **Amazon Bedrock** via the Messages API, but this was a Bedrock-specific routing bug, not a direct-API issue, and is now resolved in modern DSPy versions.

### Classification / Artifact-Type Tasks
DSPy has been extensively applied to classification-style tasks — precisely the shape of `wrong-artifact-type` rejection. The AdalFlow benchmark and Haystack cookbook both demonstrate DSPy `Signature`-based classification with typed `OutputField` enum constraints. A multi-use-case study (University of Minho, 2025) applied DSPy to a **routing agent** use case (analogous to artifact-type routing), raising accuracy from 85% to 90%. For prompt evaluation criteria tasks, accuracy jumped from 46.2% to 64.0%. Results are task-dependent: classification tasks with crisp right/wrong labels are among DSPy's strongest use cases.

### Human-in-the-Loop + DSPy (ReviewItem Architecture)
This is the most directly relevant precedent for Prismo's `ReviewItem` architecture. Explosion AI (Prodigy) published a full workflow where human annotations feed directly into DSPy optimization loops as `dspy.Example` objects, achieving ~26% improvement on a human-aligned LLM-judge metric after optimization. Critically, Prodigy docs state **DSPy recommends minimally 30 and optimally 300 labeled examples** for best optimizer results. The Towards Data Science case study explicitly validates that `DSPy optimization can be especially powerful [when] the LLM judge alignment process typically requires a human in the loop to generate labelled data`. The DSPy 3.0 roadmap explicitly lists "new optimizers that prioritize ad-hoc, human-in-the-loop feedback" as the primary forthcoming paradigm shift — confirming the current gap but also the direction of travel.

### Optimizer Selection & Dataset Requirements
- **LabeledFewShot**: Requires only `k` labeled examples; lowest barrier, good starting point.
- **BootstrapFewShot**: Uses a teacher/student pattern to synthesize additional demos from a small trainset; usable with ~10–20 labeled examples.
- **BootstrapFewShotWithRandomSearch**: Recommended at 50+ examples.
- **MIPROv2**: Full instruction + few-shot joint optimization; most powerful but most expensive. A reference run (BootstrapFewShotWithRandomSearch, gpt-3.5, 7 candidates, 10 threads) cost ~$3 USD and took ~6 minutes with 3,200 API calls.
- Optimization cost with Claude Sonnet/Opus will be meaningfully higher per token than gpt-3.5.

## What Was Hard in Practice

### 1. Metric Definition is the Critical Bottleneck
Every practitioner report identifies metric design as the hardest part. `48-10`: "the quality of any automated optimization is fundamentally limited by the quality of the metric guiding it." For `wrong-artifact-type`, a metric is achievable (correct artifact class = 1, wrong = 0), but the boundary cases — where human judgment is the authoritative signal — are exactly what DSPy needs labeled examples of to optimize against. Using ReviewItem rejection labels directly as the metric signal is the correct approach, but curating enough clean examples from 5 observed rejections is insufficient.

### 2. Small Dataset Problem
With only a 1-week observation window yielding 2/5 wrong-artifact-type rejections, the team has far fewer than the 30-example minimum Prodigy/DSPy documentation recommends. BootstrapFewShot can partially compensate by synthesizing additional demonstrations, but with very small seed sets the bootstrapped demos may not cover the full artifact-type distribution.

### 3. Metric Gaming / Proxy Drift
The Towards Data Science case study documents a concrete failure mode: DSPy optimization pushed generator outputs toward longer, more polite responses because the LLM judge was biased toward length — not because quality improved. For synthesis-service, if the metric is defined as "not rejected by human reviewers" but human reviewers are inconsistent, the optimizer will find prompt configurations that satisfy the proxy metric rather than ground truth quality.

### 4. Refactoring Cost (analyze.py)
Migrating hand-rolled prompt templates in `analyze.py` to DSPy `Signature` + `Module` patterns is a non-trivial rewrite. DSPy's structured output parsing, typed fields, and adapter layer replace the existing string interpolation. The existing `web_search` tool call pattern in synthesis-service may require wrapping as a `dspy.Tool` or `dspy.ReAct` module to remain compatible with the compiled optimizer loop.

### 5. Threading/Async Constraints
DSPy's `dspy.configure()` can only be called once per thread/task (subsequent calls from other threads raise `RuntimeError`). If synthesis-service is async (e.g., FastAPI), the configure call must happen at startup, and per-request overrides must use `dspy.context()`. This is a known footgun for async services.

### 6. Optimization Runtime Cost
Each optimizer run makes many LM calls (hundreds to thousands). With Claude Sonnet as the task model, a single MIPROv2 light run could cost $10–30 USD. This is a one-time compile cost, but it needs to be re-run whenever the underlying model, task, or training data changes.

## Constraints & Constraints Summary
| Constraint | Severity | Notes |
|---|---|---|
| Anthropic SDK compatibility | Low | DSPy native support confirmed; coexistence with existing `anthropic` client is fine |
| `web_search` tool in DSPy | Medium | Must be wrapped as a DSPy tool or ReAct module; cannot be a raw SDK call inside a Signature |
| ReviewItem human-judgment loop | Medium | Human labels ARE the correct metric signal; workflow is proven but requires 30+ curated examples |
| Dataset size (2/5 examples) | High | Far below minimum; bootstrapping partially compensates but is insufficient alone |
| Metric definition for artifact type | Medium | Classification metrics are straightforward; boundary cases need human labels |
| analyze.py rewrite | Medium | ~1–3 days of refactor to DSPy Signatures; low risk but not zero |
| Optimization cost (Claude) | Low-Medium | One-time compile cost; manageable if run infrequently |

## Sources

- https://dspy.ai/api/utils/configure/
- https://github.com/stanfordnlp/dspy/blob/main/docs/docs/learn/programming/language_models.md
- https://arxiv.org/abs/2507.03620
- https://towardsdatascience.com/systematic-llm-prompt-engineering-using-dspy-optimization/
- https://explosion.ai/blog/human-aligned-llm-evaluation-dspy
- https://prodi.gy/docs/dspy
- https://dspy.ai/learn/optimization/optimizers/
- https://dspy.ai/faqs/
- https://notebooks.databricks.com/devrel/mlflow/2024-11-27-dspy.html
- https://github.com/stanfordnlp/dspy/issues/1150
- https://www.ibm.com/think/topics/dspy
- https://dspy.ai/roadmap/
- https://myengineeringpath.dev/tools/dspy-guide/
- https://adalflow.sylph.ai/use_cases/classification.html

*confidence: 0.88 | analysis_type: feasibility*