# App Store submission checklist

## Before you archive

1. Set **Team** and **Bundle Identifier** in Xcode (e.g. `com.yourstudio.gemstonekeep`).
2. Add a **1024×1024** app icon to `Assets.xcassets/AppIcon.appiconset/` (run `Scripts/generate_app_icon.py` on Mac with Pillow).
3. Create **Game Center** leaderboards and achievements in App Store Connect (IDs in README).
4. Capture **screenshots** — iPhone 6.7" and 6.5" required; iPad if supporting tablet.
5. Set **Age Rating** — likely 4+ (cartoon fantasy violence, no realistic blood).
6. **Privacy** — no data collection; `PrivacyInfo.xcprivacy` is included.

## Info.plist (already set)

- `ITSAppUsesNonExemptEncryption` = false (standard HTTPS / Game Center only)
- Version **1.0.0** (build 1)

## Suggested listing copy

**Subtitle:** Isometric gem arcade

**Description:**
Guide the brave Rook through twelve haunted keeps. Collect every gem, dodge Gloomers and Wardens, grab the magic helm, and discover secret warps. A love letter to classic isometric arcade games — rebuilt for iPhone with modern polish.

**Keywords:** arcade, retro, isometric, maze, gems, puzzle, action

**Category:** Games → Arcade

## Optional audio swap

Drop these into the app target (create an `Audio` group in Xcode):

| File | Purpose |
|------|---------|
| `sfx_gem.caf` | Gem pickup |
| `sfx_jump.caf` | Jump |
| `sfx_death.caf` | Death |
| `sfx_clear.caf` | Level clear |
| `sfx_gameover.caf` | Game over |
| `sfx_helm.caf` | Helm pickup |
| `sfx_zap.caf` | Helm kill |
| `sfx_menu.caf` | Menu tap |
| `sfx_warp.caf` | Secret warp |
| `music_title.m4a` | Title music |
| `music_game.m4a` | Gameplay music |

Procedural synth is used automatically when files are absent.

## Optional art swap

Add PNGs to `Assets.xcassets` using names in `ART.md`.
