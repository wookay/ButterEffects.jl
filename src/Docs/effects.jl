# module ButterEffects.Docs

# from julia/Compiler/src/effects.jl
#      julia/Compiler/src/ssair/show.jl

const effectsettings = [
    :consistent,
    :effect_free,
    :nothrow,
    :terminates_globally,
    :terminates_locally,
    :notaskstate,
    :inaccessiblememonly,
    :noub,
    :noub_if_noinbounds,
    :nortcall,
    :reset_safe,
    :foldable,
    :removable,
    :total
]

const effectbits_const_to_suffix = Dict{String, Union{Char, String}}(
    "CONSISTENT_IF_NOTRETURNED" => 'c',
    "CONSISTENT_IF_INACCESSIBLEMEMONLY" => 'c',
    "EFFECT_FREE_IF_INACCESSIBLEMEMONLY" => 'e',
    "RESET_SAFE_IF_INACCESSIBLEMEMONLY" => "re",
    "INACCESSIBLEMEM_OR_ARGMEMONLY" => 'm',
    "NOUB_IF_NOINBOUNDS" => 'u',
    "CONSISTENT_OVERLAY" => 'o',
)

const effectbits_letters = [
    "+c",  "-c",  "?c",
    "+e",  "-e",  "?e",
    "+re", "-re", "?re",
    "+n",  "-n",
    "+t",  "-t",
    "+s",  "-s",
    "+m",  "-m",  "?m",
    "+u",  "-u",  "?u",
    "+o",  "-o",  "?o",
    "+r",  "-r",
]

const effectbits_suffixes = [
    "c", "e", "re", "n", "t", "s", "m", "u", "o", "r"
]

const effectbits_suffix_consts = Dict{Union{Char, String}, Symbol}(
    'c' => :consistent,
    'e' => :effect_free,
    "re" => :reset_safe,
    'n' => :nothrow,
    't' => :terminates,
    's' => :notaskstate,
    'm' => :inaccessiblememonly,
    'u' => :noub,
    'o' => :nonoverlayed,
    'r' => :nortcall
)

struct EffectBitsLetter
    prefix::Char
    suffix::Union{Char, String}
    function EffectBitsLetter(prefix::Char, suffix::Union{Char, String})
         new(prefix, suffix)
    end
    function EffectBitsLetter(letter::String)
         prefix = letter[1]
         suffix = letter[2:end]
         if isone(length(suffix))
             new(prefix, suffix[1])
         else
             new(prefix, suffix)
         end
    end
end

function effectbitsletter_color(letter::EffectBitsLetter)
    if letter.prefix == '+'
        return :green
    elseif letter.prefix == '-'
        return :red
    elseif letter.prefix == '?'
        return :yellow
    else
        error("unsupported effectbits type given")
    end
end

function Base.show(io::IO, mime::MIME"text/plain", letter::EffectBitsLetter)
    color = effectbitsletter_color(letter)
    printstyled(io, string(letter.prefix, letter.suffix); color)
end

# module ButterEffects.Docs
