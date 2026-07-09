#let SVersion(version) = [Version #version]

#let Stitle(title: [],
            version: none,
            authors: none,
            date: none) = {
  align(center)[#text(1.8em, weight: "bold", title)]
  if version != none {
    align(center)[#text(1.1em, version)]
  }
  if authors != none {
    for author in authors {
      align(center)[#author]
    }
  }
  if date != none {
    align(center)[#date]
  }
}

#let Sheading(depth: none, outlined: true, hidden: false, content) = {
  if hidden and outlined {
     show heading: none
     heading(depth: depth, content)
  } else {
    heading(depth: depth, outlined: outlined, content)
  }
}

#let Stt(body) = text(font: ("DejaVu Sans Mono",), size: 0.9em, body)

#let refpara(e) = e
#let refelem(e) = e
#let refcolumn(e) = e
#let refcontent(e) = e
#let refparaleft(e) = e
#let refelemleft(e) = e
#let refcolumnleft(e) = e
#let reffootnote(e) = footnote(e)
#let techoutside(e) = e
#let techinside(e) = e
#let plainlink(e) = e
#let indexlink(e) = e
#let bibentry(e) = e
#let nonavigation(e) = e
// A link whose target is not resolved; identity, as for Latex
// output, since unresolved cross-document references are common
// in a standalone rendering:
#let badlink(e) = e
#let noborder(e) = e
#let imageleft(e) = e
#let planetName(e) = e
#let Sendabbrev(e) = e
#let Sendsentence(e) = e

#let SInset(body) = block(inset: (left: 1em), body)
#let SCodeInset(body) = SInset(body)
#let SVerticalInset(body) = body

#let SHistory(body) = text(size: 0.85em, body)
#let SCentered(body) = align(center, body)
// A `subsubsub*section` title, rendered as a run-in heading:
#let SSubSubSubSection(body) = strong(body)

#let RpackageSpec(e) = e
#let RBackgroundLabel(body) = []
#let RBackgroundLabelInner(body) = body

#let leftindent(body) = block(inset: (left: 1em), body)

// Not styles that Scribble itself generates, but they are predefined
// for Latex output (via the "relsize" package and "scribble.tex"), so
// predefine them here, too:
#let smaller(body) = text(size: 0.83em, body)
#let larger(body) = text(size: 1.2em, body)
#let slant(body) = text(style: "oblique", body)

#let Stable(columns: [], ..content) = table(columns: columns, 
                                            stroke: none,
                                            inset: (x: 0pt, y: 0.25em),
                                             ..content)
#let Sboxed(columns: [], ..content) = block(width: 100%,
                                            fill: rgb("#E8E8FF"),
                                            inset: 3pt,
                                            Stable(columns: columns, ..content))
#let SVerbatim = Stable
