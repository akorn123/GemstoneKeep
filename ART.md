# Art asset guide

`GameArt` loads from **Assets.xcassets** first, then falls back to enhanced procedural sprites.

## Drop-in image names

Add **Single Scale** image sets (filter: nearest neighbor in Xcode).

### Characters & pickups
| Asset name | Size (suggested) |
|------------|------------------|
| `rook` | 32×40 |
| `rook_helm` | 32×40 |
| `gloomer` | 30×26 |
| `stalker` | 32×30 |
| `warden` | 34×38 |
| `swarm_bee` | 10×8 |
| `pickup_helm` | 22×20 |
| `pickup_chalice` | 20×24 |

### Gems (6 hues: 0–5)
| Asset name | Size |
|------------|------|
| `gem_0` … `gem_5` | 20×24 |
| `gem_glow_0` … `gem_glow_5` | 24×24 |
| `gem_sparkle` | 12×12 |

### Tiles (per theme: `stone_keep`, `ice_spire`, `garden_labyrinth`, `obsidian_tower`)
| Pattern | Example |
|---------|---------|
| `tile_floor_{theme}_{elevation}` | `tile_floor_stone_keep_0` |
| `tile_wall_{theme}` | `tile_wall_ice_spire` |
| `tile_ramp_{theme}_{direction}` | `tile_ramp_garden_labyrinth_rampNorth` |
| `tile_stairs_{theme}` | `tile_stairs_obsidian_tower` |

No code changes needed — rebuild after adding assets.
