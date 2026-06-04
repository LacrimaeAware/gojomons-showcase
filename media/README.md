# Media

**Raw media files in this folder are git-ignored on purpose** — they are *not*
committed and will *not* live in the public repo. They sit here only as local
originals to upload from.

## How the README still shows them (without committing the files)

GitHub hosts media you upload through the web UI on its own CDN, separate from
the repo:

1. Open the repo on github.com → edit the README (or open a new draft issue).
2. **Drag the file** (`.mp4`, `.png`) into the text box. GitHub uploads it and
   inserts a `https://github.com/user-attachments/assets/…` URL.
3. Copy that URL into the real README where the placeholder is.

The video/image then plays inline in the README, but the file itself stays on
GitHub's CDN — never in the repo. (For `.mp4`, GitHub renders a player; for
stills, use `![caption](url)`.)

## Safe to show now

| File | What it shows |
|---|---|
| `MainMenuAnim.mp4` | Main menu animation — recent, polished |
| `CatraAnim.mp4` | Catra — a flagship creature design |
| `PartyMenuAnim.mp4` | Party menu — UI design work |
| `StyleExploration.png` | Roster / style exploration (multiple mons) |

## Not safe yet — `_wip/` (do NOT publish)

Anything marked `NeedsEdit` is unfinished and should not be shown:
`IntroStartNeedsEdit.mp4`, `MerchantAnimNeedsEdit.mp4`,
`MerchantAnimNeedsEdit2.mp4`.

## Still wanted

A representative **combat** clip — holding off until it's visually ready.
