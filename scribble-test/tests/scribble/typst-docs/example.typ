// The default Scribble prefix for Typst output; use the `--prefix`
// flag (or `#:prefix-file` argument) to substitute a different prefix.
#set page(numbering: "1")
#set par(justify: true)
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
// The default style file for Typst output, which is empty; use the
// `--style` flag (or `#:style-file` argument) to substitute a
// different style file, or use `++style` (or `#:style-extra-files`)
// to add rules after this one. For example, a style file might
// contain
//    #show link: set text(fill: rgb("#07497f"))
// to color hyperlinks.
// Style definitions for rendering Racket code in Typst output,
// following the colors of "racket.css". This file is included after
// the prefix file and before any style files, so a style file (as
// supplied with the `--style` or `++style` flags) can shadow these
// definitions with new `#let` bindings.
#let RktPlain(body) = Stt(body)
#let RktBlk(body) = Stt(body)
#let RktIn(body) = highlight(fill: rgb("#eeeeee"), Stt(text(fill: rgb("#cc6633"), body)))
#let RktInBG(body) = highlight(fill: rgb("#eeeeee"), body)
#let RktRdr(body) = Stt(body)
#let RktPn(body) = Stt(text(fill: rgb("#843c24"), body))
#let RktMeta(body) = Stt(body)
#let RktMod(body) = Stt(body)
#let RktKw(body) = Stt(body)
#let RktOpt(body) = Stt(text(style: "italic", body))
#let RktErr(body) = text(fill: red, style: "italic", body)
#let RktVar(body) = Stt(text(fill: rgb("#262680"), style: "italic", body))
#let RktSym(body) = Stt(text(fill: rgb("#262680"), body))
#let RktSymDef(body) = RktSym(body)
#let RktValLink(body) = Stt(text(fill: rgb("#0000ff"), body))
#let RktValDef(body) = RktValLink(body)
#let RktModLink(body) = Stt(text(fill: rgb("#0000ff"), body))
#let RktStxLink(body) = body
#let RktStxDef(body) = RktStxLink(body)
#let RktRes(body) = Stt(text(fill: rgb("#0000af"), body))
#let RktOut(body) = Stt(text(fill: rgb("#960096"), body))
#let RktCmt(body) = Stt(text(fill: rgb("#c2741f"), body))
#let RktVal(body) = Stt(text(fill: rgb("#228b22"), body))
#let highlighted(body) = highlight(fill: rgb("#ddddff"), body)

// For `filebox`:
#let Rfilebox(body) = body
#let Rfiletitle(body) = align(right, body)
#let Rfilename(body) = box(fill: rgb("#ECF5F5"),
                           stroke: (top: 0.6pt + rgb("#6C8585"), right: 0.6pt + rgb("#6C8585")),
                           inset: (x: 0.5em, y: 2pt),
                           body)
#let Rfilecontent(body) = body

// For inherited-method labels in `defclass`:
#let inheritedlbl(body) = text(style: "italic", body)

// The default style file for Typst output, which is empty; use the
// `--style` flag (or `#:style-file` argument) to substitute a
// different style file, or use `++style` (or `#:style-extra-files`)
// to add rules after this one. For example, a style file might
// contain
//    #show link: set text(fill: rgb("#07497f"))
// to color hyperlinks.
#set document(title: "Title")

#align(center)[#text(1.8em, weight: "bold")[Title]]
#align(center)[#text(1.1em)[Version 1\.0]]

#metadata(none)<x28part_x22Titlex22x29>

= 1. Section <x28part_x22Sectionx22x29>

This is a top\-level section\.

== 1.1. Subsection <x28part_x22Subsectionx22x29>

This is a subsection\.

=== 1.1.1. Subsubsection <x28part_x22Subsubsectionx22x29>
#metadata(none)<x28modx2dpath_x22racketx2fstringx22x29>

This is a subsubsection\.

Here is an itemize:

#list(
[Item 1\.
],
[Item 2\.
])
Here is a hyperlink:

#link("http://racket-lang.org/")[I am a hyperlink to Racket\.]

#link("http://racket-lang.org/")[I am a #strong[Bold] hyperlink to Racket\.]

#link("http://racket-lang.org/")[I am a #strong[Bold] hyperlink to Racket with \[wacky characters\]\(blah blah\)\.]

#emph[Italic]\.
\_Just underlines\_\.

#strong[Bold]\.
\*Just asterisks\.\*

“Dobule quoted”\.
‘Single quoted’\.

This should NOT be ‘code‘ in Markdown\.

Example of vebatim:

#table(
  columns: 1,
  stroke: none,
  inset: (x: 0pt, y: 0.25em),
  [#Stt[Hi, world\.]], 
  [#Stt[A \`\`quote\'\'\.]], 
  [#Stt[Second line\.]], 
  [#Stt[Last line\.]], 
)

Another example of verbatim, with ticks\/quotes:

#table(
  columns: 1,
  stroke: none,
  inset: (x: 0pt, y: 0.25em),
  [#Stt[THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS]], 
  [#Stt[\`\`AS IS\'\' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT]], 
  [#Stt[LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR]], 
  [#Stt[A PARTICULAR PURPOSE ARE DISCLAIMED\. IN NO EVENT SHALL THE COPYRIGHT]], 
  [#Stt[HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,]], 
  [#Stt[SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES \(INCLUDING, BUT NOT]], 
  [#Stt[LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,]], 
  [#Stt[DATA, OR PROFITS; OR BUSINESS INTERRUPTION\) HOWEVER CAUSED AND ON ANY]], 
  [#Stt[THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT]], 
  [#Stt[\(INCLUDING NEGLIGENCE OR OTHERWISE\) ARISING IN ANY WAY OUT OF THE USE]], 
  [#Stt[OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE\.]], 
)

Example of a defmodule:

#block(width: 100%, fill: rgb("#F5F5DC"), inset: 3pt)[
#table(
  columns: 2,
  stroke: none,
  inset: (x: 0pt, y: 0.25em),
  table.cell(colspan: 2)[#Stt[ ]#RktPn[\(]#RktSym[#badlink[#RktValLink[require]]]#Stt[ ]#link(label("x28modx2dpath_x22racketx2fstringx22x29"))[#RktModLink[#RktSym[racket\/string]]]#RktPn[\)]], 
)
]

Example of a defproc:

#block(inset: (left: 1em))[
#block(width: 100%, fill: rgb("#E8E8FF"), inset: 3pt)[
#table(
  columns: 1,
  stroke: none,
  inset: (x: 0pt, y: 0.25em),
  [#RBackgroundLabel[#RBackgroundLabelInner[procedure
]]#RktPn[\(]#metadata(none)<x28def_x28x28lib_x22racketx2fstringx2erktx22x29_makex2dstringx29x29>#RktSym[#badlink[#RktValLink[make\-string]]]#Stt[ ]#RktVar[k]#Stt[ ]#RktOpt[\[]#RktVar[char]#RktOpt[\]]#RktPn[\)]#Stt[ ]→#Stt[ ]#RktSym[#badlink[#RktValLink[string?]]]], 
  [#Stt[  ]#RktVar[k]#Stt[ ]:#Stt[ ]#RktSym[#badlink[#RktValLink[exact\-nonnegative\-integer?]]]], 
  [#Stt[  ]#RktVar[char]#Stt[ ]:#Stt[ ]#RktSym[#badlink[#RktValLink[char?]]]#Stt[ ]\=#Stt[ ]#RktVal[\#\\nul]], 
)
]

]

Returns a new mutable string of length #RktVar[k] where each position in the
string is initialized with the character #RktVar[char]

Blah blah #RktPn[\(]#RktSym[#badlink[#RktValLink[or\/c]]]#Stt[ ]#RktSym[#badlink[#RktValLink[string?]]]#Stt[ ]#RktSym[#badlink[#RktValLink[bytes?]]]#RktPn[\)]\.

Example of Scribble #RktSym[examples]:

Examples:

#block(inset: (left: 1em))[
#table(
  columns: 1,
  stroke: none,
  inset: (x: 0pt, y: 0.25em),
  [#Stt[\> ]#RktPn[\(]#RktSym[#badlink[#RktValLink[define]]]#Stt[ ]#RktSym[x]#Stt[ ]#RktVal[0]#RktPn[\)]], 
  [#Stt[\> ]#RktPn[\(]#RktSym[#badlink[#RktValLink[displayln]]]#Stt[ ]#RktSym[x]#RktPn[\)]], 
  [#RktOut[0]], 
)

]

Example of Scribble #RktSym[interaction]:

#block(inset: (left: 1em))[
#table(
  columns: 1,
  stroke: none,
  inset: (x: 0pt, y: 0.25em),
  [#Stt[\> ]#RktPn[\(]#RktSym[#badlink[#RktValLink[define]]]#Stt[ ]#RktSym[x]#Stt[ ]#RktVal[0]#RktPn[\)]], 
  [#Stt[\> ]#RktSym[x]], 
  [#RktRes[0]], 
)

]

#refpara[#refcolumn[#refcontent[Note: This is a note\. Let’s make it long enough that the
markdown output will have to line\-wrap, to make sure the \> mark starts
each line properly\.
]]]