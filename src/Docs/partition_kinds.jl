# module ButterEffects.Docs

# from julia/base/runtime_internals.jl
#=
const PARTITION_KIND_CONST              = 0x0
const PARTITION_KIND_CONST_IMPORT       = 0x1
const PARTITION_KIND_GLOBAL             = 0x2
const PARTITION_KIND_IMPLICIT_GLOBAL    = 0x3
const PARTITION_KIND_IMPLICIT_CONST     = 0x4
const PARTITION_KIND_EXPLICIT           = 0x5
const PARTITION_KIND_IMPORTED           = 0x6
const PARTITION_KIND_FAILED             = 0x7
const PARTITION_KIND_DECLARED           = 0x8
const PARTITION_KIND_GUARD              = 0x9
const PARTITION_KIND_UNDEF_CONST        = 0xa
const PARTITION_KIND_BACKDATED_CONST    = 0xb
=#

struct PartitionKind
    kind::UInt8
end

const partition_kinds = [
    :PARTITION_KIND_CONST,
    :PARTITION_KIND_CONST_IMPORT,
    :PARTITION_KIND_GLOBAL,
    :PARTITION_KIND_IMPLICIT_GLOBAL,
    :PARTITION_KIND_IMPLICIT_CONST,
    :PARTITION_KIND_EXPLICIT,
    :PARTITION_KIND_IMPORTED,
    :PARTITION_KIND_FAILED,
    :PARTITION_KIND_DECLARED,
    :PARTITION_KIND_GUARD,
    :PARTITION_KIND_UNDEF_CONST,
    :PARTITION_KIND_BACKDATED_CONST,
]

function Base.show(io::IO, mime::MIME"text/plain", part::PartitionKind)
    for kind in Base.PARTITION_KIND_CONST:Base.PARTITION_KIND_BACKDATED_CONST
        kind_sym = partition_kinds[kind+1]
        if kind == part.kind
            printstyled(io, "const ", kind_sym, " = ", repr(kind); color = :cyan)
        else
            print(io,       "const ", kind_sym, " = ", repr(kind))
        end
        println(io)
    end
end


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
