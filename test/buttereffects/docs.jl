module test_buttereffects_docs

using Test
using ButterEffects: Docs
using .Docs: EffectBitsLetter, effectbitsletter_color

letter = EffectBitsLetter("?u")
@test effectbitsletter_color(letter) === :yellow

end # module test_buttereffects_docs
