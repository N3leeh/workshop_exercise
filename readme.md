# Linux-Workshop
Enthalten sind einige kleine Übungsaufgaben für Shell-Einsteiger.
Jede Aufgabe ergibt einen Lösungsbuchstaben; alle Buchstaben zusammen ergeben ein Wort.
Ansible-Playbook + Rolle zum erstellen der Dateien + Verzeichnisse für die Teilnehmer

# Themen Studenten-Workshop

## Tag 1
- Ein bisschen was zu Linux, Torvalds, Supercomputer etc.
- Einführung in die Shell
    - was ist die Shell? Shell-Prompt; Eingabehilfen; Konfiguration
    - Anmeldung
    - Basis-Befehle (id, pwd, whoami, date, ls, echo etc.) und Aufruf
    - Verzeichnisbaum; absolute und relative Pfade
    - Shellsonderzeichen, Pipelines, Escaping, Wildcards, Variablen etc.
    - Infos über Dateien und Befehle
    - Filedeskriptoren
    - History
    - Aliase
- Arbeiten mit Dateien
    - Dateiarten; reguläre Dateien, Verzeichnisse, Soft- und Hardlinks z.B.
    - Einführung in vim
    - Dateien erstellen, umbenennen, verschieben
    - (in) Dateien suchen
- Schnitzeljagd Teil 1

## Tag 2
- Wiederholung von Tag 1
- (event. Rest von schnitzeljagd Teil 1)
- Linux-Umgebung
    - Speicherverwaltung
    - Pakete finden und installieren
    - Prozesse, Prozessverwaltung
    - Dienste, systemd
    - Logs, journalctl
    - Root, Sudo, Wechsel auf andere User
    - Dateirechte (rwx) lesen, ändern
- Schnitzeljagd Teil 2
- Netzwerk
    - SSH, SCP, rsync
    - DMZ
    - IP-Adressen
- Wiederholung Tag 2
- Meme-Quiz
- Feedback

# Aufgaben-Liste

## Teil 1
1. Finde einen String in einer Datei (grep)
2. Verschiebe eine Datei (mv)
3. Finde einen Parameter für einen Befehl (man)
4. Erstelle eine Liste von Dateien, schreibe sie in eine Datei und nummeriere die Ausgabe (redirection, cat oder less)
5. Welcher User hat die UID 0? (id, getent passwd)
6. Versteckte Datei finden und lesen (ls -al)
7. Manpage-Abschnitt für Systemverwaltung (man man)
8. Alias rausfinden und nutzen (alias)
9. Linux OS-Version (/etc/os-release)
10. Bestimmten Befehl finden mit Hilfe von Wildcards
11. Datei mit merkwürdigem Namen lesen

## Teil 2
12. Hard- und Softlinks unterscheiden
13. Herausfinden, in welcher Gruppe alle Teilnehmer sind
14. Nicht lesbare Datei lesen
15. Ordner mit unzulänglichen Rechten
16. Anzahl von Substrings in einer Datei
17. Datei finden, die keinem User und keiner Gruppe gehört
18. String formatieren (Count substring, tr, sort)
19. String formatieren II (Gegenteil-Tag (tac, rev, sort, uniq))
20. Kernel-Version
21. Wechsel zum User Plankton

## Sidequests
- Lass die Kuh die Zukunft voraussagen!
- Ideen für weitere Übungsaufgaben

## Zusatzaufgaben, für Leute die noch Zeit haben
1. Besondere Rechte einer Datei
2. Name der besonderen Dateirechte
3. Welchen Exitcode hat ein Befehl?
4. Wie kann man nur Fehler umleiten?
5. Skript korrigieren
6. Rechte auf Dateiordner
7. Besondere Datei-Attribute
8. Prozesse und Signale (&, jobs, ps/pgrep, kill, trap)
9. Matrjoschka: Dateityp erkennen und auspacken (file/od, tar, base64)
10. Log-Analyse: Einbruchsversuch in auth.log finden (grep, awk, sort, uniq)


# Ausbringen (Ansible)

Im Ordner `ansible-setup`. Die Teilnehmerliste kommt aus `~/webtty-playground/vars/jailed.yml`
(anderer Pfad: `-e teilnehmerliste=/pfad/jailed.yml`). Jeder Teil kann einzeln und in beliebiger
Reihenfolge ausgebracht werden; ein erneuter Lauf ändert nichts und überschreibt keine Arbeit der Teilnehmenden.

| Befehl | Legt an |
|---|---|
| `ansible-playbook setup-exercises.yaml --tags=start` | Zu Beginn des Workshops: Ordner `~/schnitzeljagd` mit Lösungsdatei `00_solution`, `00_readme.md` und `00_tipps` |
| `ansible-playbook setup-exercises.yaml --tags=teil1` | Aufgaben 01-11 (Tag 1) inkl. Alias und Skript für Aufgabe 8 |
| `ansible-playbook setup-exercises.yaml --tags=teil2` | Aufgaben 12-21 (Tag 2) inkl. User `plankton` |
| `ansible-playbook setup-exercises.yaml --tags=pro` | Zusatzaufgaben und Sidequests |

Die Start-Dateien werden bei jedem Teil mit angelegt, falls sie noch fehlen.

# Tests

## Lösungsskript
`tests/loese-schnitzeljagd.sh` löst die Schnitzeljagd so, wie es Teilnehmende tun würden, und prüft jeden
Buchstaben gegen das Lösungswort. Es muss **als Teilnehmer** laufen und löst die Aufgaben wirklich
(verschiebt Dateien, ändert Besitzer) - also nur mit einem Test-Account:

```sh
bash loese-schnitzeljagd.sh            # alles
bash loese-schnitzeljagd.sh teil2      # nur Teil 2
```

Damit lässt sich vor jedem Workshop prüfen, ob die Aufgaben auf dem echten Server (z.B. nach einem
Kernel- oder Debian-Update, Aufgaben 9 und 20) noch zum Lösungswort passen.

## Pipeline (GitHub Actions)
`.github/workflows/ci.yml`:
- **Lint**: yamllint, shellcheck, ansible-lint (zunächst nicht blockierend)
- **Syntax**: `ansible-playbook --syntax-check` und Liste der Tasks je Teil
- **Molecule**: fünf Szenarien in `ansible-setup/molecule/`, jeweils in einem frischen
  `debian:trixie`-Container:
    - `start`, `teil1`, `teil2`, `pro`: jeder Teil **einzeln** - beweist, dass die Teile unabhängig sind
    - `alle`: alle Teile zusammen, inkl. komplettem Lösungswort
  
  Ablauf je Szenario: Container erstellen, vorbereiten (Pakete wie im Jail-Image, Teilnehmende
  `max`/`mellanie`), ausbringen, zweiter Lauf ohne Änderungen (Idempotenz), Lösungsskript als `max`.

Lokal (Docker nötig):
```sh
pip install ansible-core molecule "molecule-plugins[docker]" requests
ansible-galaxy collection install community.docker
cd ansible-setup && molecule test -s teil2
```

Einschränkungen: Im Container wird `chattr +i` (pro_07) übersprungen, weil overlayfs keine
Datei-Attribute kann. Host und Jail-Container sind im Test derselbe Container.

## Lösung
Die Lösung basiert auf Linux-Kernel-Codenames; eine Liste davon findet sich z.B. hier:
- https://www.pro-linux.de/artikel/2/1959/schafe-und-kojoten-die-internen-kernel-namen-von-linux.html
- https://handwiki.org/wiki/List_of_Linux_kernel_names
- https://lunduke.substack.com/p/the-best-linux-kernel-release-code
