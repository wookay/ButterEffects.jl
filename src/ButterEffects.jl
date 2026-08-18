module ButterEffects

function __init__()
    Base.require(@__MODULE__, :REPL) # trigger REPLExt
end

include("Docs.jl")

export      is_defined_const_binding,
            is_some_const_binding,
            is_some_imported,
            is_some_implicit,
            is_some_explicit_imported,
            is_some_binding_imported,
            is_some_guard

using Base: is_defined_const_binding,
            is_some_const_binding,
            is_some_imported,
            is_some_implicit,
            is_some_explicit_imported,
            is_some_binding_imported,
            is_some_guard

end # module ButterEffects
