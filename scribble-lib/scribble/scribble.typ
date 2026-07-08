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
