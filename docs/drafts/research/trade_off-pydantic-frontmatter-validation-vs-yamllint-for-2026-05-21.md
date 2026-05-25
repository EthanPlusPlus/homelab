## Trade-Off Analysis — Pydantic frontmatter validation vs yamllint for doctrine-service metadata reconc...

**Recommendation:** `hybrid: Pydantic (primary, for all schema validation) + yamllint (thin pre-pass, for in-file duplicate key detection and line-precise YAML syntax errors only)`

Pydantic with python-frontmatter is the clear primary engine because yamllint is categorically incapable of schema validation — it cannot detect missing lifecycle fields, invalid statuses, malformed record_type values, or the superseded_by cross-field constraint that are the core of metadata reconciliation. Pydantic's discriminated unions on `record_type` give clean per-type validation without hand-rolled conditionals, and `ValidationError.errors()` produces structured, machine-readable output that downstream reconciliation reporting can consume directly. The recommended hybrid adds yamllint only as a 3-line pre-pass using its Python library API to catch the one thing Pydantic cannot see — in-file duplicate YAML keys that get silently collapsed by PyYAML before Pydantic is invoked — giving both line-precise syntax diagnostics and full schema enforcement without duplicating any logic.

## Findings

## Pydantic Frontmatter Validation vs yamllint for Doctrine-Service Metadata Reconciliation

---

### Option 1: Python-native Pydantic Schema Validation (python-frontmatter + Pydantic models)

**How it works:**
`python-frontmatter` (production/stable, ISC license) parses the `---` YAML delimiters from markdown files and returns a dict of attributes. That dict is passed to a per-`record_type` Pydantic `BaseModel`, which validates field presence, types, enum values, and custom cross-field constraints.

**Strengths:**
- **Full schema enforcement**: Pydantic checks required fields, types, value constraints (e.g., `Literal['active','deprecated','superseded']` for `status`), and cross-field logic. yamllint explicitly cannot do this — it "validates YAML syntax and style but does not validate against schemas" (yamllint man page).
- **Discriminated unions for `record_type` routing**: Pydantic's `Field(discriminator='record_type')` dispatches each doc to the correct sub-model (e.g., `DecisionModel`, `PolicyModel`) in a single, efficient, error-clean call. The Pydantic docs recommend discriminated unions as "more performant and more predictable than untagged unions."
- **Structured, machine-readable error output**: `ValidationError.errors()` returns a list of dicts with `loc` (field path), `msg`, `type`, and `input` — perfect for programmatic downstream reporting. "When validation fails, you get clear, structured error messages not cryptic KeyError or AttributeError exceptions buried in your business logic."
- **Duplicate ID detection (cross-document)**: Pydantic validates per-record; a thin post-validation pass accumulating `id` values across the corpus can detect duplicates. This is custom Python logic, not a Pydantic built-in, but trivially added in the same pipeline.
- **Extensibility**: Adding a new `record_type` means adding a new `BaseModel` subclass and registering it as a `Literal` discriminator arm — no new tooling, no new config format, just Python.
- **Production precedent**: The pattern of `python-frontmatter` → Pydantic model is well-attested in production (blog pipelines, ML config validation, LLM output validation, AI agent skill metadata). The `frontmatter-format` library's author explicitly recommends: "define self-identifiable Pydantic schemas for all your metadata, and then serialize and deserialize them to frontmatter everywhere."
- **YAML type coercion gotcha handling**: Pydantic catches silent YAML coercion errors (e.g., `status: yes` becoming a boolean instead of string) that would pass yamllint entirely. Practitioners note that "if you or your colleague forgets to use this format, the safe_load() method will still read it into your data… you will get a weird error message deep in your code."
- **Model validator for lifecycle rules**: `@model_validator` enables cross-field logic — e.g., "if status is `superseded`, `superseded_by` must be non-null" — impossible to express with yamllint.

**Weaknesses:**
- **No raw YAML syntax feedback before parsing**: If a file has a malformed YAML block that causes `python-frontmatter` itself to throw, the error is a PyYAML scanner exception, not a Pydantic error. This is recoverable with a `try/except` wrapper but adds boilerplate.
- **Duplicate-within-file key detection**: Python's YAML parsers silently collapse duplicate keys in the same frontmatter block before Pydantic ever sees them, so in-file duplicate key detection requires a pre-pass or yamllint as a complementary check.
- **No line number in errors by default**: Pydantic errors reference field names, not line numbers in the source file. For a CLI reporting tool, you'd need to map field names back to the source.

---

### Option 2: yamllint as Pre-indexing Validation + Custom Python Rules

**How it works:**
yamllint runs first to catch YAML syntax/style errors (indentation, trailing spaces, key repetition, line length). Custom Python code then parses the validated YAML and applies hand-rolled checks for required fields, status enums, lifecycle rules, and duplicate IDs.

**Strengths:**
- **Line-number-precise YAML syntax errors**: yamllint outputs `file:line:col error-message`, which is useful for authors fixing malformed frontmatter. It catches indentation errors, duplicate keys within a single file, and truthy-value weirdness at the byte level.
- **Catches key repetition**: yamllint's `key-duplicates` rule detects duplicate YAML keys within a single document before the Python parser collapses them — something Pydantic alone cannot see.
- **Lightweight CI integration**: yamllint integrates trivially into pre-commit and CI pipelines as a standalone CLI check.

**Weaknesses:**
- **Does not validate schemas at all**: This is fundamental and documented. yamllint "validates YAML syntax and style but does not validate against schemas. For schema validation, use tools like ajv or language-specific validators." It cannot detect missing `lifecycle` fields, invalid `status` values, invalid `record_type`, or the relationship between `status: superseded` and a missing `superseded_by`.
- **Custom rules must be reimplemented**: All schema logic (required fields, enum values, cross-field constraints, per-`record_type` differences) must be written as bespoke Python — effectively reimplementing what Pydantic provides out of the box, but without type safety, structured errors, or maintainability.
- **Unstructured error output by default**: yamllint emits human-readable text strings. Custom rule violations require additional formatting code to produce structured output for downstream consumers.
- **Extension is costly**: Adding a new `record_type` means updating hand-rolled conditional logic. No discriminator pattern, no type safety, no schema-as-code.
- **Two-tool complexity**: The yamllint + custom rules approach requires maintaining two separate validation layers with no unified error model.
- **Real-world precedent on schema limits**: Practitioners exploring this path consistently conclude yamllint is insufficient alone and reach for a schema tool: "The former [syntax] can be achieved by using a linting tool like yamllint. The latter [schema] with a library like Yamale, which is what we went with."

---

### Dimension-by-dimension comparison

| Dimension | Pydantic + python-frontmatter | yamllint + custom rules |
|---|---|---|
| **Missing lifecycle fields** | ✅ Native (required fields in BaseModel) | ❌ Must hand-code |
| **Invalid status values** | ✅ Native (`Literal[...]`) | ❌ Must hand-code |
| **Malformed YAML syntax** | ⚠️ Via PyYAML exception (needs try/except) | ✅ Line-precise error |
| **In-file duplicate YAML keys** | ❌ Parser collapses before Pydantic sees it | ✅ `key-duplicates` rule |
| **Duplicate IDs across docs** | ⚠️ Custom post-pass (trivial Python set) | ⚠️ Custom (same effort) |
| **Per-record_type schema routing** | ✅ Discriminated unions, one call | ❌ Manual if/else |
| **Cross-field constraints** | ✅ `@model_validator` | ❌ Must hand-code |
| **Structured error output** | ✅ `ValidationError.errors()` JSON-serializable | ❌ String parsing required |
| **Extensibility for new record_types** | ✅ New `BaseModel` subclass | ❌ Modify conditional logic |
| **OSS Prismo schema support** | ❌ No OSS tool covers this exact schema; must build | ❌ Same |
| **Line numbers in errors** | ❌ Field-name only | ✅ Line:col |

### Does any OSS tool handle the full Prismo schema?
No. Neither yamllint, Yamale, nor any generic YAML validator understands doctrine-service-specific semantics (lifecycle fields, `superseded_by` relationships, `record_type`-conditional required fields). Both approaches require custom code. The question is whether that custom code is Pydantic models (structured, maintainable) or hand-rolled Python conditionals (fragile, unstructured).

### On yamllint as a complement, not a replacement
yamllint's one genuine advantage — in-file duplicate key detection and line-precise syntax errors — can be captured as a thin pre-pass that runs `yamllint` via its Python library API before `python-frontmatter` is invoked. This is a hybrid, not a replacement, and adds minimal complexity.

## Sources

- https://yamllint.readthedocs.io/
- https://linuxcommandlibrary.com/man/yamllint
- https://github.com/adrienverge/yamllint
- https://www.mavjs.org/post/yaml-linting-schema-validation/
- https://www.redhat.com/en/blog/check-yaml-yamllint
- https://python-frontmatter.readthedocs.io/
- https://pypi.org/project/frontmatter/
- https://github.com/jlevy/frontmatter-format
- https://haykot.dev/blog/generating-blog-frontmatter/
- https://docs.pydantic.dev/latest/concepts/unions/
- https://docs.pydantic.dev/latest/errors/errors/
- https://docs.pydantic.dev/latest/examples/files/
- https://medium.com/datamindedbe/leveraging-pydantic-for-validation-daf2d51e0627
- https://www.sarahglasmacher.com/how-to-validate-config-yaml-pydantic/
- https://www.c-sharpcorner.com/article/validating-yaml-and-toml-configurations-in-python-with-pydantic/
- https://betterprogramming.pub/validating-yaml-configs-made-easy-with-pydantic-594522612db5
- https://safjan.com/python-packages-yaml-front-matter-markdown/
- https://guidest.com/markdown/front-matter/
- https://typethepipe.com/post/pydantic-discriminated-union/
- https://aiechoes.substack.com/p/mastering-pydantic-part-3-types-unions

*confidence: 0.93 | analysis_type: trade_off*