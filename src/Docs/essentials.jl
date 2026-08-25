# module ButterEffects.Docs

# docs @_?_meta macros in julia/base/essentials.jl

# from julia/base/expr.jl
#      julia/base/essentials.jl

function get_doc_for_effect_setting(syms::Symbol...):String
    join(map(contents_for_effectsetting, syms), "\n")
end

"""
* can be used in place of `@assume_effects :total` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:total))
"""
:(@Base._total_meta)

"""
* can be used in place of `@assume_effects :foldable` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:foldable))
"""
:(@Base._foldable_meta)

"""
* can be used in place of `@assume_effects :terminates_locally` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:terminates_locally))
"""
:(@Base._terminates_locally_meta)

"""
* can be used in place of `@assume_effects :terminates_globally` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:terminates_globally))
"""
:(@Base._terminates_globally_meta)

"""
* can be used in place of `@assume_effects :terminates_globally :notaskstate` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:terminates_globally, :notaskstate))
"""
:(@Base._terminates_globally_notaskstate_meta)

"""
* can be used in place of `@assume_effects :terminates_globally :noub` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:terminates_globally, :noub))
"""
:(@Base._terminates_globally_noub_meta)

"""
* can be used in place of `@assume_effects :effect_free :terminates_locally` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:effect_free, :terminates_locally))
"""
:(@Base._effect_free_terminates_locally_meta)

"""
* can be used in place of `@assume_effects :nothrow :noub` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:nothrow, :noub))
"""
:(@Base._nothrow_noub_meta)

"""
* can be used in place of `@assume_effects :nothrow` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:nothrow))
"""
:(@Base._nothrow_meta)

"""
* can be used in place of `@assume_effects :noub` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:noub))
"""
:(@Base._noub_meta)

"""
* can be used in place of `@assume_effects :notaskstate` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:notaskstate))
"""
:(@Base._notaskstate_meta)

"""
* can be used in place of `@assume_effects :noub_if_noinbounds` (supposed to be used for bootstrapping)
$(get_doc_for_effect_setting(:noub_if_noinbounds))
"""
:(@Base._noub_if_noinbounds_meta)

const _doc_propagate_inbounds_meta = join(Base.Docs._doc(Base.Docs.Binding(Base, Symbol("@propagate_inbounds"))).text)
"""
* another version of inlining that propagates an inbounds context
$_doc_propagate_inbounds_meta
"""
:(@Base._propagate_inbounds_meta)

const _doc_nospecializeinfer_meta  = join(Base.Docs._doc(Base.Docs.Binding(Base, Symbol("@nospecializeinfer"))).text)
"""
$_doc_nospecializeinfer_meta
"""
:(@Base._nospecializeinfer_meta)

# module ButterEffects.Docs
