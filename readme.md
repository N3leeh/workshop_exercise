# Linux-Workshop
Enthalten sind einige kleine Übungsaufgaben für Shell-Einsteiger.
Jede Aufgabe ergibt einen Lösungsbuchstaben; alle Buchstaben zusammen ergeben ein Wort.
Ansible-Playbook + Rolle zum erstellen der Dateien + Verzeichnisse für die Teilnehmer

# Themen Studenten-Workshop

## Tag 1
- Ein bisschen was zu Linux, Thorvalds, Supercomputer etc.
- Einführung in die Shell
    - was ist die Shell? Shell-Prompt; Eingabehilfen; Konfiguration
    - Anmeldung
    - Basis-Befehle (id, pwd, whomami, date, ls, echo etc.) und Aufruf
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

Weitere Ideen:
- Lass die Kuh die Zukunft voraussagen!


Zusatzaufgaben für Profis

1. Besondere Rechte einer Datei
2. Name der besonderen Dateirechte
3. Welchen Exitcode hat ein Befehl?
4. Wie kann man nur Fehler umleiten?
5. Skript korrigieren
6. Rechte auf Dateiordner
7. Besondere Datei-Attribute

## Lösung
Die Lösung basiert auf Linkx-Kernel-Codenames; eine Liste davon findet sich z.B. hier:
- https://www.pro-linux.de/artikel/2/1959/schafe-und-kojoten-die-internen-kernel-namen-von-linux.html
- https://handwiki.org/wiki/List_of_Linux_kernel_names
- https://lunduke.substack.com/p/the-best-linux-kernel-release-code
