#import "template.typ": *

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

#figure(
  caption: [Mimo gwałtownego spadku kosztów w ciągu ostatniej dekady, wzniesienie kilograma ładunku na niską orbite wciąż wynosi \~2000\$ @owid-space-exploration-satellites],
  image("images/cost-space-launches-low-earth-orbit.svg"),
)

//> Czy takie "wnioski w podpisie zdj" to git pomysł? Czy powinienem tu też dopisać sam opis zdjecia (że "grafika z world in data") ?

Postępy w miniaturyzacji otworzyły droge tzw. "Nano Satelitom", czyli satelit do 10~kg. W ostatnich 10 latach wzniesiono na orbite już tysiące takich satelit, a w 2026 roku spodziewa się wzniesienia ponad 600 @nanosatsDatabase.

#figure(caption: [Ilość wzniesionych "Nano Satelit" w ostatnich latach @nanosatsDatabase.], image(
  "images/Nanosats_years_2026-07-31.svg",
  width: 90%,
))

Europejska Agencja Kosmiczna organizuje nawet zawody dla młodzieży w budowaniu "CanSat'ów", czyli pseudo-satelit wielkości puszki po napojach @cansatWiki. Zawodnicy w wieku około licealnym sami projektują i budują swoje satelity, które będą w stanie wykonać określoną przez nich misje (np. zebrać obrazy terenu), utrzymać komunikacje oraz bezpiecznie wylądować. Satelity zespołów, którym uda dostać się do ostatniego etapu, są zrzucane z wysokości \~200m. Realia tych zawodów są wcale nie tak odległe od tego, co staje się możliwe w dzisiejszej branży kosmicznej.

#figure(caption: [Przykładowa pseudo-satelita CanSat na zawodach Europejskiej Agencji Kosmicznej @cansatPhotos], image(
  "images/Day-2-Can-Sat-2026-H68A5262--scaled.jpg",
  width: 50%,
))

=== Nano-satelity a nano-silniki

// Uwaga do numeracji stron:
// @nasaSoa2026 -> strony drukowane rozdz. 4 (PDF ma ~55 str. okładki/wstępu przed nimi, np. str. 65 wyd. = str. 10 PDF)
// @hsu2023compendium -> strony PDF = strony drukowane

==== *Jak dużo nano-satów faktycznie ma napęd*

- 3417 nanosatów wyniesionych (do 31.07.2026), w tym tylko *279* z modułem napędowym → *ok. 8%* floty @nanosatsDatabase
  - figura: "Total nanosatellites and CubeSats launched" - legenda: "Nanosats launched incl. launch failures" = 3417; "Nanosats with propulsion modules" = 279; "CubeSats launched to beyond LEO" = 37; "CubeSats launched incl. launch failures" = 3165
  - // potencjalna figura do pracy: https://www.nanosats.eu/img/fig/Nanosats_total_2026-07-31.svg
  - na wykresie linia napędów jest niemal płaska na tle eksponencjalnego wzrostu floty - napęd nie nadąża za tempem wynoszenia
- niezależne potwierdzenie akademickie: "Nanosatellites launched with propulsion modules is 222, but here many could be unknown." → 222/2714 = *8,2%* (stan 30.09.2024) @kulu2024statistics (s. 3, sekcja 2.3)
- względem samych CubeSatów ~9% (222 z 2381 "successfully to orbit") @kulu2024statistics (s. 3)
- zastrzeżenie: kryterium "propulsion module" w bazie niejawne - strona keyword "Propulsion" wlicza też żagle deorbitacyjne (NanoSail-D, LightSail) → 8% traktować raczej jako górną granicę @kuluPropulsionKeyword
- opinie z przeglądów: "very few have seen actual implementation in space" @krejci2018ieee (abstrakt, s. 362); "their limited propulsion capabilities have often been a constraint in achieving certain mission objectives" @alnaqbi2024review (abstrakt)
- paradoks oferty: rynek rejestruje 336 systemów napędowych smallsat (2023), a ~92% floty nadal bez napędu @hsu2023compendium (s. 15)
- kontekst floty: 3165 CubeSatów; rekord roczny 2025: 401; średnio 2021-2025 ~347/rok; tylko 37 CubeSatów poza LEO (w tym 18 interplanetarnych) @nanosatsDatabase (blok "Facts as of 2026 July 31" + figury)
- form factor: dominanta 3U (>1300 wystrzelonych), dalej 6U (14,8%) i 1U (11,5%) @kulu2024statistics (Fig. 5, s. 5)

==== *Po co go wykorzystują jeśli już*

- *podnoszenie orbity (orbit-raising)*
  - Beihangkongshi-1 (12U, NPT30-I2-1U; 55 W, 0,8 mN): 2 wypalenia po 90 min → +700 m wysokości; po 11 wypaleniach łącznie >3 km @rafalskyi2021iodine (Fig. 4: "for each firing gives an altitude change between 200 m and 400 m at a thrust and power of about 0.8 mN and 55 W")
  - NorSat-TD (35 kg, SFL DEFIANT, NPT30-I2-1.5U): 26.01.2024 manewr podniesienia orbity - odzyskanie ~20 km straconych na drag @nosa2024norsattd ("...tente den norske nasjonale satellitten NorSat-TD rakettmotoren sin for å gå opp til en høyere bane")
- *utrzymanie orbity (station-keeping / drag makeup)*
  - Beihangkongshi-1: "Manoeuvres 1A and 1B demonstrate that the propulsion system can be used for orbit maintenance to compensate for this drag." @rafalskyi2021iodine
  - EYE / SPHERE-1 (6U Sony, rezystojęt wodny Pale Blue): przedłużenie życia misji o ~2,5 roku @nasaSoa2026 (s. 88: "The water propulsion system is expected to prolong the satellite's life by 2.5 years.")
- *unikanie kolizji*
  - NorSat-TD: zdolność unikania kolizji jako cel misji @nasaSoa2026 (s. 89: "included a demonstration of satellite collision avoidance maneuvers") - [uwaga: wykonanie konkretnego manewru CA niewiadome; ref. SOTA dot. integracji testowej z 2021]
  - GMS-T (Enpulsion Micro R3): "propulsive capability for collision avoidance" @nasaSoa2026 (s. 86)
  - Beihangkongshi-1: "In addition, all firings are representative of collision avoidance manoeuvres." @rafalskyi2021iodine
- *deorbitacja końca misji*
  - UWE-4 (1U, NanoFEEP): obniżenie orbity (2020) - pierwsza deorbitacja EP na 1U @kramer2020uwe4 @nasaSoa2026 (s. 86)
  - NanoAvionics EPSS: "provides satellites with decommissioning utility at the end of mission, meeting the space debris mitigation requirements of ESA and NASA" @hsu2023compendium (s. 132)
  - bezpaliwowo: NanoSail-D2 - żagiel 10 m² z orbity 650 km → reentrja po 240 dniach @nasaSoa2026 (s. 102)
- *formacje / rendezvous*
  - CanX-4 i CanX-5: autonomiczne utrzymywanie formacji od 1 km do 50 m separacji @nasaSoa2026 (s. 77)
  - CPOD (2×3U, VACCO R236fa): zbliżenie z 997 km do minimum 0,36 km @nasaSoa2026 (s. 78)
  - GOMX-4B (NanoProp 6U): demonstracja lotu formacyjnego (2018) @nasaSoa2026 (s. 77)
- *misje poza LEO*
  - MarCO-A/B: 5 manewrów TCM w trasie do Marsa + przekaźnik telemetrii EDL InSight (XI 2018) @nasaSoa2026 (s. 78) @jpl2018marco
  - Lunar IceCube i LunaH-Map (6U, Artemis I): BIT-3 (jod stały) jako napęd główny transferu księżycowego @nasaSoa2026 (s. 89-90); LunaH-Map padł przez zablokowany zawór zbiornika - lekcja dla kwalifikacji @nasa2023lunahmap
- puenta: "iodine enables substantial system miniaturization and simplification, which provides small satellites and satellite constellations with new capabilities for deployment, collision avoidance, end-of-life disposal and space exploration" @rafalskyi2021iodine (abstrakt)

*De-orbitacja*
- czy obecnie jest problemem, że trzeba je projektować tak, żeby same sie deorbitowały? czy gdyby miały zdolność do świadomego deorbitowania, to mogłyby tam siedzieć dłużej?
- regulacje wymagają *rezultatu* (zejścia z LEO w limicie czasu), nie narzucają środka - pasywna samodeorbitacja to tylko jeden z wariantów:
  - FCC 22-74 (IX 2022): "space stations ending their mission in, or passing through, the LEO region below 2000 km altitude and planning disposal through uncontrolled atmospheric re-entry to complete disposal as soon as practicable following end of mission, and no later than five years after the end of mission" @fcc2022deorbit (¶18; 47 CFR § 25.283(e))
  - kluczowa definicja: "end of mission" = "the time at which the individual spacecraft is no longer capable of conducting collision avoidance maneuvers" → satelita z napędem sam decyduje, kiedy startuje 5-letni zegar @fcc2022deorbit (¶18)
  - obowiązuje też satelity non-US z dostępem do rynku USA; w życie 09.09.2024, wymóg od 29.09.2024 (wcześniej 2-letnie grandfathering) @fcc2025guide
  - ESA (wewnętrzne wymogi, XI 2023): faza disposal w LEO skrócona "from 25 to a maximum of five years", P(sukcesu) > 90%, dodatkowe wymogi dla konstelacji @esoc2023requirements; Zero Debris Charter (2023) - niewiążący, cel na 2030 @esa2023charter
  - IADC 5.3.2 i ODMSP pkt 4-1.b: klasyczne 25 lat - wciąż standard poza FCC/ESA @iadc2025guidelines @usg2019odmsp
- bez napędu zgodność z 5 latami = praca nisko → krótka misja:
  - CubeSat 1-3U: start \<400 km → życie \<6 mies.; >550 km → >5 lat niezależnie od aktywności słonecznej @russell2026lifetime
  - CubeSat 5 kg (i = 30°): 500 km → 7,4 lat; 550 km → 15,8; 600 km → 31,8; 650 km → 61,4 lat @brito2015decay (tab. 1-3); wniosek autorów: "the maximum altitude at which this satellite can be allocated is around 550 km" dla zgodności z europejskim kodem
  - NASA SOTA: "at orbital altitudes beyond 500 km, there is no guarantee the spacecraft will deorbit within that timeframe and some may have trouble deorbiting in under 25 years" @nasaSota2023deorbit (s. 371-372)
  - praktyka projektowa bez napędu: "spacecraft are launched in a lower orbit for a natural decay within a few years or equipped with deorbit systems" @nasaSota2023deorbit (s. 369-370)
- z napędem: wyżej + dłużej + aktywne zejście na koniec:
  - ExoTerra Courier (SEP, 12U): "provides up to 1 km/s of delta-v... spiraling to 800 km from a drop-off orbit of 400 km and then deorbiting" - operacja na 800 km (pasywnie niezgodna z 5 latami) + kontrolowana deorbitacja @nasaSoa2026 (s. 94)
  - typowy cykl misji z EP: "orbit raising, orbit maintenance, and de-orbit" @nasaSoa2026 (s. 95-96)
  - dla CubeSatów naukowych FCC przewiduje zwolnienia case-by-case (NASA SMD opiera deorbitację na naturalnym opadzie) @fcc2025guide
- praktyka (ESA SER 2026): 88-99% satelitów \<1000 kg kończących misję od 2020 spełnia 25-letnią regułę - ale głównie *naturalnie* (niska orbita); przy progu 5 lat z niezgodnych naprawia zgodność tylko 5-35% @esa2026ser (Exec. Summary s. 5-6; Fig. 6.28)

==== *Jakie technologie napędu wykorzystują, jak często, i czemu takie a nie inne. Jakie są trendy wzrostowo-spadkowe wykorzystania*

- co realnie lata na nanosatach (technologia → liczby):
  - cold gas - liczbowo dominanta: "Among civilian applications, cold gas propulsion prevails over other chemical options" @shumeiko2026trends (s. 26, Fig. 20); MarCO (R236fa, 8 × 25 mN) @alnaqbi2024review (s. 11); MEMS: NanoProp 3U (butan; TW-1 2015, GOMX-4B 2018) @hsu2023compendium (s. 83-84)
  - FEEP - najliczniejsza EP klasy nanosatelitarnej: 194 systemy Enpulsion (185 NANO + 2 MICRO R3 + 7 NANO AR3) na 79 satelitach od 2018 @enpulsionHeritage (abstrakt AIAA SciTech 2024)
  - FEEP-MEMS na 1U: NanoFEEP (Ga, \<40 µN, \<3 W, 0,16 kg) @nasaSoa2026 (tab. 4-8)
  - elektrospray MEMS: S-iEPS (MIT) - AeroCube-8A&B (2015); TILE (Accion) - BeaverCube (2022) @alnaqbi2024review (s. 29-30)
  - jodowy GIT: NPT30-I2 - "As of July 2023, ThrustMe reported more than 100 systems on order" @nasaSoa2026 (s. 89); wg producenta 242 systemy wyniesione na >100 satelitów (2026) @thrustme2026hundred
  - jod jako cold gas: I2T5 (0,2 mN) - pierwszy jodowy system w kosmosie (Xiaoxiang 1-08, 2019) @nasaSoa2026 (s. 22)
  - PPT/VAT - dopiero wchodzi: DUPLEX (6U) dostarczony na ISS (IX 2025) @nasaSoa2026 (s. 27); w ocenie integracji smallsat: PPT 4/13 pkt, VAT "receiving zero points" @shumeiko2026trends (tab. 13, s. 33)
  - Hall - na \<10 kg praktycznie nie lata: BHT-200 (13 mN, 250 W) - loty na mikrosatelitach (TacSat-2, FalconSat-5/6); mini-Hall 20 W (Aliena MUSIC-SI) dopiero status "engineering to flight" @nasaSoa2026 (tab. 4-10)
  - chemiczne green: EPSS (ADN) - pierwszy chemiczny napęd na CubeSacie (LituanicaSAT-2, 2017) @hsu2023compendium (s. 131); woda + elektroliza: HYDROS-C (PTD-1, 2021) @alnaqbi2024review (s. 21-22)
- czemu takie a nie inne:
  - moc: nano-satelita 1-10 kg ma ~100 W na busa, CubeSat ~2 kg "few to tens of W" @hsu2023compendium (tab. 1, s. 4); przy EP \<75 mN/kW nawet 500 W daje tylko 38 mN @nasaSoa2026 (s. 65: "electric propulsion generally provides thrust-to-power levels below 75 mN/kW")
  - → na napęd realnie zostaje kilka-kilkanaście W → FEEP/elektrospray (µN-sub-mN) albo cold gas; Hall (250 W+) odpada
  - objętość i masa: "The miniaturization of propulsion technologies is challenging due to the limited volume available and limited power budget for propulsion systems in small satellites." @alnaqbi2024review (s. 2)
  - przepisy wynoszenia: CDS - "Propulsion systems shall have at least 3 inhibits to activation" + zgodność z AFSPCMAN 91-710 @cdsRev14 (pkt 2.1.3-2.1.6, s. 10); hydrazyna toksyczna (SCAPE) → wysokie koszty integracji @nasaSoa2026
  - paliwo: ksenon drogi i rzadki + presjonizowane zbiorniki vs jod stały niepresjonizowany: "propellant that can be stored unpressurized will help simplify satellite design and propulsion system integration and reduce the market demand for xenon" @rafalskyi2021iodine; ITAR-free @thrustmeNpt30
- trendy:
  - liczba systemów: 115 (2019) → 336 (2023) @hsu2023compendium (s. 15); elektryczne 155 vs chemiczne 167, ale TRL ≥ 7 ma ~37% chemicznych vs ~16% elektrycznych @hsu2023compendium (s. 9)
  - EP dominuje w lotnych misjach smallsat: "predominance of electric propulsion technology, especially electrospray propulsion, accounting for 82% out of the 305 missions analyzed" @shumeiko2026trends (s. 25, Fig. 19) [zdanie wieloznaczne - przy pisaniu prozy sprawdzić Fig. 19]
  - jod ↑ kosztem ksenonu: "the storage density of I2 is three times higher compared to xenon" @mazouffre2016ep (s. 22); popyt na ksenon może wyprzedzić podaż w ~10 lat @rafalskyi2021iodine
  - FEEP i metalowe PPT ↑: "FEEPs and Metal PPTs are emerging, as they offer integration simplicity (no moving parts and solid propellant storage)" @hsu2023compendium (s. 16)
  - MEMS/tablice emitorów ↑ @shumeiko2026trends (s. 12); green propellants i woda ↑ @hsu2023compendium (s. 17)
  - na horyzoncie: ABEP dla VLEO - ABIE-X (proof-of-concept on-orbit) @yamamoto2026abiex

// Tu koniec punktów, reszta notatek jest stara

==== Dalsze gówno notatki

// SZKIC - notatki, docelowo przerobić na pełną prozę.
// Układ: potrzeba -> stan ogólny -> co lata -> kierunki -> wyzwania -> puenta.

*Dlaczego nanosatelita potrzebuje napędu:*
- funkcje: podnoszenie orbity (orbit-raising), utrzymanie orbity (station-keeping), unikanie kolizji, formacje i podloty, deorbitacja końca misji, trajektorie międzyplanetarne @krejci2018ieee @nasaSoa2026
- wymóg regulatorowy: FCC (IX 2022) - deorbitacja w ≤ 5 lat po zakończeniu misji dla satelitów z licencją FCC; napęd (lub mechanizm bezpaliwowy) staje się wymogiem projektowym @fcc2022deorbit
- realne przypadki: UWE-4 (1U) - *obniżenie orbity* (demonstracja deorbitacji; ~5 µN z eksperymentu rotacji) - NIE faktyczny unik kolizji @kramer2020uwe4 @nasaSoa2026 (s. 86); NorSat-TD - napęd NPT30-I2: zdolność unikania kolizji jako cel misji + realny manewr podniesienia orbity (+~20 km, 01.2024) @nasaSoa2026 (s. 89) @nosa2024norsattd; LituanicaSAT-2 - EPSS na ADN: korekta orientacji, unik kolizji, wydłużenie życia @nasaSoa2026 (s. 73)
- kontekst rynkowy: 3417 nanosatelitów wyniesionych do VII 2026, spodziewane tysiące kolejnych @nanosatsDatabase - napęd wciąż tylko u mniejszości floty, jego udział rośnie @hsu2023compendium

*Zakresy parametrów urządzeń dla smallsatów (NASA SOTA 2026):* @nasaSoa2026
- cold gas: 10 µN - 3.6 N, I~sp~ 40-110 s
- elektrotermiczne: 0.1 mN - 1 N, I~sp~ 20-350 s
- elektrospray: 20 µN - 20 mN, I~sp~ 225-3000 s
- silnik jonowy z siatkami (GIT): 0.1-20 mN, I~sp~ 500-3000 s
- Hall: 0.25-55 mN, I~sp~ 200-1920 s
- PPT/VAT: 4-500 µN, I~sp~ 87-3200 s

*Stan ogólny (rynek i dojrzałość):*
- liczba systemów napędowych dla smallsatów w compendium Aerospace: 115 (2019) → 336 (2023); elektrycznych 155, chemicznych 167 @hsu2023compendium
- dojrzałość: chemiczne \~37% z TRL ≥ 7, elektryczne \~16% - EP dogania, ale wolniej @hsu2023compendium
- EP: impuls całkowity rząd wielkości wyższy niż chemiczne, ale siła \< 75 mN/kW mocy i wymóg wielogodzinnej pracy @nasaSoa2026 @mazouffre2016ep
- klasa nanosatelity: 1-10 kg, \~100 W mocy na busa - dla napędu realnie zostaje pojedyncze - kilkadziesiąt W @hsu2023compendium
- TRL-e samoraportowane przez producentów, trudne do weryfikacji -> NASA SOTA klasyfikuje urządzenia po "Progress toward Mission Infusion": Concept / In-Development / Engineering-to-Flight / Flight-Demonstrated @nasaSoa2026
- rynek przesycony ("over-abundance"): duplikaty technologii u wielu producentów, churn i przejęcia start-upów @hsu2023compendium

*Co realnie lata (technologie + przykłady):*
- cold gas - dominanta liczbowo; MarCO (2018): pierwsze międzyplanetarne napędzane CubeSaty, VACCO MiPS (mikrotechnologia ChEMS™), R236fa, 8 × 25 mN, 755 N·s, ΔV 40 m/s @vaccoMarco @hsu2023compendium (s. 110) @nasaSoa2026
- jod jako zimny gaz: ThrustMe I2T5 (sublimacyjny) - pierwszy jod w kosmosie (Xiaoxiang 1-08, 2019; potem NAPA-2, Spire L3C, Robusta-3A) @nasaSoa2026
- FEEP: Enpulsion Nano (IFM Nano, ind) - pierwszy lot 2018 (Flock 3P, \~220 µN); łącznie 185 syst. NANO (+9 innych) na 79 satelitach od 2018 - najbardziej rozpowszechniony EP klasy nanosatelitarnej @nasaSoa2026 @enpulsionHeritage
- MEMS-FEEP: NanoFEEP (TU Dresden / Morpheus Space; głowica Ø13 × 21 mm, \< 6 g, gal) na UWE-4 - pierwsza EP na 1U; lecz 3 z 4 głowic anomalie, m.in. impingement strumienia na antenę @bock2018nanofeep @kramer2020uwe4 @nasaSoa2026
- elektrospray: MIT iEPS / Accion TILE - tablice emitorów typu MEMS (loty: AeroCube-8A&B 2015, BeaverCube/TILE-2 2022 @alnaqbi2024review s. 29-30); impulsy \< 10 µN·s; precyzję dowiódł Busek CMNT na LISA Pathfinder @hsu2023compendium @nasaSoa2026
- GIT na jodzie: ThrustMe NPT30-I2 (RF, 1U/1.5U, do \~5.5 kN·s w 1U) - pierwsza elektryczna EP na jodzie (Beihangkongshi-1, 2020/21, zmiana wysokości \~700 m, publikacja w Nature); > 100 szt. w zamówieniach @rafalskyi2021iodine @thrustmeNpt30 @nasaSoa2026
- GIT: Busek BIT-3 (RF, jod stały) jako napęd główny Lunar IceCube i LunaH-Map (6U, Artemis I); LunaH-Map unieruchomił zablokowany zawór zbiornika - przykład ryzyka kwalifikacji @nasaSoa2026
- Hall: na klasie \< 10 kg praktycznie nie lata (Busek BHT-200, 250 W - loty na mikrosatelitach TacSat-2, FalconSat-5/6; planowany jodowy Hall na 12U NASA iSat anulowany) @nasaSoa2026 (tab. 4-10) @hsu2023compendium
- chemiczne miniaturyzowane: EPSS na ADN (NanoAvionics, LituanicaSAT-2; uwaga: LMP-103S to preparat ECAPS HPGP - latał na ArgoMoon), hybrydowy MiPS na ArgoMoon (Artemis I), elektroliza wody HYDROS-C (NASA PTD-1) - wysoki TRL, lecz toksyczność i masa zbiorników/przelotowych @nasaSoa2026 (s. 71, 73)

*Kierunki badawcze (najbliżej tematu pracy):*
- mikrofabrykacja/MEMS jako droga do "scalania" napędu: tablice elektrospray, NanoFEEP (Si), ChEMS - brak ruchomych części, produkcja seryjna, paliwo stałe w strukturze @levchenko2018micropropulsion @alnaqbi2024review
- nanomateriały: emitory polowe (CNT itp.), poprawa wydajności i trwałości mikroźródeł jonów @levchenko2018nanomaterials
- jod zamiast ksenonu: gęstość magazynowania \~3× większa, stały przy niskiej pr. pary; otwarte pytania: silny utleniacz, kompatybilność materiałowa, trwałość długoterminowa @nasaSoa2026 @rafalskyi2021iodine
- ABEP do VLEO: pobieranie gazu atmosferycznego jako paliwa; ABIE-X (2026) - pierwsze on-orbit proof-of-concept @yamamoto2026abiex; Kreios Space + NanoAvionics (2026) - plan pierwszej orbitalnej demonstracji ABEP @kreios2026abep; przegląd mechanizmów @duppada2026abep
- bezpaliwowe (propellantless): żagle, drag sails, plasma brake - tanie deorbitacje, ale bez kontroli trajektorii @nasaSoa2026

*Wyzwania (luka, którą adresuje ta praca):*
- moc: siła EP przy \< 75 mN/kW → sub-mN przy mocy nanosatelity; misje wymagają długich okien pracy @nasaSoa2026
- pomiar: siły rzędu µN wymagają mikrowag i głębokiej próżni - charakteryzacja mikro-napędów to wąskie gardło @hsu2023compendium
- trwałość: kondensacja metalu (In/Ga) na elektrodach, jod jako utleniacz, degradacja emitorów; mało długich testów życia @nasaSoa2026
- integracja: impingement strumienia na panele/payload (przypadek UWE-4) - potrzeba dobrej charakterystyki plazmy @kramer2020uwe4 @nasaSoa2026
- kwalifikacja: brak standardów TRL/kwalifikacji dedykowanych mikro-napędom @hsu2023compendium @nasaSoa2026
- puenta: FEEP i GIT na jodzie przeszły z pokazów do operacyjnej fazy; silniki jonowe w technologii MEMS z siatkami dopiero wchodzą - stąd potrzeba charakterystyki prototypu (ta praca)

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

#rys("images/stanowisko.jpg", "Całe stanowisko pomiarowe")

=== Obudowa silnika

#rys("images/3d-enc/pic-pcb.jpg", "Złącze komory próżniowej, pod które projektowana była obudowa", width: 60%)

#figure(caption: "Płytka PCB", grid(
  columns: 2,
  image("images/3d-enc/pcb-angle.png"), image("images/3d-enc/pcb-top.png"),
))

#figure(caption: "Otoczka do goldpinów", grid(
  columns: 3,
  image("images/3d-enc/goldpin_hs-angle.png"),
  image("images/3d-enc/goldpin_hs-angle-section.png"),
  image("images/3d-enc/goldpin_hs-side-section.png"),
))

#figure(caption: "Trzymak do krzemu", {
  grid(
    columns: 3,
    image("images/3d-enc/si_hs-angle-back.png"),
    image("images/3d-enc/si_hs-angle.png"),
    image("images/3d-enc/si_hs-angle-section.png"),
  )
  grid(
    columns: (40%, 40%),
    image("images/3d-enc/si_hs-side.png"), image("images/3d-enc/si_hs-side-section.png"),
  )
})

#rys("images/3d-enc/all-angle.png", "Finał"),

#grid(
  columns: 2,
  rys("images/3d-enc/pic-all.jpg", "tak"), rys("images/3d-enc/pic-all-zoom.jpg", "tak"),
)

#grid(
  columns: 2,
  rys("images/3d-enc/pic-goldpin_hs-2.jpg", "tak"), rys("images/3d-enc/pic-goldpin_hs-3.jpg", "tak"),
)


=== Urządzenia do pomiarów elektrycznych i ich automatyzacja

=== Automatyczna kontrola zaworu

#grid(
  columns: 2,
  rys("images/kretacz/krecidlo.png", "krecidlo"), rys("images/kretacz/nad-krecidlo.png", "krecidlo"),
  rys("images/kretacz/trzymak-dol.png", "dol"), rys("images/kretacz/all.png", "all"),
)

== Pomiary

== Wnioski z pomiarów



= Wnioski ogólne i podsumowanie

#bibliography("bibliography.bib", style: "ieee", title: "Bibliografia", full: true)
