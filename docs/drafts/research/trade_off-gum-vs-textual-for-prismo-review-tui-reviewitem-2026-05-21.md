## Trade-Off Analysis — Gum vs Textual for prismo review TUI — ReviewItem inbox interaction (list / show...

**Recommendation:** `hybrid`

Use Gum for all interaction primitives (gum filter for inbox list, gum confirm for approve/reject, gum input/write for notes, gum spin for API calls) and replace gum pager with glow for content display — keeping the entire flow as an enhanced bash script with zero language rewrite. This hybrid satisfies every interaction requirement of the ReviewItem flow (list/show/approve/reject/edit) while honoring Decision 021's 'CLI ships first' constraint and adding only two compiled Go binaries to the dependency surface. Textual should be reconsidered only if the interaction model grows to require simultaneous multi-pane state (e.g., diffing two versions side-by-side, or batch multi-item operations) — at which point the bash foundation will have been validated and a Textual rewrite can be planned deliberately rather than speculatively.

## Findings

## Gum + glow/bat (Hybrid) vs Textual: Prismo ReviewItem TUI

---

### Option A: Gum (Charmbracelet) — Drop-in Bash Enhancement

**What it is:**
Gum is a set of composable terminal UI primitives callable from shell scripts: `gum choose`, `gum confirm`, `gum input`, `gum write`, `gum filter`, `gum pager`, `gum format`. It is a compiled Go binary with no runtime dependencies.

**Strengths:**
- **Zero rewrite cost.** Gum is designed to be embedded directly in shell scripts. The existing `prismo` bash script can be enhanced line-by-line rather than replaced wholesale. Real-world usage patterns (git commit helpers, tmux session pickers, package uninstallers) confirm the drop-in model is well-proven.
- **Exact primitives needed for the review flow exist natively:** `gum filter` for listing/picking pending items; `gum pager` for scrolling through full ReviewItem content; `gum confirm` for approve/reject; `gum input`/`gum write` for the optional rejection note or edit; `gum format` for rendering Markdown bodies inline before the pager step.
- **Markdown rendering is built in.** `gum format` accepts piped Markdown and renders it with glamour styling. For longer content, `gum pager` accepts pre-rendered ANSI output from `gum format` piped through it, giving a scrollable rendered view — no `bat` or `glow` required, though `glow` is a same-vendor tool that can substitute for richer paging.
- **Exit-code-based flow control** maps naturally to bash conditionals: `gum confirm` returns 0 for yes, 1 for no/Ctrl-C, so approve/reject branching is idiomatic.
- **Single binary install.** Available via brew, apt, pacman, nix, and others — no Python, no venv, no pip.

**Weaknesses:**
- **`gum pager` has known bugs.** A documented bug (Jan 2025) shows `gum pager` sometimes fails to render the last line; a memory leak was filed in the same period; tmux `status-position top` crops search results. These are non-trivial if the ReviewItem body is long and the operator is in a tmux session (common in homelab contexts).
- **No true simultaneous multi-pane layout.** Gum cannot show a persistent list panel on the left alongside a detail panel on the right in a single interaction. Each primitive takes full-screen turn, making the UX more wizard-like (step-through) than spatially organized.
- **Long lines / multiline items in `gum filter` truncate without ellipsis.** If ReviewItem titles are long, they get cut off silently. Workaround: pre-truncate titles with `cut` before piping.
- **Process-per-step startup cost.** Each `gum` call forks a Go binary. While fast individually, a tight loop of `gum log` calls showed ~100x overhead vs `/bin/echo` in a real bug report. For the review flow (which is not a tight loop), this is unlikely to matter in practice.
- **CTRL+C exits only the current step**, not the whole script, unless `set -e` is used — requiring careful exit-code handling in the script.
- **Content rendering gap for structured metadata.** ReviewItems likely have metadata (status, source, timestamps) alongside the markdown body. `gum format` renders markdown but has no table/column layout; assembling a multi-field detail view requires piping `gum style --join` calls.

**Middle path with glow:** Charmbracelet's `glow` (same vendor, same license) is a dedicated CLI markdown reader with built-in pager, search, and page-up/page-down. `echo "$BODY" | glow -` renders the ReviewItem body beautifully and avoids the `gum pager` memory/last-line bugs entirely. This hybrid — gum for interaction primitives + glow for content display — covers the full flow with zero Python.

---

### Option B: Textual (Textualize) — Full Python TUI Framework

**What it is:**
Textual is a Python async application framework with a CSS-like layout system, a rich widget library (DataTable, ListView, TextArea, Buttons, Markdown renderer), and an event-driven model. Building the prismo review flow in Textual means rewriting the bash script as a Python application.

**Strengths:**
- **Simultaneous multi-pane layout is first-class.** A left-panel item list + right-panel detail view with scrollable markdown content is the canonical Textual use case. The layout engine handles proportional sizing, docking, and terminal resize natively.
- **Markdown rendering is built in and widget-level.** Textual's `Markdown` widget renders markdown inline within the layout, so the detail pane shows the body, metadata, and source captures together without a separate pager step.
- **Rich widget library covers every interaction primitive.** DataTable for the pending inbox, Input/TextArea for the note/edit fields, Button for approve/reject, all styled consistently without assembly of multiple tools.
- **Testable, maintainable.** Textual has a built-in testing framework (`textual.testing`), dev console (`textual console`), and CSS live-reload. The decoupled component model is easier to unit-test than bash.
- **Future-proof for complexity growth.** If ReviewItems grow to include diff views, source capture previews, or batch operations, Textual can absorb that complexity; bash + gum cannot.
- **Async HTTP calls possible.** If prismo review ever needs to call the API asynchronously (e.g., prefetch the next item while displaying the current one), Textual's asyncio base makes this natural.

**Weaknesses:**
- **Full rewrite required.** The existing bash script at `~/canon/homelab/scripts/prismo` must be replaced entirely. All curl invocations, environment variable handling, and existing command flow must be re-implemented in Python. This is not an incremental change.
- **Python/venv dependency introduced.** The homelab system that runs `prismo review` must have a Python env with Textual installed. This adds dependency management overhead: venv isolation, pip, version pinning. The current script has zero runtime dependencies beyond bash and curl.
- **Startup time.** Python + Textual import chain adds meaningful cold-start latency compared to a shell script calling a single compiled binary. For an interactive review tool invoked manually this is acceptable, but it is a real cost.
- **Textual is a `not-bash` rewrite**, which carries all the hidden coupling risks: implicit environment variables, path assumptions, and subprocess wrappers for curl/jq calls that are transparent in bash become explicit subprocess calls in Python.
- **Overkill for the current interaction model.** The review flow (list → show → confirm → input note → submit) is a linear wizard with 4-5 steps. This is exactly the use case Gum's primitives were designed for. Textual's event-driven app model adds architectural ceremony for a workflow that has no concurrent state.
- **The "CLI ships first" constraint from Decision 021 explicitly favors speed of delivery**, and Textual's rewrite cost directly conflicts with this.

---

### Specific Question: Is the ReviewItem body rich enough to require Textual layout?

The key content concern is: *markdown body + metadata + source captures*. Evaluated by surface:
- **Metadata (status, timestamps, source):** Can be formatted with `gum style` and `gum join` into a header block, or simply rendered via `gum format` with a markdown table.
- **Markdown body:** `gum format` renders it inline; for long bodies, `glow -` renders with paging and search — covering the content entirely.
- **Source captures:** If these are URLs or file paths, they can be listed in the formatted markdown output. If they are embedded diffs or long code blocks, `glow -` handles syntax-highlighted code blocks well.

The critical gap is **simultaneous visibility** — being able to see the item list and the detail at the same time. Gum cannot do this. But for a human-judgment boundary (Decision 021), the operator reviews one item at a time. A step-through wizard (filter → pager → confirm → input) has no practical UX disadvantage over a split-pane view for single-item review.

---

### Head-to-Head Summary

| Dimension | Gum + glow (Hybrid) | Textual |
|---|---|---|  
| Rewrite cost | Near zero (additive to bash) | Full rewrite |
| Time-to-ship | Hours | Days–weeks |
| Runtime dependency | Single Go binary (gum) + glow | Python + venv + textual |
| Markdown rendering | `gum format` / `glow` ✓ | Built-in Markdown widget ✓ |
| Scrollable detail view | `glow -` with pager ✓ | Scrollable widget ✓ |
| Multi-pane layout | ✗ (step-through only) | ✓ (side-by-side) |
| Approve/reject + note | `gum confirm` + `gum input` ✓ | Button + Input widget ✓ |
| Edit before approve | `$EDITOR` or `gum write` ✓ | TextArea widget ✓ |
| Known bugs (content) | `gum pager` memory leak (use glow instead) | None critical in current version |
| Bash interop | Native (it IS bash) | subprocess wrappers needed |
| Testability | Low (bash) | High (Textual testing framework) |
| Decision 021 alignment | ✓ (CLI ships first, incremental) | ✗ (requires full rewrite before shipping) |
| Future complexity ceiling | Low | High |

## Sources

- https://github.com/charmbracelet/gum
- https://github.com/charmbracelet/glow
- https://github.com/Textualize/textual
- https://github.com/charmbracelet/gum/issues/823
- https://github.com/charmbracelet/gum/issues/797
- https://github.com/charmbracelet/gum/issues/443
- https://github.com/charmbracelet/gum/discussions/351
- https://github.com/charmbracelet/gum/issues/892
- https://tech.aufomm.com/how-do-i-use-charmbracelet-gum-to-improve-my-scripts/
- https://realpython.com/python-textual/
- https://www.textualize.io/blog/7-things-ive-learned-building-a-modern-tui-framework/
- https://pkg.go.dev/github.com/charmbracelet/gum/pager
- https://github.com/charmbracelet/gum/releases/tag/v0.11.0
- https://dev.to/dunkinfrunkin/i-built-a-markdown-pager-for-the-terminal-because-i-live-in-the-cli-and-nothing-else-worked-h95
- https://dnastacio.medium.com/bash-over-python-39e0eba502f9
- https://www.xda-developers.com/replaced-bash-scripts-python-what-happened/

*confidence: 0.91 | analysis_type: trade_off*