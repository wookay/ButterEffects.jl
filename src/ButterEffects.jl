module ButterEffects

function __init__()
    Base.require(@__MODULE__, :REPL) # trigger REPLExt
end

include("Docs.jl")

end # module ButterEffects
