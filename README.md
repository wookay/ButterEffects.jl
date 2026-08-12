# ButterEffects.jl 🧈

|  **Build Status**                |
|:---------------------------------|
|  [![][actions-img]][actions-url] |


```julia-repl
julia> using ButterEffects

help?> :noub
  :noub
  =====

  The :noub setting asserts that the method will not execute any undefined
  behavior (for any input). Note that undefined behavior may technically cause
  the method to violate any other effect assertions (such as :consistent or
  :effect_free) as well, but we do not model this, and they assume the absence
  of undefined behavior.

  – doc from julia/base/expr.jl macro assume_effects(args...)

help?> Base.PARTITION_KIND_IMPORTED
const PARTITION_KIND_CONST = 0x00
const PARTITION_KIND_CONST_IMPORT = 0x01
const PARTITION_KIND_GLOBAL = 0x02
const PARTITION_KIND_IMPLICIT_GLOBAL = 0x03
const PARTITION_KIND_IMPLICIT_CONST = 0x04
const PARTITION_KIND_EXPLICIT = 0x05
const PARTITION_KIND_IMPORTED = 0x06
const PARTITION_KIND_FAILED = 0x07
const PARTITION_KIND_DECLARED = 0x08
const PARTITION_KIND_GUARD = 0x09
const PARTITION_KIND_UNDEF_CONST = 0x0a
const PARTITION_KIND_BACKDATED_CONST = 0x0b

help?> Base.is_some_const_binding
  │ Warning
  │
  │  The following bindings may be internal; they may change or be
  │  removed in future versions:
  │
  │  • Base.is_some_const_binding

  (is_defined_const_binding(kind) || kind == PARTITION_KIND_UNDEF_CONST)
```

[actions-img]: https://github.com/wookay/ButterEffects.jl/workflows/CI/badge.svg
[actions-url]: https://github.com/wookay/ButterEffects.jl/actions
