module test_buttereffects_docs

using Test
using ButterEffects: Docs
using .Docs: EffectBitsLetter, effectbitsletter_color
using .Docs: PartitionKind, PartitionFlag, PartitionMask

letter = EffectBitsLetter("?u")
@test effectbitsletter_color(letter) === :yellow

part_kind = PartitionKind(Base.PARTITION_KIND_CONST)
@test part_kind.kind == Docs.PARTITION_KIND_CONST

part_flag = PartitionFlag(Base.PARTITION_FLAG_EXPORTED)
@test part_flag.flag == Docs.PARTITION_FLAG_EXPORTED

@test Docs.PARTITION_FLAG_IMPLICITLY_DEPRECATED == 0x100

part_mask = PartitionMask(Base.PARTITION_MASK_KIND)
@test part_mask.mask == Docs.PARTITION_MASK_KIND

end # module test_buttereffects_docs
