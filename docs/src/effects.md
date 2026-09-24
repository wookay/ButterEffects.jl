# Effects

!!! note
    doc from
    - julia/Compiler/src/effects.jl

```julia-repl
julia> using ButterEffects

help?> +c
### Effects: +c
...
```

## effectbits letters
```
+c   -c   ?c
+e   -e   ?e
+re  -re  ?re
+n   -n
+t   -t
+s   -s
+m   -m   ?m
+u   -u   ?u
+o   -o   ?o
+r   -r
```

## effectbits suffixes
```
c  e  re  n  t  s  m  u  o  r
```

## effect settings
```
:consistent
:effect_free
:reset_safe
:nothrow
:terminates_globally
:terminates_locally
:notaskstate
:inaccessiblememonly
:noub
:noub_if_noinbounds
:nonoverlayed
:consistent_overlay
:nortcall
:foldable
:removable
:total
```

## effectbits consts
```
CONSISTENT_IF_NOTRETURNED
CONSISTENT_IF_INACCESSIBLEMEMONLY
EFFECT_FREE_IF_INACCESSIBLEMEMONLY
RESET_SAFE_IF_INACCESSIBLEMEMONLY
INACCESSIBLEMEM_OR_ARGMEMONLY
NOUB_IF_NOINBOUNDS
CONSISTENT_OVERLAY
```

## effects functions
```@docs
Compiler.is_consistent
Compiler.is_nothrow
Compiler.is_foldable_nothrow
Compiler.is_effect_free
Compiler.is_consistent_if_inaccessiblememonly
Compiler.is_effect_free_if_inaccessiblememonly
Compiler.is_notaskstate
Compiler.is_noub
Compiler.is_finalizer_inlineable
Compiler.is_inaccessiblememonly
Compiler.is_nortcall
Compiler.is_foldable
Compiler.is_terminates
Compiler.is_inaccessiblemem_or_argmemonly
Compiler.is_consistent_if_notreturned
Compiler.is_removable_if_unused
Compiler.is_consistent_overlay
Compiler.is_noub_if_noinbounds
Compiler.is_nonoverlayed
```

```@docs
# if VERSION >= v"1.14.0-DEV.2872"
# Compiler.is_reset_safe
# Compiler.is_reset_safe_if_inaccessiblememonly
```
