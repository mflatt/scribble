// As for HTML output (and unlike Latex output), footnote content is
// rendered in a block at the end of the enclosing section, and the
// footnote reference is a superscript number that links to the
// content:
#let Footnote(body) = body
#let FootnoteRef(body) = super(body)
#let FootnoteRefNumber(body) = body
#let FootnoteTarget(body) = super(body)
#let FootnoteTargetNumber(body) = body
#let FootnoteContent(body) = body
#let FootnoteMarginContent(body) = footnote(body)
#let FootnoteBlock(body) = body
#let FootnoteBlockContent(body) = text(size: 0.85em, body)

// A `note` margin note is rendered as a regular footnote:
#let NoteBox(body) = footnote(body)
#let NoteContent(body) = body
