# Documentation Maintenance

Use this checklist when updating the showcase repo or preparing public pages.

## Routine Freshness Pass

1. Read [docs/README.md](../README.md) and the latest return handoff.
2. Compare README claims against the current playable game and current roadmap.
3. Check whether roadmap docs still label ideas correctly: current, roadmap,
   future intended, possible alternative, parked, cut, or needs call.
4. Keep chronological material chronological. If a page is old pipeline context,
   label it that way instead of silently treating it as current.
5. Update links after moving docs.
6. Run the public-doc check:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-public-docs.ps1
```

## Automation

The Codex app has an active weekly automation named
`Gojomons weekly docs freshness audit`. It covers the private game repo as source
material and this showcase repo as the public-facing output. The automation
should audit freshness, run `scripts/check-public-docs.ps1` for showcase changes,
and push reviewable docs branches instead of quietly publishing major changes.

## Public Readiness

Before publishing a page, clip, or README update:

- Use edited project copy, not unreviewed exports or local-only scratch material.
- Keep account names, local paths, credentials, and unreleased working notes out.
- Use original or licensed media for public clips and images.
- Keep protected-series names out of in-world labels and project identity.
- If AI use is mentioned, keep it short and quality-centered.
- The page should talk about the game, not the writing process behind the page.

## Current Local-Only Material

- `SHOWCASE_NOTES.md`
- `pages-preview/`
- uncommitted `.mp4` files under `media/`

Those can guide future work, but they should not be committed without a deliberate
public-readiness pass.
