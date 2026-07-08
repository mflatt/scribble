// The default Scribble prefix for Typst output; use the `--prefix`
// flag (or `#:prefix-file` argument) to substitute a different prefix.
#set page(numbering: "1")
#set par(justify: true)
// The default style file for Typst output, which is empty; use the
// `--style` flag (or `#:style-file` argument) to substitute a
// different style file, or use `++style` (or `#:style-extra-files`)
// to add rules after this one. For example, a style file might
// contain
//    #show link: set text(fill: rgb("#07497f"))
// to color hyperlinks.
#set document(title: "Title")

#align(center)[#text(1.8em, weight: "bold")[Title]]
#align(center)[#text(1.1em)[Version 1.0]]

#metadata(none) <x28part_x22Titlex22x29>

= 1. Section <x28part_x22Sectionx22x29>

This is a top\-level section.

== 1.1. Subsection <x28part_x22Subsectionx22x29>

This is a subsection.

=== 1.1.1. Subsubsection <x28part_x22Subsubsectionx22x29>
#metadata(none) <x28modx2dpath_x22racketx2fstringx22x29>

This is a subsubsection.

Here is an itemize:

- Item 1.

- Item 2.

Here is a hyperlink:

#link("http://racket-lang.org/")[I am a hyperlink to Racket.]

#link("http://racket-lang.org/")[I am a #strong[Bold] hyperlink to Racket.]

#link("http://racket-lang.org/")[I am a #strong[Bold] hyperlink to Racket with \[wacky characters\]\(blah blah\).]

#emph[Italic].
\_Just underlines\_.

#strong[Bold].
\*Just asterisks.\*

“Dobule quoted”.
‘Single quoted’.

This should NOT be ‘code‘ in Markdown.

Example of vebatim:

#table(
  columns: 1,
  stroke: none,
  [#raw("Hi, world.")
], 
  [#raw("A ``quote''.")
], 
  [#raw("Second line.")
], 
  [#raw("Last line.")
], 
)

Another example of verbatim, with ticks\/quotes:

#table(
  columns: 1,
  stroke: none,
  [#raw("THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS")
], 
  [#raw("``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT")
], 
  [#raw("LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR")
], 
  [#raw("A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT")
], 
  [#raw("HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,")
], 
  [#raw("SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT")
], 
  [#raw("LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,")
], 
  [#raw("DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY")
], 
  [#raw("THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT")
], 
  [#raw("(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE")
], 
  [#raw("OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.")
], 
)

Example of a defmodule:

#raw(block: true, lang: "racket", " (require racket/string)")

Example of a defproc:

#block(inset: (left: 1em))[
#raw(block: true, lang: "racket", "procedure                       \n(make-string k [char]) → string?\n  k : exact-nonnegative-integer?\n  char : char? = #\\nul          ")
#metadata(none) <x28def_x28x28lib_x22racketx2fstringx2erktx22x29_makex2dstringx29x29>
]

Returns a new mutable string of length #raw("k") where each position in the
string is initialized with the character #raw("char")

Blah blah #raw("(")#raw("or/c")#raw(" ")#raw("string?")#raw(" ")#raw("bytes?")#raw(")").

Example of Scribble #raw("examples"):

Examples:

#block(inset: (left: 1em))[
#raw(block: true, lang: "racket", "> (define x 0) \n> (displayln x)\n0              ")

]

Example of Scribble #raw("interaction"):

#block(inset: (left: 1em))[
#raw(block: true, lang: "racket", "> (define x 0)\n> x           \n0             ")

]

#block(inset: (left: 1em))[
#block(inset: (left: 1em))[
Note: This is a note. Let’s make it long enough that the
markdown output will have to line\-wrap, to make sure the \> mark starts
each line properly.

]

]
