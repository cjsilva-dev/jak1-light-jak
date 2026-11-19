#!/bin/bash
# usage (inside jak.py session; boots the game): lj-mapscan.sh <out file> level=continue [level=continue ...]
# Teleports to each continue, waits for the level to be active, scans it (lj-mapscan.gc); appends MS/MR/MSEND lines
# to <out file> (skips levels already in it). Then on the Mac: mapgen.py jak1 <out file> <repo>/goal_src/jak1.
out=$1; shift
A=/tmp/wj-ask.sh; P=/home/deck/jak-proto/white-jak
cp /tmp/lj-mapscan.gc $P/data/goal_src/jak1/
if ! tmux -L goal1 has-session -t goal 2>/dev/null || ! pgrep -x gk >/dev/null; then
  /tmp/wj-boot.sh >/dev/null || { echo "FAIL boot"; exit 1; }
  sleep 3
fi
WAIT=6 $A '(ml "goal_src/jak1/lj-mapscan.gc")' >/dev/null
log() { ls -t $P/data/log/jak1.*.log | head -1; }
for arg in "$@"; do
  lv=${arg%%=*}; cn=${arg#*=}
  grep -qa "^MSEND $lv " $out 2>/dev/null && { echo "$lv: already scanned"; continue; }
  L=$(log); n=$(wc -l < $L)
  $A "(ms-go-c \"$cn\")" >/dev/null; sleep 4
  if tail -n +$((n+1)) $L | grep -qa "^MG-FAIL"; then echo "$lv: no continue $cn"; continue; fi
  ok=0
  for i in $(seq 1 40); do
    sleep 1; m=$(wc -l < $L); WAIT=0.5 $A "(ms-status (quote $lv))" >/dev/null
    tail -n +$((m+1)) $L | grep -qa "^MQ $lv active" && { ok=1; break; }
    pgrep -x gk >/dev/null || { echo "$lv: GAME DIED"; exit 1; }
  done
  [ $ok = 1 ] || { echo "$lv: never active"; continue; }
  sleep 4
  m=$(wc -l < $L); WAIT=0.5 $A "(lj-mapscan (quote $lv))" >/dev/null
  for i in $(seq 1 240); do sleep 1; tail -n +$((m+1)) $L | grep -qa "^MSEND $lv\|^MS-FAIL $lv" && break; done
  tail -n +$((m+1)) $L | grep -a "^MS \|^MR \|^MSEND \|^MS-FAIL" >> $out; tail -n +$((m+1)) $L | grep -a "^MSB " | head -12
  echo "$lv: $(tail -n +$((m+1)) $L | grep -a '^MS \|^MSEND \|^MS-FAIL' | tr '\n' ' ')"
  pgrep -x gk >/dev/null || { echo "GAME DIED after $lv"; exit 1; }
done
