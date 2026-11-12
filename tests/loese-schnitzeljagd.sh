#!/usr/bin/env bash
#
# Löst die Schnitzeljagd automatisch - so, wie es Teilnehmende tun würden -
# und prüft jeden Lösungsbuchstaben gegen das erwartete Lösungswort.
#
# Aufruf ALS TEILNEHMER (nicht als root), im Home-Verzeichnis:
#   bash loese-schnitzeljagd.sh [start] [teil1] [teil2] [pro]
# Ohne Argument werden alle Teile geprüft.
#
# ACHTUNG: Das Skript LÖST die Aufgaben wirklich (verschiebt Dateien, ändert
# Besitzer, schreibt die Lösungsdatei). Nur mit einem Test-Account verwenden!
#
# Verwendet von der Molecule-Pipeline (ansible-setup/molecule/), kann aber
# auch auf dem echten Workshop-Server in einem Test-Container genutzt werden.
#
# Exit-Code: 0 = alles ok, 1 = mindestens eine Prüfung fehlgeschlagen

set -u
export LC_ALL=C.UTF-8   # "rev" hängt sich bei UTF-8-Text in der C-Locale auf

# Lösungswort (siehe Datei "solution" im Repo): NOCTURNAL MONSTER PUPPY
LOESUNG="NOCTURNALMONSTERPUPPY"
# Lösungswort der Zusatzaufgaben pro_11 bis pro_18: BOBTAIL SQUID
LOESUNG_Z="BOBTAILSQUID"
SJ="$HOME/schnitzeljagd"
TO=10   # Timeout in Sekunden pro Befehl, damit nichts endlos hängt

ok=0; fail=0
declare -A gefunden=()
declare -A gefunden_z=()

# Farben nur im Terminal oder wenn FORCE_COLOR gesetzt ist (z.B. in CI)
if [ -t 1 ] || [ -n "${FORCE_COLOR:-}" ]; then
    gruen() { printf '\033[32m%s\033[0m' "$*"; }
    rot()   { printf '\033[31m%s\033[0m' "$*"; }
else
    gruen() { printf '%s' "$*"; }
    rot()   { printf '%s' "$*"; }
fi

# pruefe <Aufgabe> <Position> <gefundener Buchstabe> [Beschreibung]
pruefe() {
    local aufgabe=$1 pos=$2 ist=${3^^} text=${4:-}
    local soll=${LOESUNG:$((pos-1)):1}
    if [[ -n "$ist" && "$ist" == "$soll" ]]; then
        printf '%-8s Pos %2s = %s  %s %s\n' "$aufgabe" "$pos" "$ist" "$(gruen OK)" "$text"
        gefunden[$pos]=$ist; ok=$((ok+1))
    else
        printf '%-8s Pos %2s = %-2s %s (erwartet %s) %s\n' "$aufgabe" "$pos" "${ist:-?}" "$(rot FEHLER)" "$soll" "$text"
        fail=$((fail+1))
    fi
}

# pruefe_z <Aufgabe> <Position> <gefundener Buchstabe> [Beschreibung]
# wie pruefe, aber für das Lösungswort der Zusatzaufgaben
pruefe_z() {
    local aufgabe=$1 pos=$2 ist=${3^^} text=${4:-}
    local soll=${LOESUNG_Z:$((pos-1)):1}
    if [[ -n "$ist" && "$ist" == "$soll" ]]; then
        printf '%-8s Pos %2s = %s  %s %s\n' "$aufgabe" "$pos" "$ist" "$(gruen OK)" "$text"
        gefunden_z[$pos]=$ist; ok=$((ok+1))
    else
        printf '%-8s Pos %2s = %-2s %s (erwartet %s) %s\n' "$aufgabe" "$pos" "${ist:-?}" "$(rot FEHLER)" "$soll" "$text"
        fail=$((fail+1))
    fi
}

# Buchstabe aus einer Zeile "... Buchstabe an Stelle N: X" lesen
buchstabe() { grep -o 'Stelle [0-9]*: .' | awk '{print $NF}' | head -1; }

# check <Name> <Beschreibung> <Befehl...>  - für Aufgaben ohne Buchstaben
check() {
    local name=$1 text=$2; shift 2
    if timeout "$TO" bash -c "$*" >/dev/null 2>&1; then
        printf '%-8s %s %s\n' "$name" "$(gruen OK)" "$text"; ok=$((ok+1))
    else
        printf '%-8s %s %s\n' "$name" "$(rot FEHLER)" "$text"; fail=$((fail+1))
    fi
}

# letzter Buchstabe eines Wortes
letzter() { local w=$1; echo "${w: -1}"; }

teil_start() {
    echo "== Start"
    check start "Ordner ~/schnitzeljagd gehört mir"      "[ -O '$SJ' ] && [ -d '$SJ' ]"
    check start "Lösungsdatei vorhanden und schreibbar"  "[ -w '$SJ/00_solution' ]"
    check start "readme und tipps lesbar"                "[ -r '$SJ/00_readme.md' ] && [ -r '$SJ/00_tipps' ]"
}

teil_1() {
    echo "== Teil 1"
    cd "$SJ" || return

    # 01: Hinweis in Mr. Krabs' Logbuch finden
    local b
    b=$(grep -o 'Geheimzutat Nr. 1 = .' 01/logbuch | head -1 | awk '{print $NF}')
    pruefe 01 19 "$b" "grep im Logbuch"

    # 02: Krabbenburger von Spongebob zu Patrick verschieben -> mv
    if [ -e 02/spongebob/krabbenburger ]; then mv 02/spongebob/krabbenburger 02/patrick/; fi
    if [ -e 02/patrick/krabbenburger ] && [ ! -e 02/spongebob/krabbenburger ]; then b=m; else b=""; fi
    pruefe 02 10 "$b" "mv spongebob/krabbenburger patrick/"

    # 03: rm rekursiv -> Parameter r (Manpage muss das hergeben)
    if timeout $TO man rm 2>/dev/null | grep -qE -- '-r, -R, --recursive'; then b=r; else b=""; fi
    pruefe 03 16 "$b" "man rm zeigt -r"

    # 04: ls in Datei, nummeriert ausgeben, 34. Eintrag
    (cd 04/bikini_bottom && ls > text)
    b=$(cat -n 04/bikini_bottom/text | awk '$1==34 {print $2}')
    pruefe 04 4 "$(letzter "$b")" "34. Eintrag: $b"

    # 05: User mit UID 0
    b=$(awk -F: '$3==0 {print $1}' /etc/passwd | head -1)
    pruefe 05 11 "${b:1:1}" "UID 0: $b"

    # 06: versteckte Datei
    b=$(cat 06/.[!.]* 2>/dev/null | tr -d '[:space:]')
    pruefe 06 21 "$b" "versteckte Datei"

    # 07: Kapitel der Manpages für Systemverwaltung -> 8 -> "a"
    local kap
    kap=$(timeout $TO man man 2>/dev/null | grep -iE '^\s*[0-9]\s+System administration' | awk '{print $1}')
    if [[ "$kap" =~ ^[0-9]$ ]]; then pruefe 07 "$kap" a "Kapitel $kap"; else pruefe 07 8 "" "man man: Kapitel nicht gefunden (man-db installiert?)"; fi

    # 08: Alias finden und ausführen
    local al ziel
    al=$(bash -ic 'alias' 2>/dev/null | grep -o "alias quallenfischersong=.*")
    ziel=$(echo "$al" | sed -E "s/^alias [^=]+='?([^']*)'?$/\1/")
    b=$(timeout $TO "$ziel" 2>/dev/null | grep -o 'Sie sagt: .' | awk '{print $NF}')
    pruefe 08 2 "$b" "alias quallenfischersong"

    # 09: Distribution und Version
    local id ver
    # shellcheck disable=SC1091
    id=$(. /etc/os-release && echo "$ID"); ver=$(. /etc/os-release && echo "${VERSION_ID%%.*}")
    if [ "$id" = debian ] && [[ "$ver" =~ ^[0-9]+$ ]]; then pruefe 09 "$ver" s "Debian $ver"
    else pruefe 09 13 "" "keine Debian-Version gefunden ($id $ver)"; fi

    # 10: Befehle unter /usr/bin mit genau einem Zeichen, keine Buchstaben/Zahlen
    local n
    # shellcheck disable=SC2010 # bewusst so, wie Teilnehmende es lösen
    n=$(ls /usr/bin | grep -c '^[^[:alnum:]]$')
    if [ "$n" -ge 1 ] 2>/dev/null; then pruefe 10 "$n" n "$n Befehl(e)"; else pruefe 10 1 "" "keine gefunden"; fi

    # 11: Datei mit merkwürdigem Namen
    b=$(cat 11/Pattys* 2>/dev/null | tr -d '[:space:]')
    pruefe 11 18 "$b" "merkwürdiger Dateiname"
}

teil_2() {
    echo "== Teil 2"
    cd "$SJ" || return
    local b

    # 12: Datei, die sich unterscheidet (eigene Inode / Softlink)
    local ref name zahl
    ref=$(stat -c %i 12/unterordner/bestellung)
    name=$(cd 12/unterordner && for f in bestellung_*; do [ "$(stat -c %i "$f")" != "$ref" ] && echo "$f"; done)
    zahl=${name##*_}
    if [[ "$zahl" =~ ^[0-9]+$ ]]; then pruefe 12 "$zahl" "${LOESUNG:0:1}" "$name (gleicher Buchstabe wie Pos 1)"
    else pruefe 12 7 "" "keine abweichende Datei gefunden"; fi

    # 13: Gruppe aller Teilnehmer -> 5. Buchstabe
    local gr
    gr=$(id -Gn | tr ' ' '\n' | grep -x jailed)
    pruefe 13 15 "${gr:4:1}" "Gruppe: ${gr:-nicht in jailed}"

    # 14: Datei gehört root (0400) -> nur mit sudo lesbar
    check 14a "Datei ohne sudo NICHT lesbar" "! cat 14/krabbenburgergeheimrezept"
    b=$(timeout $TO sudo -n cat 14/krabbenburgergeheimrezept 2>/dev/null | tr -d '[:space:]')
    pruefe 14 20 "$b" "sudo cat"

    # 15: Planktons Labor übernehmen (sudo chown -R), dann "geheimzutat" suchen
    check 15a "Labor ohne sudo NICHT lesbar" "! ls 15/labor"
    timeout $TO sudo -n chown -R "$(id -un)" 15/labor 2>/dev/null
    local f
    f=$(find 15/labor -name geheimzutat 2>/dev/null | head -1)
    b=$(cat "$f" 2>/dev/null | tr -d '[:space:]')
    pruefe 15 5 "$b" "sudo chown -R; find -name geheimzutat"

    # 16: Anzahl "Wahnsinn" in Thaddäus' Tagebuch (grep -c und grep -o | wc -l gleich)
    local anz
    anz=$(grep -c Wahnsinn 16/tagebuch)
    check 16a "grep -c und grep -o zählen gleich" "[ \$(grep -o Wahnsinn 16/tagebuch | wc -l) -eq $anz ]"
    pruefe 16 "$anz" "${LOESUNG:3:1}" "$anz x Wahnsinn (gleicher Buchstabe wie Pos 4)"

    # 17: Fundbüro - Datei ohne User und Gruppe
    f=$(find 17/fundbuero -nouser -nogroup -type f 2>/dev/null | head -1)
    b=$(cat "$f" 2>/dev/null | tr -d '[:space:]')
    pruefe 17 3 "$b" "find -nouser -nogroup"

    # 18: Kommas -> Newlines, sortieren, zählen, Wort das nur einmal vorkommt
    local w
    w=$(tr ',' '\n' < 18/text | sort | uniq -c | awk '$1==1 {print $2}' | head -1)
    pruefe 18 12 "$(letzter "$w")" "einmaliges Wort: $w"

    # 19: zeilenweise rückwärts (tac), zeichenweise (rev), letzte Zeile
    local zeile
    zeile=$(timeout $TO tac 19/text | timeout $TO rev | tail -1)
    w=$(echo "$zeile" | awk '{print $NF}')
    pruefe 19 9 "$(letzter "$w")" "tac | rev | tail -1"

    # 20: Kernel-Major-Version
    local major
    major=$(uname -r | cut -d. -f1)
    pruefe 20 "$major" "${LOESUNG:15:1}" "Kernel $(uname -r) (gleicher Buchstabe wie Pos 16)"

    # 21: Variable KAREN von plankton
    b=$(timeout $TO sudo -n -i -u plankton printenv KAREN 2>/dev/null | tr -d '[:space:]')
    pruefe 21 17 "$b" "sudo -i -u plankton printenv KAREN"
}

teil_pro() {
    echo "== Zusatzaufgaben"
    cd "$SJ" || return
    check pro_01 "passwd hat SUID-Bit"                   "[ -u /usr/bin/passwd ]"
    check pro_02 "find findet SUID-Dateien"              "[ \$(find /usr -perm -4000 -type f 2>/dev/null | wc -l) -ge 1 ]"
    check pro_03 "ls /gibtesnicht hat Exitcode 2"        "ls /gibtesnicht; [ \$? -eq 2 ]"
    check pro_04 "Fehler landen in Datei"                "ls /gibtesnicht 2> /tmp/beschwerden.\$\$; grep -q gibtesnicht /tmp/beschwerden.\$\$"
    check pro_05 "skript.sh ist kaputt (nicht ausführbar)" "[ ! -x pro_05/skript.sh ] && ! bash -n pro_05/skript.sh"
    check pro_05b "skript.sh lässt sich reparieren"      "d=\$(mktemp -d); sed -e 's/^name = /name=/' -e 's/ \] then/ ]; then/' pro_05/skript.sh > \$d/s.sh; chmod +x \$d/s.sh; \$d/s.sh | grep -q Hallo"
    check pro_06 "Zettel in Patricks Stein NICHT löschbar" "f=\$(ls pro_06/stein/* | head -1); [ -n \"\$f\" ] && ! rm -f \"\$f\" && [ -e \"\$f\" ]"
    if lsattr pro_07/erster_dollar 2>/dev/null | awk '{print $1}' | grep -q i; then
        check pro_07 "Dollar auch mit sudo NICHT löschbar" "! sudo -n rm -f pro_07/erster_dollar && [ -e pro_07/erster_dollar ]"
    else
        printf '%-8s %s\n' pro_07 "übersprungen (kein immutable-Attribut, z.B. Test-Container)"
    fi
    check pro_08 "Qualle reagiert nur auf SIGUSR1"       "out=\$(mktemp); ./pro_08/qualle.sh > \$out & p=\$!; sleep 1; kill \$p; sleep 1; kill -0 \$p && kill -USR1 \$p; wait \$p; grep -q Erwischt \$out"
    check pro_09 "Flaschenpost lässt sich auspacken"     "d=\$(mktemp -d); tar xzf pro_09/flaschenpost -C \$d && base64 -d \$d/kiste/brief | grep -q 'Flaschenpost'"
    check pro_10 "auth.log: 93 Fehlversuche"             "[ \$(grep -c 'Failed password' pro_10/auth.log) -eq 93 ]"
    check pro_10b "auth.log: 203.0.113.42 am häufigsten" "grep 'Failed password' pro_10/auth.log | awk '{print \$(NF-3)}' | sort | uniq -c | sort -n | tail -1 | grep -q 203.0.113.42"
    check pro_10c "auth.log: Einbruch als thaddaeus"      "grep Accepted pro_10/auth.log | grep 203.0.113.42 | grep -q thaddaeus"
    check pro_10d "adressbuch: IP gehört Plankton"        "grep 203.0.113.42 pro_10/adressbuch | grep -q Plankton"
    check side01 "fortune | cowsay funktioniert"          "/usr/games/fortune | /usr/games/cowsay"
    teil_zusatz
}

# Zusatzaufgaben mit eigenem Lösungswort (pro_11 bis pro_18)
teil_zusatz() {
    echo "== Zusatzaufgaben mit Lösungswort"
    cd "$SJ" || return
    local b w pid port
    check zusatz "Lösungsdatei 00_solution_zusatz vorhanden" "[ -w '$SJ/00_solution_zusatz' ]"

    # pro_11: Klarinette starten, Prozess finden, mit SIGTERM beenden -> Datei "ruhe"
    timeout $TO ./pro_11/thaddaeus_uebt > /dev/null
    sleep 1
    pid=$(pgrep -u "$(id -u)" -x klarinette | head -1)
    if [ -n "$pid" ]; then kill "$pid"; sleep 1; fi
    b=$(buchstabe < pro_11/ruhe 2>/dev/null)
    pruefe_z pro_11 11 "$b" "pgrep klarinette; kill $pid"
    # Zombie zählt als beendet (in Test-Containern ist PID 1 "sleep" und räumt nicht auf)
    check pro_11a "Klarinette ist danach still" "[ -z '$pid' ] || [ ! -e /proc/$pid ] || grep -q '^State:.*Z' /proc/$pid/status"

    # pro_12: diff - ausgetauschte und hinzugefügte Zutat
    w=$(diff pro_12/rezept_original pro_12/rezept_plankton | sed -n '/^[0-9]*c[0-9]*$/,/^[0-9]/p' | grep '^>' | awk '{print $NF}')
    pruefe_z pro_12 9 "${w:0:1}" "diff: ausgetauscht -> $w"
    w=$(diff pro_12/rezept_original pro_12/rezept_plankton | sed -n '/^[0-9]*a[0-9]*$/,$p' | grep '^>' | awk '{print $NF}')
    pruefe_z pro_12 4 "${w:0:1}" "diff: hinzugefügt -> $w"

    # pro_13: größte Datei in Patricks Stein
    w=$(find pro_13/stein -type f -exec du -k {} + | sort -n | tail -1 | awk '{print $2}')
    w=$(basename "$w")
    pruefe_z pro_13 8 "${w:0:1}" "du: größte Datei $w"

    # pro_14: frischer Burger (jünger als 30 Tage) und uralter Burger (älter als 20 Jahre)
    w=$(find pro_14/grill -type f -mtime -30)
    b=$(grep -o 'Buchstabe: .' "$w" 2>/dev/null | awk '{print $NF}')
    pruefe_z pro_14 5 "$b" "find -mtime -30: ${w##*/}"
    w=$(find pro_14/grill -type f -mtime +7300)
    b=$(grep -o 'Buchstabe: .' "$w" 2>/dev/null | awk '{print $NF}')
    pruefe_z pro_14 12 "$b" "find -mtime +7300: ${w##*/}"

    # pro_15: Mrs. Puffs Boot ist nicht ausführbar -> chmod +x
    check pro_15a "Boot ist zu Beginn NICHT ausführbar" "[ ! -x pro_15/mrs_puffs_boot ]"
    chmod +x pro_15/mrs_puffs_boot
    b=$(timeout $TO ./pro_15/mrs_puffs_boot | buchstabe)
    pruefe_z pro_15 2 "$b" "chmod +x mrs_puffs_boot"

    # pro_16: Ordner in den PATH, dann "zurarbeit" aus dem Home-Verzeichnis
    check pro_16a "zurarbeit ohne PATH nicht gefunden" "cd ~ && ! command -v zurarbeit"
    b=$(cd ~ && PATH="$PATH:$SJ/pro_16/wegweiser" timeout $TO zurarbeit | buchstabe)
    pruefe_z pro_16 10 "$b" "PATH erweitert; zurarbeit"

    # pro_17: höchster Betrag (sort -n nach Spalte 3) und neueste Bestellung (sort nach Datum)
    w=$(sort -t';' -k3 -n pro_17/kassenbuch | tail -1 | cut -d';' -f2)
    pruefe_z pro_17 7 "${w:0:1}" "sort -t';' -k3 -n: $w"
    w=$(sort pro_17/kassenbuch | tail -1 | cut -d';' -f2)
    pruefe_z pro_17 1 "${w:0:1}" "sort | tail -1: $w"

    # pro_18: Bestellfenster öffnen, Port mit ss finden, mit curl bestellen
    timeout $TO ./pro_18/bestellfenster_oeffnen > /dev/null
    port=$(ss -tlnp 2>/dev/null | grep krosse-krabbe | awk '{print $4}' | sed 's/.*://' | head -1)
    b=$(timeout $TO curl -s "http://localhost:$port/speisekarte" | buchstabe)
    pruefe_z pro_18 6 "$b" "ss -tlnp -> Port $port; curl /speisekarte"
    b=$(timeout $TO curl -s "http://localhost:$port/bestellen/krabbenburger" | buchstabe)
    pruefe_z pro_18 3 "$b" "curl /bestellen/krabbenburger"
    pkill -u "$(id -u)" -x krosse-krabbe
}

# --- Hauptprogramm -----------------------------------------------------------
if [ "$(id -u)" -eq 0 ]; then echo "Bitte als Teilnehmer ausführen, nicht als root."; exit 2; fi
teile=("$@"); [ ${#teile[@]} -eq 0 ] && teile=(start teil1 teil2 pro)

for t in "${teile[@]}"; do
    case $t in
        start) teil_start ;;
        teil1) teil_1 ;;
        teil2) teil_2 ;;
        pro)   teil_pro ;;
        *) echo "Unbekannter Teil: $t"; exit 2 ;;
    esac
done

# Lösungswort zusammensetzen, wenn alle 21 Buchstaben gefunden wurden
if [ ${#gefunden[@]} -eq ${#LOESUNG} ]; then
    wort=""; for i in $(seq 1 ${#LOESUNG}); do wort+=${gefunden[$i]}; done
    echo; echo "Lösungswort: ${wort:0:9} ${wort:9:7} ${wort:16:5}"
    [ "$wort" = "$LOESUNG" ] || { echo "$(rot 'Lösungswort falsch!')"; fail=$((fail+1)); }
    # Wie die Teilnehmenden: Lösung in die Lösungsdatei schreiben
    printf 'Lösungswort:\n\n%s %s %s\n' "${wort:0:9}" "${wort:9:7}" "${wort:16:5}" > "$SJ/00_solution" 2>/dev/null
fi

# Lösungswort der Zusatzaufgaben
if [ ${#gefunden_z[@]} -eq ${#LOESUNG_Z} ]; then
    wort=""; for i in $(seq 1 ${#LOESUNG_Z}); do wort+=${gefunden_z[$i]}; done
    echo; echo "Lösungswort Zusatzaufgaben: ${wort:0:7} ${wort:7:5}"
    [ "$wort" = "$LOESUNG_Z" ] || { echo "$(rot 'Lösungswort der Zusatzaufgaben falsch!')"; fail=$((fail+1)); }
fi

echo; echo "Ergebnis: $ok ok, $fail fehlgeschlagen"
[ "$fail" -eq 0 ]
