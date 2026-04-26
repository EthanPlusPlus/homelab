# Prismo Canon — Home

> Install the **Dataview** community plugin in Obsidian to render the tables below.
> Settings → Community plugins → Browse → search "Dataview"

---

## Proposed Ideas

```dataview
TABLE status AS "Status"
FROM "homelab/docs/proposed-ideas"
SORT id ASC
```

---

## Decisions

```dataview
TABLE file.name AS "File"
FROM "homelab/docs/decisions"
SORT file.name ASC
```

---

## In Progress

```dataview
LIST
FROM "homelab/docs/proposed-ideas"
WHERE contains(status, "In progress") OR contains(status, "progress")
```

---

## Open Questions

- [[open-questions]]

## Context

- [[recent-changes]] · [[progress]] · [[constraints]] · [[services]]
