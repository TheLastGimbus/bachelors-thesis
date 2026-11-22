#import "template.typ": thesis, title-page

#show: thesis

#title-page(
  "Charakteryzacja silnika jonowego wykonanego technikami MEMS",
  "Mateusz Soszyński",
  "dr inż. Piotr Szyszka",
  "Inteligentna Elektronika",
  2026,
)

#heading(numbering: none)[Wprowadzenie]
Streszczenie pracy.

*Słowa kluczowe:* silnik jonowy, MEMS

#pagebreak()

#heading(numbering: none)[Abstract]
Abstract of the thesis.

*Keywords:* ion thruster, MEMS

#pagebreak()

#outline(title: "Spis treści")



= Wstęp

== Teoria

// O czym chce napisać:
// Chce generalnie, żeby ta teoria pokazała, że ten silnik jest potrzebny
// Czemu jest potrzebny?
// - Bo dotychczasowe silniki są duże
// Czemu duże silniki są złe?
// - Bo wszystko co duże w kosmosie jest złe -> DODAJ koszty wynoszenia w kosmos
// - Bo new space ma małe payloady -> DODAJ rozmiary payloadów
//

=== Miniaturyzacja satelit

Branża kosmiczna przez ostatnie lata bardzo dojrzała, i stała się dynamicznym, bogatym w innowacje rynkiem. Przestała ona należeć do kilku największych organizacji rządowych świata, a rozmyła się na wiele nowych firm i start-up'ów, które szybko wprowadzają zmiany w tym, co leci na orbitę naszej planety. Powszechnie używa się terminu "New Space" na ten trend @newSpaceWiki.

Jednym z najważniejszych aspektów tych innowacji jest miniaturyzacja - wznoszenie ładunku w kosmos to ogromne koszta, a każdy kilogram mniej to zaoszczędzone tysiące dolarów.
Pomógł tu fakt, że miniaturyzacja dotyczy niemal wszystkich technologii których używamy - przykładowo, dzięki branży mobilnej, która naciskała na energooszczędność procesorów w telefonach, z tych samych wydajniejszych i mniejszych procesorów mogą korzystać firmy kosmiczne.

#figure(caption: [Mimo gwałtownego spadku kosztów w ciągu ostatniej dekady, wzniesienie kilograma ładunku na niską orbite wciąż wynosi \~2000\$ @owid-space-exploration-satellites], image("images/cost-space-launches-low-earth-orbit.svg")
)

//> Czy takie "wnioski w podpisie zdj" to git pomysł? Czy powinienem tu też dopisać sam opis zdjecia (że "grafika z world in data") ?

Postępy w miniaturyzacji otworzyły droge tzw. "Nano Satelitom", czyli satelit do 10~kg. W ostatnich 10 latach wzniesiono na orbite już tysiące takich satelit, a w 2026 roku spodziewa się wzniesienia ponad 600 @nanosatsDatabase.

#figure(caption: [Ilość wzniesionych "Nano Satelit" w ostatnich latach @nanosatsDatabase.], image("images/Nanosats_years_2026-07-31.svg", width: 90%))

Europejska Agencja Kosmiczna organizuje nawet zawody dla młodzieży w budowaniu "CanSat'ów", czyli pseudo-satelit wielkości puszki po napojach @cansatWiki. Zawodnicy w wieku około licealnym sami projektują i budują swoje satelity, które będą w stanie wykonać określoną przez nich misje (np. zebrać obrazy terenu), utrzymać komunikacje oraz bezpiecznie wylądować. Satelity zespołów, którym uda dostać się do ostatniego etapu, są zrzucane z wysokości \~200m. Realia tych zawodów są wcale nie tak odległe od tego, co staje się możliwe w dzisiejszej branży kosmicznej.

#figure(caption: [Przykładowa pseudo-satelita CanSat na zawodach Europejskiej Agencji Kosmicznej @cansatPhotos], image("images/Day-2-Can-Sat-2026-H68A5262--scaled.jpg", width: 50%))

== Przegląd literatury

// ABIE-X: On-orbit proof-of-concept experiment of air-breathing ion engine
// Ziomki twierdzą że "Very low Earth orbit" jeszcze nie śmiga bo jest opór powietrza, a oni zrobią silnik co będzie na tym działał
// https://www.sciencedirect.com/science/article/pii/S0094576526003620

// Electric propulsion for satellites and spacecraft: established technologies and novel approaches
//
// https://vpn.student.pwr.edu.pl/https//iopscience.iop.org/article/10.1088/0963-0252/25/3/033002/meta

// Electric propulsion for small satellites
//
// https://vpn.student.pwr.edu.pl/https//iopscience.iop.org/article/10.1088/0741-3335/57/1/014005

// Electric propulsion: comparisons between different concepts
//
// https://vpn.student.pwr.edu.pl/https///iopscience.iop.org/article/10.1088/0741-3335/53/12/124011

// Plasma propulsion for telecommunication satellites
//
// https://iopscience.iop.org/article/10.1088/1742-6596/1326/1/012001

= Zagadnienie



= Charakteryzacja

== Stanowisko pomiarowe

=== Obudowa silnika

=== Urządzenia do pomiarów elektrycznych i ich automatyzacja

=== Automatyczna kontrola zaworu

== Pomiary

== Wnioski z pomiarów



= Wnioski ogólne i podsumowanie

#bibliography("bibliography.bib", style: "ieee", title: "Bibliografia", full: true)
