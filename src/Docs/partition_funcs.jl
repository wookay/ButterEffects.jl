# module ButterEffects.Docs

"""
```julia
(kind == PARTITION_KIND_CONST || kind == PARTITION_KIND_CONST_IMPORT || kind == PARTITION_KIND_IMPLICIT_CONST || kind == PARTITION_KIND_BACKDATED_CONST)
```
"""
Base.is_defined_const_binding(kind::UInt8)

"""
```julia
(is_defined_const_binding(kind) || kind == PARTITION_KIND_UNDEF_CONST)
```
"""
Base.is_some_const_binding(kind::UInt8)

"""
```julia
(kind == PARTITION_KIND_IMPLICIT_GLOBAL || kind == PARTITION_KIND_IMPLICIT_CONST || kind == PARTITION_KIND_EXPLICIT || kind == PARTITION_KIND_IMPORTED)
```
"""
Base.is_some_imported(kind::UInt8)

"""
```julia
(kind == PARTITION_KIND_IMPLICIT_GLOBAL || kind == PARTITION_KIND_IMPLICIT_CONST || kind == PARTITION_KIND_GUARD || kind == PARTITION_KIND_FAILED)
```
"""
Base.is_some_implicit(kind::UInt8)

"""
```julia
(kind == PARTITION_KIND_EXPLICIT || kind == PARTITION_KIND_IMPORTED)
```
"""
Base.is_some_explicit_imported(kind::UInt8)

"""
```julia
is_some_explicit_imported(kind) || kind == PARTITION_KIND_IMPLICIT_GLOBAL
```
"""
Base.is_some_binding_imported(kind::UInt8)

"""
```julia
(kind == PARTITION_KIND_GUARD || kind == PARTITION_KIND_FAILED || kind == PARTITION_KIND_UNDEF_CONST)
```
"""
Base.is_some_guard(kind::UInt8)

# module ButterEffects.Docs
