#!/usr/bin/env bash
# Release guard. Stops a release (and flags a push) when this repository contains files or code that exist only on the
# maintainer's own devices and must never be redistributed from here: locally generated character models and the engine
# patches that go with them, from a separate mod (The Cinematic Legacy) that is merged into the maintainer's installs.
# Its generated files contain game assets. Exit 1 lists every hit. Generated file: do not edit by hand.
set -u
cd "$(git rev-parse --show-toplevel)"
self=".github/scripts/release-guard.sh"
paths='(^|/)engine/mods/cinematic/|(^|/)cinematic-(eyes|skirt)\.gc$|(^|/)merc_replacements/.+\.(glb|gltf|png)$|\.fr3$|(^|/)pre-cinematic-backup(/|$)|j2-cinematic'
markers=(
  'cinematic-replacement?'
  'cinematic-jak-shadow-clip'
  'cinematic-sig-shadow-clip'
  'cinematic-samos-shadow-clip'
  'cinematic-dax-shadow-clip'
  'cinematic-color-meta'
  'cinematic-eye-anim'
  'cinematic-eye-cleanup'
  'cinematic-fit-skirt'
  'cinematic-original-cloth-setup'
  'cinematic-skirt.o'
  'cinematic-eyes.o'
  'Cinematic gameplay replacement'
  'Cinematic skin follows'
  'oracle-jak) cinematic'
  'Fit the cinematic Jinx'
  'Enable the rider'\''s existing eye pose data'
  'The Cinematic Legacy'
  'j2-cinematic'
  'authored_rgba'
  'native_palette'
  'pre-cinematic-backup'
)
fail=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  echo "::error file=$f::release guard: this path must not be in the repository"; fail=1
done < <(git ls-files | grep -E "$paths" || true)
args=(); for m in "${markers[@]}"; do args+=(-e "$m"); done
hits=$(git grep -I -n -F "${args[@]}" -- . ":(exclude)$self" || true)
if [ -n "$hits" ]; then
  while IFS= read -r l; do echo "::error::release guard: $l"; done <<< "$hits"
  fail=1
fi
[ "$fail" = 0 ] && echo "release guard: clean ($(git ls-files | wc -l | tr -d ' ') files checked)"
exit $fail
