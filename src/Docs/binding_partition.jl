# module ButterEffects.Docs

using Base: PARTITION_KIND_CONST, #
            PARTITION_KIND_CONST_IMPORT,
            PARTITION_KIND_GLOBAL,
            PARTITION_KIND_IMPLICIT_GLOBAL,
            PARTITION_KIND_IMPLICIT_CONST,
            PARTITION_KIND_EXPLICIT,
            PARTITION_KIND_IMPORTED,
            PARTITION_KIND_FAILED,
            PARTITION_KIND_DECLARED,
            PARTITION_KIND_GUARD,
            PARTITION_KIND_UNDEF_CONST,
            PARTITION_KIND_BACKDATED_CONST,
            PARTITION_FLAG_EXPORTED, #
            PARTITION_FLAG_DEPRECATED,
            PARTITION_FLAG_DEPWARN,
            # PARTITION_FLAG_IMPLICITLY_EXPORTED,
            # PARTITION_FLAG_IMPLICITLY_DEPRECATED,
            PARTITION_MASK_KIND, #
            PARTITION_MASK_FLAG

for (name, value) in [(:PARTITION_FLAG_IMPLICITLY_EXPORTED, 0x80),
                      (:PARTITION_FLAG_IMPLICITLY_DEPRECATED, 0x100)]
    if isdefinedglobal(Base, name)
        @eval using Base: $name
    else
        @eval const $name = $value
    end
end

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

const PARTITION_FLAG_EXPORTED     = 0x10
const PARTITION_FLAG_DEPRECATED   = 0x20
const PARTITION_FLAG_DEPWARN      = 0x40
const PARTITION_FLAG_IMPLICITLY_EXPORTED = 0x80
const PARTITION_FLAG_IMPLICITLY_DEPRECATED = 0x100

const PARTITION_MASK_KIND         = 0x0f
const PARTITION_MASK_FLAG         = 0x1f0
=#

struct PartitionKind
    kind::UInt8
end

struct PartitionFlag
    flag::UInt16
end

struct PartitionMask
    mask::UInt16
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

const partition_flags = [
    :PARTITION_FLAG_EXPORTED,
    :PARTITION_FLAG_DEPRECATED,
    :PARTITION_FLAG_DEPWARN,
    :PARTITION_FLAG_IMPLICITLY_EXPORTED,
    :PARTITION_FLAG_IMPLICITLY_DEPRECATED,
]

const partition_masks = [
    :PARTITION_MASK_KIND,
    :PARTITION_MASK_FLAG,
]

# from julia/src/julia.h

# from julia/base/show.jl
# printing bindings and partitions
# function print_partition(io::IO, partition::Core.BindingPartition)
function print_partition_kind(io::IO, kind::UInt8)
    # print(io, partition.min_world)
    # print(io, ":")
    # max_world = @atomic partition.max_world
    # if max_world == typemax(UInt)
    #     print(io, '∞')
    # else
    #     print(io, max_world)
    # end
    # if (partition.kind & PARTITION_MASK_FLAG) != 0
    #     flags = String[]
    #     (partition.kind & PARTITION_FLAG_EXPORTED)            != 0 && push!(flags, "exported")
    #     (partition.kind & PARTITION_FLAG_IMPLICITLY_EXPORTED) != 0 && push!(flags, "re-exported")
    #     (partition.kind & PARTITION_FLAG_DEPRECATED)          != 0 && push!(flags, "deprecated")
    #     (partition.kind & PARTITION_FLAG_DEPWARN)             != 0 && push!(flags, "depwarn")
    #     (partition.kind & PARTITION_FLAG_IMPLICITLY_DEPRECATED) != 0 && push!(flags, "implicitly-deprecated")
    #     print(io, " [", join(flags, ","), "]")
    # end
    # print(io, " - ")
    # kind = binding_kind(partition)
    if kind == PARTITION_KIND_BACKDATED_CONST
        print(io, "backdated constant binding to ")
        printstyled(io, "partition restriction", underline = true)
    #   print(io, partition_restriction(partition))
    elseif kind == PARTITION_KIND_CONST
        print(io, "constant binding to ")
        printstyled(io, "partition restriction", underline = true)
    #   print(io, partition_restriction(partition))
    elseif kind == PARTITION_KIND_CONST_IMPORT
        print(io, "constant binding (declared with `import`) to ")
        printstyled(io, "partition restriction", underline = true)
    #   print(io, partition_restriction(partition))
    elseif kind == PARTITION_KIND_UNDEF_CONST
        print(io, "undefined const binding")
    elseif kind == PARTITION_KIND_GUARD
        print(io, "undefined binding - guard entry")
    elseif kind == PARTITION_KIND_FAILED
        print(io, "ambiguous binding - guard entry")
    elseif kind == PARTITION_KIND_DECLARED
        print(io, "weak global binding declared using `global` (implicit type Any)")
    elseif kind == PARTITION_KIND_IMPLICIT_GLOBAL
        print(io, "implicit `using` resolved to global ")
        printstyled(io, "partition restriction globalref", underline = true)
    #   print(io, partition_restriction(partition).globalref)
    elseif kind == PARTITION_KIND_IMPLICIT_CONST
        print(io, "implicit `using` resolved to constant ")
        printstyled(io, "partition restriction", underline = true)
    #   print(io, partition_restriction(partition))
    elseif kind == PARTITION_KIND_EXPLICIT
        print(io, "explicit `using` from ")
        printstyled(io, "partition restriction globalref", underline = true)
    #   print(io, partition_restriction(partition).globalref)
    elseif kind == PARTITION_KIND_IMPORTED
        print(io, "explicit `import` from ")
        printstyled(io, "partition restriction globalref", underline = true)
    #   print(io, partition_restriction(partition).globalref)
    else
        @assert kind == PARTITION_KIND_GLOBAL "unexpected partition kind"
        print(io, "global variable with type ")
        printstyled(io, "partition restriction", underline = true)
    #   print(io, partition_restriction(partition))
    end
end

function show_partition_kind(io::IO, mime::MIME"text/plain", kind::UInt8)
    doc = if kind == PARTITION_KIND_CONST # 0x0
        """
    // Constant: This binding partition is a constant declared using `const _ = ...`
    //  ->restriction holds the constant value"""
    elseif kind == PARTITION_KIND_CONST_IMPORT # 0x1
        """
    // Import Constant: This binding partition is a constant declared using `import A`
    //  ->restriction holds the constant value"""
    elseif kind == PARTITION_KIND_GLOBAL # 0x2
        """
    // Global: This binding partition is a global variable. It was declared either using
    // `global x::T` to implicitly through a syntactic global assignment.
    //  -> restriction holds the type restriction"""
    elseif kind == PARTITION_KIND_IMPLICIT_GLOBAL # 0x3
        """
    // Implicit: The binding was a global, implicitly imported from a `using`'d module.
    //  ->restriction holds the ultimately imported global binding"""
    elseif kind == PARTITION_KIND_IMPLICIT_CONST # 0x4
        """
    // Implicit: The binding was a constant, implicitly imported from a `using`'d module.
    //  ->restriction holds the ultimately imported constant value"""
    elseif kind == PARTITION_KIND_EXPLICIT # 0x5
        """
    // Explicit: The binding was explicitly `using`'d by name
    //  ->restriction holds the imported binding"""
    elseif kind == PARTITION_KIND_IMPORTED # 0x6
        """
    // Imported: The binding was explicitly `import`'d by name
    //  ->restriction holds the imported binding"""
    elseif kind == PARTITION_KIND_FAILED # 0x7
        """
    // Failed: We attempted to import the binding, but the import was ambiguous
    //  ->restriction is NULL."""
    elseif kind == PARTITION_KIND_DECLARED # 0x8
        """
    // Declared: The binding was declared using `global` or similar. This acts in most ways like
    // PARTITION_KIND_GLOBAL with an `Any` restriction, except that it may be redefined to a stronger
    // binding like `const` or an explicit import.
    //  ->restriction is NULL."""
    elseif kind == PARTITION_KIND_GUARD # 0x9
        """
    // Guard: The binding was looked at, but no global or import was resolved at the time
    //  ->restriction is NULL."""
    elseif kind == PARTITION_KIND_UNDEF_CONST # 0xa
        """
    // Undef Constant: This binding partition is a constant declared using `const`, but
    // without a value.
    //  ->restriction is NULL"""
    elseif kind == PARTITION_KIND_BACKDATED_CONST # 0xb
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
    for (idx, kind) in enumerate(PARTITION_KIND_CONST:PARTITION_KIND_BACKDATED_CONST)
        kind_sym = partition_kinds[idx]
        if kind == part.kind
            printstyled(io, "const ", kind_sym, " = ", repr(kind); color = :cyan)
        else
            print(io,       "const ", kind_sym, " = ", repr(kind))
        end
        println(io)
    end
    println(io)
    print_partition_kind(io, part.kind)
    println(io)
    println(io)
    show_partition_kind(io, mime, part.kind)
end

function Base.show(io::IO, mime::MIME"text/plain", part::PartitionFlag)
    for (idx, flag) in enumerate([PARTITION_FLAG_EXPORTED,
                                  PARTITION_FLAG_DEPRECATED,
                                  PARTITION_FLAG_DEPWARN,
                                  PARTITION_FLAG_IMPLICITLY_EXPORTED,
                                  PARTITION_FLAG_IMPLICITLY_DEPRECATED])
        flag_sym = partition_flags[idx]
        if flag == part.flag
            printstyled(io, "const ", flag_sym, " = ", repr(flag); color = :cyan)
        else
            print(io,       "const ", flag_sym, " = ", repr(flag))
        end
        println(io)
    end
end

function Base.show(io::IO, mime::MIME"text/plain", part::PartitionMask)
    for (idx, mask) in enumerate([PARTITION_MASK_KIND,
                                  PARTITION_MASK_FLAG])
        mask_sym = partition_masks[idx]
        if mask == part.mask
            printstyled(io, "const ", mask_sym, " = ", repr(mask); color = :cyan)
        else
            print(io,       "const ", mask_sym, " = ", repr(mask))
        end
        println(io)
    end
end

# module ButterEffects.Docs
