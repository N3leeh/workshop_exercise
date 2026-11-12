#!/usr/bin/env python3
"""Das Bestellfenster der Krossen Krabbe: ein kleiner Webserver auf einem zufälligen Port."""
import ctypes
from http.server import BaseHTTPRequestHandler, HTTPServer

# Prozessname "krosse-krabbe" statt "python3" (sichtbar in ps und ss)
try:
    ctypes.CDLL(None).prctl(15, b"krosse-krabbe", 0, 0, 0)  # 15 = PR_SET_NAME
except Exception:  # pylint: disable=broad-except
    pass

SEITEN = {
    "/": "Willkommen an der Krossen Krabbe! Hier ist Spongebob, was darf's sein?\n"
         "Die Speisekarte findest du unter /speisekarte\n",
    "/speisekarte": "SPEISEKARTE DER KROSSEN KRABBE\n"
                    "  Krabbenburger ........ 2,99 $   bestellen: /bestellen/krabbenburger\n"
                    "  Seetangsalat ......... 1,50 $   bestellen: /bestellen/seetangsalat\n"
                    "  Korallencola ......... 1,00 $   bestellen: /bestellen/korallencola\n"
                    "\nTagesangebot von Mr. Krabs: Buchstabe an Stelle 6: I (kostenlos, ausnahmsweise)\n",
    "/bestellen/krabbenburger": "Ein Krabbenburger, frisch vom Grill! Guten Appetit!\n"
                                "Auf der Serviette steht: Buchstabe an Stelle 3: B\n",
    "/bestellen/seetangsalat": "Seetangsalat? Wir sind doch kein Reformhaus! Nimm lieber einen Krabbenburger.\n",
    "/bestellen/korallencola": "Eine Korallencola. Leider ist sie warm. Wie wäre es mit einem Krabbenburger dazu?\n",
}


class Bestellfenster(BaseHTTPRequestHandler):
    """Beantwortet GET-Anfragen mit Text."""

    def do_GET(self):  # pylint: disable=invalid-name
        antwort = SEITEN.get(self.path.rstrip("/") or "/")
        status = 200
        if antwort is None:
            status = 404
            antwort = "Das gibt es hier nicht. Schau auf die Speisekarte: /speisekarte\n"
        daten = antwort.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(daten)))
        self.end_headers()
        self.wfile.write(daten)

    def log_message(self, *args):  # keine Ausgabe im Terminal
        pass


if __name__ == "__main__":
    # Port 0: Das Betriebssystem sucht einen freien, zufälligen Port aus
    HTTPServer(("127.0.0.1", 0), Bestellfenster).serve_forever()
