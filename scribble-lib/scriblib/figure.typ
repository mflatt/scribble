#let Ialign(dir, body) = align(dir, block(align(left, body)))

#let Figure(body) = block(width: 100%, body)
#let FigureMulti(body) = Figure(body)
#let FigureMultiWide(body) = Figure(body)
#let Herefigure(body) = block(width: 100%, Ialign(center, body))

#let Centerfigure(body) = block(width: 100%, Ialign(center, body))
#let Leftfigure(body) = block(width: 100%, Ialign(left, body))
#let Rightfigure(body) = block(width: 100%, Ialign(right, body))

#let FigureInside(body) = body

#let Legend(body) = block(width: 100%, stroke: (top: 0.33pt), inset: (top: 4pt), body)
#let LegendContinued(body) = Legend(body)

#let Centertext(body) = align(center, body)

#let FigureRef(body, ignored) = body
#let FigureTarget(body, ignored) = body
#let suppressfloats(body) = body
