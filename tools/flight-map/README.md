# Flight ground map tools

`goal_src/jak1/engine/mods/flight-map.gc` is generated. It records which level owns the ground of every 16 m cell of
Jak 1's outdoor world, and how high that ground is. The streamer (`flight-stream.gc`) looks levels up there to load
the level under Jak and the one he is flying toward.

Files here:

- `lj-mapscan.gc`: dev-only GOAL file. Loaded into a debug boot of the game through the REPL, it casts four rays per
  cell against one level's collision and prints the result to the game log.
- `lj-mapscan.sh`: runs the scan for a list of levels (teleports to a continue point of each). It expects the game
  booted in debug with a goalc REPL in tmux (socket `goal1`) and a helper that sends a form and waits. Point it at
  your setup with `LJ_GAME` (the install), `LJ_ASK` (the send-and-wait helper), `LJ_BOOT` (the debug boot) and
  `LJ_SCAN` (this folder's `lj-mapscan.gc`); the defaults are the author's Steam Deck.
- `scan-jak1.txt`: the raw scan this repo's map was generated from (the twelve outdoor levels: village1 beach
  training jungle misty firecanyon village2 swamp rolling ogre village3 snow).
- `mapgen.py`: turns a scan into `flight-map.gc` (the same generator as Dark Flight's and True Flight's, `jak1` mode).

Regenerate the map from the stored scan:

```
python3 tools/flight-map/mapgen.py jak1 tools/flight-map/scan-jak1.txt goal_src/jak1
```

The interiors under the world (the temple, the sunken city, the caves) and the citadel are not mapped on purpose: the
game's own load lines handle them, and their ground would claim the surface above them. A level that is not in the
map is left to the game.
