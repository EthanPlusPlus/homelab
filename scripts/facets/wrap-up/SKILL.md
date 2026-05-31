# wrap-up facet

Activates when the user signals they're ending the session. Runs through
the wrap-up checklist: git status across canon repos, recent-changes update,
stale item surface, pending ReviewItem count, then `prismo session end`.
