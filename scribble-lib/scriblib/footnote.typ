// As for HTML output (and unlike Latex output), footnote content is
// rendered in a block at the end of the enclosing section, and the
// footnote reference is a superscript number that links to the
// content:
#let Footnote(body) = footnote(body)
#let FootnoteRef(body) = []
#let FootnoteRefNumber(body) = body
#let FootnoteTarget(body) = []
#let FootnoteTargetNumber(body) = body
#let FootnoteContent(body) = body
#let FootnoteMarginContent(body) = footnote(body)
#let FootnoteBlock(body) = []
#let FootnoteBlockContent(body) = []

// A `note` margin note is rendered as a regular footnote:
#let NoteBox(body) = footnote(body)
#let NoteContent(body) = body
