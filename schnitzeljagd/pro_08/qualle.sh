#!/bin/bash
# Die Qualle schwimmt so lange im Hintergrund, bis sie das richtige Signal bekommt.

trap 'echo; echo "Die Qualle ignoriert SIGTERM. Probier ein anderes Signal!"' TERM
trap 'echo; echo "Die Qualle ignoriert auch SIGINT (Strg+C)."' INT
trap 'echo; echo "Erwischt! Die Qualle hat SIGUSR1 bekommen und sagt: Signale sind super!"; exit 0' USR1

echo "Die Qualle (PID $$) schwimmt jetzt..."
while true; do
    sleep 1
done
