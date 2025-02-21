((inline_formula
  .
  (_) @_start
  (_)? @_end
  .
  ) @math.outer
  (#make-range! "math.inner" @_start @_end))

(inline_formula) @math.outer

((displayed_equation
  .
  (_) @_start
  (_)? @_end
  .
  ) @math.outer
  (#make-range! "math.inner" @_start @_end))

(displayed_equation) @math.outer
