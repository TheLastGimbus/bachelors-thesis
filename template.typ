// Szablon pracy dyplomowej – PWr, W12 WEFiM (wzór strony tytułowej: inz_pl_w12n.docx)

#let thesis(body) = {
  // Official .docx template uses "EB Garamond", but i like liberation :)
  set text(font: ("Liberation Serif"), size: 12pt, lang: "pl")

  // druk dwustronny: numer strony przy zewnętrznej krawędzi
  set page(
    paper: "a4",
    margin: (inside: 2.8cm, outside: 2.8cm, y: 2.5cm),
    footer: context align(
      if calc.even(here().page()) { left } else { right },
      counter(page).display(),
    ),
  )

  set par(justify: true, first-line-indent: (amount: 1.2em, all: true), spacing: 0.8em)
  set heading(numbering: "1.")
  set figure(supplement: "Rys.")
  set math.equation(numbering: "(1)")
  show link: underline
  
  set grid(gutter: 14pt)

  // cytowanie @key: obok referencji w tekście dodaje przypis dolny "Autor: Tytuł"
  //
  //Dlaczego to jest potrzebne — dwie rzeczy:
  // 1. Cytyj w tekście vs. w bibliografii. Twoje @key w rozdziałach to forma "normal" (renderuje się jako [1]). Ale tytuł bibliografii na końcu pracy też jest zbudowany z elementów cite — te mają formę "full" (pełny wpis, np. „1 IEEE, about CubeSat..."). Bez if każda pozycja w Bibliografii dostałaby też zbędny przypis ze sobą samym w treści.
  // 2. Rekurencja. Sam dodaję w przypisie cite(it.key, form: "full") — to jest też cytowanie, więc reguła show cite łapie je ponownie. Gdyby nie było if, ten wewnętrzny cite znów dostałby przypis, w którym znów jest cite, i tak w nieskończoność — Typst by się zapętlił. Dzięki if forma "full" przechodzi przez else bez zmian, więc łańcuch się urywa.
//  show cite: it => {
//    if it.form == "normal" {
//      context {
//        // przypis tylko przy PIERWSZYM cytowaniu danego źródła; przy kolejnych
//        // odwołaniach samej referencji [n] bez powtarzania przypisu.
//        // Uwaga: query(...).before(it.location()) zawiera też cytowanie bieżące,
//        // więc pierwsze wystąpienie daje prev.len() == 1.
//        let prev = query(cite.where(key: it.key, form: "normal").before(it.location()))
//        if prev.len() <= 1 {
//          // forma "full" z dedykowanym stylem CSL: przypis to sam "Autor: Tytuł"
//          // (styl ma identyczne layouty citation i bibliography, więc pełny wpis
//          // wygląda jak cytowanie). Lista autorów ≥ 6 skraca się do "X et al.".
//          it + footnote(numbering: _ => [], cite(it.key, supplement: it.supplement, form: "full", style: "footnote-author-title.csl"))
//        } else {
//          it
//        }
//      }
//    } else {
//      it
//    }
//  }

  // Em-dash 😏
  show " - ": it => {
    " – "
  }

  // ==== callout: linia zaczynająca się od "> " ====
  let callout-color = rgb(0, 0, 0, 32)

  // tekst węzła contentu: zwykły tekst daje swój tekst, element `space` daje spację,
  // cokolwiek innego (box itp.) — nic
  let node-text(node) = if node.has("text") { node.text } else if repr(node.func()) == "space" { " " } else { "" }

  // czy akapit zaczyna się od "> "? Zwykły tekst to jeden node "text"; z markupem
  // w środku body jest sekwencją, a "> " siedzi w pierwszym tekście — ewentualnie
  // rozpadszy się na ">" + element `space`, gdy zaraz za spacją jest markup (np. obrazek).
  // Guard "node-text(first) != ''" odcina paragrafy zaczynające się od elementu (boxa itp.)
  let is-callout(body) = {
    let nodes = if body.has("children") { body.children.slice(0, 2) } else { (body,) }
    nodes.len() > 0 and node-text(nodes.first()) != "" and nodes.map(node-text).join().starts-with("> ")
  }

  // callout: linia zaczynająca się od "> " — reszta linii może zawierać dowolny markup
  // (pogrubienia, math itp.). "> " wycina reguła regex wewnątrz bloku, więc nie
  // łapie "> " w środku zwykłych akapitów ani w blokach kodu.
  // Uwaga: goły #image(...) jest blokowy i wypada z callouta — inline'uj przez box.
  show par: it => {
    if is-callout(it.body) {
      block(radius: 5pt, width: 100%, inset: 6pt, fill: callout-color)[
        #show regex("^> "): it => []
        #show regex("^>$"): it => []
        #it
      ]
    } else {
      it
    }
  }

  // rozmiary nagłówków wg zaleceń; rozdziały od nowej strony
  show heading: set par(first-line-indent: 0pt)
  show heading.where(level: 1): set text(size: 25pt)
  show heading.where(level: 1): it => pagebreak(weak: true) + it
  show heading.where(level: 2): set text(size: 17pt)
  show heading.where(level: 3): set text(size: 14pt)

  // tabele: podpis nad tabelą
  show figure.where(kind: table): set figure(supplement: "Tab.")
  show figure.where(kind: table): set figure.caption(position: top)

  // poprawna polska matma
  show math.ast: it => math.dot
  show math.equation: it => {
    show regex("\d+\.\d+"): num => num.text.replace(".", ",")
    it
  }

  body
}

#let title-page(title, author, supervisor, field, year) = page(
  margin: 2.54cm,
  footer: none,
)[
  #set text(size: 14pt)
  #set par(first-line-indent: 0pt)

  #align(center)[
    #text(size: 16pt, weight: "bold")[Politechnika Wrocławska] \
    #text(size: 16pt)[Wydział Elektroniki, Fotoniki i Mikrosystemów]
  ]
  #line(length: 100%)
  Kierunek studiów: #field

  #v(1fr)
  #align(center, text(size: 32pt)[PRACA DYPLOMOWA \ INŻYNIERSKA])
  #v(1.5fr)
  #align(center, text(size: 16pt, title))
  #v(1.5fr)
  #align(center)[Autor: \ #author]
  #v(1cm)
  #align(center)[Opiekun: \ #supervisor]
  #v(2fr)

  #line(length: 100%)
  #align(center, text(size: 16pt)[Wrocław #year])
]

#let rys(path, cap, ..imgArgs) = figure(image(path, ..imgArgs), caption: cap)