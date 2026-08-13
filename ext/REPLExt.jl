module REPLExt

using ButterEffects: Docs

function repl_effectbits(io::Base.TTY, line::AbstractString)::Bool
     mime = MIME"text/plain"()
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

function repl_partition_kinds(io::Base.TTY, line::AbstractString)::Bool
    local kind
    if startswith(line, "Base.PARTITION_KIND_")
        try
            kind = eval(Meta.parse(line))
        catch ex # ::UndefVarError
            return false
        end
    elseif startswith(line, "PARTITION_KIND_")
        try
            kind = eval(Meta.parse(string("Base.", line)))
        catch ex # ::UndefVarError
            return false
        end
    else
        return false
    end
    part = Docs.PartitionKind(kind)
    mime = MIME"text/plain"()
    Base.show(io, mime, part)
    return true
end # function repl_partition_kinds

using HelpMode
function __init__()
    HelpMode.register(repl_effectbits)
    HelpMode.register(repl_partition_kinds)
end

end # module REPLExt
