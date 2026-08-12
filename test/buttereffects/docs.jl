module test_buttereffects_docs

using Test
using ButterEffects: Docs
using .Docs: EffectBitsLetter, effectbitsletter_color
using .Docs: PartitionKind

letter = EffectBitsLetter("?u")
@test effectbitsletter_color(letter) === :yellow

kind = PartitionKind(Base.PARTITION_KIND_CONST)
@test kind.value == Base.PARTITION_KIND_CONST

end # module test_buttereffects_docs
