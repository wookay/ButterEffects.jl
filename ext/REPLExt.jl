module REPLExt

using ButterEffects: Docs

function repl_effectbits(io::IO, line::AbstractString)::Bool
    mime = MIME("text/plain")
    if line ∈ Docs.effectbits_letters
        letter = Docs.EffectBitsLetter(String(line))
        Docs.show_effectbits_letter(io, mime, letter)
        return true
    elseif line ∈ Docs.effectbits_suffixes
        suffix = isone(length(line)) ? line[1] : line
        Docs.show_effectbits_suffix(io, mime, suffix)
        return true
    elseif startswith(line, ':')
        setting = Symbol(line[2:end])
        if setting ∈ Docs.effectsettings
            Docs.show_effectsetting(io, mime, setting)
            return true
        end
    else
        setting = Symbol(line)
        if setting ∈ Docs.effectsettings
            Docs.show_effectsetting(io, mime, setting)
            return true
        elseif haskey(Docs.effectbits_const_to_suffix, line)
            suffix = getindex(Docs.effectbits_const_to_suffix, line)
            Docs.show_effectbits_suffix(io, mime, suffix)
            return true
        end
    end
    return false
end # function repl_effectbits

function repl_partition_consts(io::IO, line::AbstractString)::Bool
    local name
    if startswith(line, "Base.PARTITION_")
        name = line[6:end]
    elseif startswith(line, "PARTITION_")
        name = line
    else
        return false
    end
    local n
    try
        n = getglobal(Docs, Symbol(name))
    catch ex # ::UndefVarError
        return false
    end
    mime = MIME("text/plain")
    if startswith(name, "PARTITION_KIND_")
        part = Docs.PartitionKind(n)
        Base.show(io, mime, part)
        return true
    elseif startswith(name, "PARTITION_FLAG_")
        part = Docs.PartitionFlag(n)
        Base.show(io, mime, part)
        return true
    elseif startswith(name, "PARTITION_MASK_")
        part = Docs.PartitionMask(n)
        Base.show(io, mime, part)
        return true
    end
    return false
end # function repl_partition_consts

using HelpMode
function __init__()
    HelpMode.register(repl_effectbits)
    HelpMode.register(repl_partition_consts)
end

end # module REPLExt
