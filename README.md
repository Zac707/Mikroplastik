# Mikroplastik2025

## Das Werkstück
Dieser Prototyp wurde für die Sonderforschungsgruppe Mikroplastik der Universität Bayreuth designed und entwickelt.
Im Rahmen dieses Themas interagieren Spieler*innen auf unterschiedliche Arten mit Plastik.

Der Prototyp besteht aus einem Main Screen und fünf Minigames.

Im Main Screen werfen bis zu 3 Spielende mit Winden verbundene Haken aus, um in einem Becken schwimmende Plastikobjekte zu fangen und herauszufischen.
Auf einer Anzeige links unten kann man den Verschmutzungsgrad des gesamten Beckens sehen.
Durch eine Fortschrittsleiste am rechten Rand kann man den Gesamtfortschritt der gesammelten Scores sehen.
Durch das Einholen von Gegenständen können Minigames gestartet werden.

Im Plastik Werfen Minigame sammeln Spielende in einer begrenzten Zeit Punkte, indem sie das entsprechende Plastik in den richtigen Mülleimer befördern. 
Das Thema hier ist Mülltrennung von unterschiedlichen Plastik-Arten.

Im Odd One Out Minigame sammeln Spielende in einer begrenzten Zeit Punkte, indem sie unter vielen herumfliegenden biologisch abbaubaren Gegenständen einen Plastikgegenstand finden und antippen. 
Das Thema hier ist das Sauberhalten von Biomüll.

Im Würmer Minigame sammeln Spielende in einer begrenzten Zeit Punkte, indem sie Würmer steuern, um Grünzeug zu essen. Essen sie zu viel Plastik oder treffen eine Wand, verschwindet ihr Wurm. 
Das Thema hier ist der Beitrag von Würmern zu nährstoffreicher Erde und wie ihnen durch Mikroplastik geschadet wird.

Im Sand-Such Minigame sammeln Spielende Punkte, indem sie in möglichst kurzer Zeit bestimmte Mikroplastik-Teile mittels Lupen im Sand finden. 
Das Thema hier ist die Verbreitung von Mikroplastik und wie schwer es von anderen Partikeln zu unterscheiden ist.

Im Rätsel Minigame sammeln Spielende in einer begrenzten Zeit Punkte, indem sie einen Weg durch ein "Straßennetz" planen, der an allen auf der Karte verteilten Müllsäcken vorbeikommt.
Das Thema hier ist die Eigenverantwortung eines jeden um öffentliche Lebensräume sauber zu halten..


Als ein Spiel, was für die Nutzung bei Messen gedacht ist, ist es Fullscreen und hat kein Pause-Menü, um es zu beenden. Es wird angenommen, dass der Multi-Touchscreen eine für den Betreibenden zugängliche Tastatur hat, und das Spiel durch Alt + F4 beendet werden kann.

## Informationen zum Spielen

### How-To: Spielen
Werfe den Haken einer Winde in das Becken und ziehe ihn mit der Winde ein, um ein angelbares Objekt zu fangen. Drücke auf "Einholen", um es zum Ufer zu ziehen und ein Minigame zu starten.
Objekte im Wasser verfallen mit der Zeit. Je mehr Objekte verfallen, desto mehr steigt der Verschmutzungsgrad des Beckens. Wenn der maximale Verschmutzungsgrad erreicht ist oder das gesamte Becken mit Objekten gefüllt ist, ist Game Over.
Durch das Abschließen von Minigames wird Score der Fortschrittsleiste hinzufügt. An unterschiedlichen Punkten der Fortschrittsleiste finden Events statt, die den Verschmutzungsgrad des Beckens verringern. Fülle die ganze Fortschrittsleiste, um das Spiel zu gewinnen.

Im Main Screen gibt es in der linken oberen Ecke Knöpfe zum gezielten Starten von Minigames.
Abgesehen davon korrespondiert eine Art Objekt zu einem Minigame:
- Becher -> Odd One Out
- Flasche -> Plastik Werfen
- Rechen -> Würmer
- Eimer -> Sand-Such
- Tüte -> Rätsel


### How-To: Einstellen
(Mit Zugriff auf das Godot Projekt selbst. Godot Version: 4.4.1)

Die meisten Parameter des Hauptspiels können eingestellt werden.
Viele davon finden sich in `global_config.gd`. Einige Einstellungen zu der Menge und Geschwindigkeit von im Becken auftauchenden Objekten lassen sich in `map.gd` im Inspector vom `ObjectSpawner` verändern.


### Bekannte Bugs
Im Main Screen (Becken zum Fischen):
- Wenn man den Haken auswirft und er *auf* einem angelbaren Objekt zu Stehen kommt, wird nicht das Objekt geangelt, sondern erst das nächste Objekt, in das der Haken beim einziehen hineingezogen wird.
- Wenn man mit einer Maus (statt mit Touch) den Haken auswirft kann es manchmal passieren, dass nach dem wieder Einziehen über die Winde sich der Haken mit dem Mauszeigen bewegt, ohne dass man die Maustaste gedrückt hat.
- Wenn man aus einem Minigame zurück in den Main Screen kommt, muss man manchmal einen Haken erst durch die Winde heranziehen, bevor man ihn wieder draggen kann.
- Die Grenze, bei der registriert wird, dass der Haken den Wurfbereich verlassen hat, ist größer als der sichtbare Collider. Deshalb ist dieser kleiner als der intendierte Wurfbereich.
- Wenn man aus einem Minigame zurück in den Main Screen kommt, wird der Säuberungs Progress-Event (Beseitigung eines Teils des Verschmutzungsgrades und der vorhandenen Objekte) unbeabsichtigt angewendet, selbst wenn kein neues Event erreicht ist.

In Mikroplastik Werfen:
- Die Guideline entspricht nicht ganz der tatsächlichen Flugbahn, vor allem bei Würfen zur Seite bemerkbar

Im Rätsel:
- Wenn die Linie mit zu hoher Geschwindigkeit bewegt wird, werden Ecken nicht registriert. Heißt man kann in Richtungen gehen die eigentlich nicht erlaubt sind, oder zurückgehen ohne den Punkt zu löschen. Dieser Bug ist behebbar indem man die maximal Geschwindigkeit eingrenzt, die Steuerung fühlt sich dann allerdings sehr unresponsiv und frustrierend an.
- Wenn an einem dreieckigen Tile eine Linie durchgeht und eine zweite Linie den übrigen Eingang nutzt, kommt die zweite Linie nicht mehr frei.
- Wenn Linien aufeinander treffen würden, zwingen sie sich gegenseitig in gegensätzliche Richtungen zu gehen. Wenn sie orthogonal aufeinander treffen, bedeutet dass das eine Linie zwingend in die falsche Richtung gezwungen wird.


### Teammitglieder

- Hannes Partheymüller
    - Bereiche: Programmierung, Game Design, System Architecture
    - Entwicklung des Main Screens und seines Inhalts (Winden, angelbare Objekte, Gesamtfortschritt mit Events und Verschmutzung) und des Minigame-Systems
    - Entwicklung des Odd One Out Minigames mit Miriam Reinhardt
- Miriam Reinhardt
    - Bereiche: 2D Art, Game Design, Programmierung
    - Herstellung der 2D Assets für den Main Screen, Odd One Out und Rätsel Minigame
    - Entwicklung des Odd One Out Minigames mit Hannes Partheymüller
- Zacharie Tissier
    - Bereiche: Programmierung, Game Design, 2D Art
    - Entwicklung der Plastik Werfen, Würmer, Sand-Such und Rätsel Minigames
    - Herstellung der 2D Assets für die Plastik Werfen, Würmer und Sand-Such Minigames