# Gemstone Keep

Retro isometric arcade game for iOS — Swift + SpriteKit, no third-party dependencies.

## Open in Xcode

1. Open `GemstoneKeep.xcodeproj` on a Mac with Xcode 15+.
2. Select the **GemstoneKeep** scheme and an iPhone simulator (or device).
3. Build & Run (⌘R).

**Release polish** delivers procedural audio, art pipeline, App Store docs.

**Roguelite mode (Option B):** permadeath runs, wallet gems, exit portals, shrine shop every 2 floors, enemy gem theft, meta camp upgrades with soul gems.

### Roguelite loop

1. **Collect gems** → wallet currency (score is separate).
2. **Reach the EXIT portal** → clear the floor (gems optional).
3. **Every 2 floors** → shrine offers 3 random run augments (Swift Paws, Iron Helm, Gloom Ward, Gem Magnet, Guardian Heart, Rich Vein).
4. **Gloomers eat map gems** → you lose 1 wallet gem per theft.
5. **Death** → Guardian Heart revives once, else run ends at **Camp** (bank soul gems, buy meta upgrades: Hearty Start, Thick Fur, Shrine Favor, Soul Keeper, Keen Eye).

**Milestone 9** delivers: level flyover intro, trauma-based screen shake, gem collection sparkle burst, CRT scanline filter (toggle in Settings), and performance tuning (60fps cap, node culling, throttled mini-map).

**Milestone 8** delivers: title menu, settings (haptics/sound/music/mini-map/debug), persistent high score, 10 achievements, Game Center leaderboards, and settings-aware audio/haptics.

**Milestone 7** delivers: 12 handcrafted levels across four themes, difficulty scaling, endless loop after level 12, and three secret warps (jump in hidden corners).

**Milestone 6** delivered: magic helm power-up, golden chalice, helm-kill scoring, time bonus, timer HUD, helm bar, and corner mini-map.

## Levels

| # | Name | Theme | Secret warp |
|---|------|-------|-------------|
| 1 | Stone Gate | stone_keep | — |
| 2 | Inner Ward | stone_keep | Moonlit Alcove → skip 3 |
| 3 | Baron's Bulwark | stone_keep | — |
| 4 | Frost Vestibule | ice_spire | — |
| 5 | Glacier Gallery | ice_spire | — |
| 6 | Crystal Crown | ice_spire | Frost Rift → skip 4 |
| 7 | Ivy Court | garden_labyrinth | — |
| 8 | Thorn Maze | garden_labyrinth | — |
| 9 | Bloom Sanctum | garden_labyrinth | Hedge Portal → skip 3 |
| 10 | Ash Atrium | obsidian_tower | — |
| 11 | Void Rampart | obsidian_tower | — |
| 12 | Eclipse Spire | obsidian_tower | — |

After level 12, the game loops back to level 1 with higher enemy counts and speeds (`DifficultyScaler`).

## Project layout

```
GemstoneKeep/
  App/              AppDelegate, SceneDelegate, GameViewController
  Game/
    GameScene.swift
    Art/GameArt.swift   Asset loader (catalog PNGs → procedural fallback)
    PlaceholderArt.swift Enhanced procedural sprites
    Systems/            SynthAudioEngine, MusicManager, …
    Effects/        GemSparkleBurst
    Levels/         LevelData, LevelBuilder, LevelCatalog
    UI/             TitleScene, CRTEffectNode, overlays, MiniMapNode
```

## Depth sorting

See `IsoMath.zPosition(col:row:elevation:layerOffset:)` — diagonal `(row + col)` for screen depth, `elevation × 100` for vertical layers, small offsets for walls vs floor vs entities.

## Audio & art swaps

- **Audio:** Procedural synth plays automatically. Drop `.caf` / `.m4a` files into the Xcode target to override — see `STORE.md`.
- **Art:** Add image sets to `Assets.xcassets` — see `ART.md`. Run `Scripts/generate_app_icon.py` on Mac for a starter icon.

## App Store

See `STORE.md` for submission checklist, listing copy, and encryption declaration (`ITSAppUsesNonExemptEncryption` = false).

## Game Center (App Store Connect)

Create these IDs to match the code:

**Leaderboards:** `gemstonekeep.leaderboard.highscore`, `gemstonekeep.leaderboard.deepest_level`

**Achievements:** `gemstonekeep.achievement.first_gem`, `clear_castle`, `score_25k`, `score_100k`, `secret_warp`, `all_warps`, `reach_ice`, `reach_eclipse`, `helm_master`, `chalice_hunter`

## Requirements

- iOS 16+
- Swift 5.9+
- iPhone primary, iPad supported
