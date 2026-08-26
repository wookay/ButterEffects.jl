# Effects

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
