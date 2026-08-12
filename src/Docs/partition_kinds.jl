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
    value::UInt8
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

function Base.show(io::IO, mime::MIME"text/plain", kind::PartitionKind)
    for value in Base.PARTITION_KIND_CONST:Base.PARTITION_KIND_BACKDATED_CONST
        kind_sym = partition_kinds[value+1]
        if value == kind.value
            printstyled(io, "const ", kind_sym, " = ", repr(value); color = :cyan)
        else
            print(io,       "const ", kind_sym, " = ", repr(value))
        end
        println(io)
    end
end

# module ButterEffects.Docs
