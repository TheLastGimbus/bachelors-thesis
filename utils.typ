////////////////////////////////////////
/// STYLING ////////////////////////////
////////////////////////////////////////


#let mathSettings(doc) = {
  show math.ast: it => math.dot
  show math.equation: it => {
    show regex("\d+\.\d+"): num => num.text.replace(".", ",")
    it
  }
  doc
}

// You can apply all of the above, or this one to set everything
#let matiSettings(doc) = {
  set page(margin: 1.7cm, numbering: "1", number-align: end)
  show link: underline
  set heading(numbering: "1.")
  set figure(supplement: "Rys")
  set par(first-line-indent: 1em)
  set text(lang: "pl")
  set grid(gutter: 2em)

  show: mathSettings

  doc
}


#let title(tekst) = {
  set align(center)
  set text(size: 20pt)
  tekst
}

#let callout(body, color: rgb(0, 0, 0, 32)) = box(
    radius: 5pt,
    width: 100%,
    inset: 6pt,
    fill: color
)[#body]

#let cToK(c) = c+273.15
