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

# from julia/src/julia.h

function show_partitionkind(io::IO, mime::MIME"text/plain", kind::UInt8)
    doc = if kind == Base.PARTITION_KIND_CONST # 0x0
        """
    // Constant: This binding partition is a constant declared using `const _ = ...`
    //  ->restriction holds the constant value"""
    elseif kind == Base.PARTITION_KIND_CONST_IMPORT # 0x1
        """
    // Import Constant: This binding partition is a constant declared using `import A`
    //  ->restriction holds the constant value"""
    elseif kind == Base.PARTITION_KIND_GLOBAL # 0x2
        """
    // Global: This binding partition is a global variable. It was declared either using
    // `global x::T` to implicitly through a syntactic global assignment.
    //  -> restriction holds the type restriction"""
    elseif kind == Base.PARTITION_KIND_IMPLICIT_GLOBAL # 0x3
        """
    // Implicit: The binding was a global, implicitly imported from a `using`'d module.
    //  ->restriction holds the ultimately imported global binding"""
    elseif kind == Base.PARTITION_KIND_IMPLICIT_CONST # 0x4
        """
    // Implicit: The binding was a constant, implicitly imported from a `using`'d module.
    //  ->restriction holds the ultimately imported constant value"""
    elseif kind == Base.PARTITION_KIND_EXPLICIT # 0x5
        """
    // Explicit: The binding was explicitly `using`'d by name
    //  ->restriction holds the imported binding"""
    elseif kind == Base.PARTITION_KIND_IMPORTED # 0x6
        """
    // Imported: The binding was explicitly `import`'d by name
    //  ->restriction holds the imported binding"""
    elseif kind == Base.PARTITION_KIND_FAILED # 0x7
        """
    // Failed: We attempted to import the binding, but the import was ambiguous
    //  ->restriction is NULL."""
    elseif kind == Base.PARTITION_KIND_DECLARED # 0x8
        """
    // Declared: The binding was declared using `global` or similar. This acts in most ways like
    // PARTITION_KIND_GLOBAL with an `Any` restriction, except that it may be redefined to a stronger
    // binding like `const` or an explicit import.
    //  ->restriction is NULL."""
    elseif kind == Base.PARTITION_KIND_GUARD # 0x9
        """
    // Guard: The binding was looked at, but no global or import was resolved at the time
    //  ->restriction is NULL."""
    elseif kind == Base.PARTITION_KIND_UNDEF_CONST # 0xa
        """
    // Undef Constant: This binding partition is a constant declared using `const`, but
    // without a value.
    //  ->restriction is NULL"""
    elseif kind == Base.PARTITION_KIND_BACKDATED_CONST # 0xb
        """
    // Backated constant. A constant that was backdated for compatibility. In all other
    // ways equivalent to PARTITION_KIND_CONST, but prints a warning on access"""
    end

    # // This is not a real binding kind, but can be used to ask for a re-resolution
    # // of the implicit binding kind
    # PARTITION_FAKE_KIND_IMPLICIT_RECOMPUTE # 0xc
    # PARTITION_FAKE_KIND_CYCLE # 0xd

    doc_from = "-- doc from julia/src/julia.h"
    md = Markdown.MD(Any[Markdown.parse(doc, flavor=:common), Markdown.parse(doc_from)])
    Base.show(io, mime, md)
end

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
    println(io)
    show_partitionkind(io, mime, part.kind)
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
