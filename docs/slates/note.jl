try; import KaimonSlate; catch; error("This is a Kaimon Slate notebook — running it as plain Julia needs the KaimonSlate runtime in this environment. Add it with `import Pkg; Pkg.add(\"KaimonSlate\")`, or open it in Kaimon Slate."); end; KaimonSlate.standalone!(@__MODULE__; dir=@__DIR__)

#%% md id=intro
@md"""
# ButterEffects
"""

#%% code id=8b8485
using ButterEffects: Docs
using .Docs: EffectBitsLetter
using .Docs: PartitionKind, PartitionFlag, PartitionMask

#%% code id=e91bcd
(c, e, u) = [EffectBitsLetter("+c"), EffectBitsLetter("-e"), EffectBitsLetter("?u")]

#%% code id=d6e0a0
part_kind = PartitionKind(Base.PARTITION_KIND_CONST)
Base.show(stdout, MIME"text/plain"(), part_kind)

#%% code id=460cc4
part_flag = PartitionFlag(Base.PARTITION_FLAG_EXPORTED)
Base.show(stdout, MIME"text/plain"(), part_flag)

#%% code id=2d1c3e
part_mask = PartitionMask(Base.PARTITION_MASK_KIND)
Base.show(stdout, MIME"text/plain"(), part_mask)

# ╔═╡ Slate.config · per-notebook settings (Settings panel)
#   docid = 562ad148-87f0-4fe7-89f1-8eb28b72553a
# ╚═╡
