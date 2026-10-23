#!/bin/bash
# Begrüßt dich und zählt die Dateien im aktuellen Ordner

name = $(whoami)
anzahl=$(ls | wc -l)

if [ "$anzahl" -gt 0 ] then
    echo "Hallo $name, hier liegen $anzahl Dateien."
else
    echo "Hallo $name, der Ordner ist leer."
fi
