module REPLExt

using ButterEffects: Docs
using Markdown

# doc from julia/base/expr.jl    `macro assume_effects(args...)`
#          julia/Compiler/src/effects.jl    `struct Effects`"
function repl_effectsetting(io::IO, setting::Symbol)
    doc = if setting === :consistent
        """
## `:consistent`

The `:consistent` setting asserts that for egal (`===`) inputs:
- The manner of termination (return value, exception, non-termination) will always be the same.
- If the method returns, the results will always be egal.

!!! note
    This in particular implies that the method must not return a freshly allocated
    mutable object. Multiple allocations of mutable objects (even with identical
    contents) are not egal.

!!! note
    The `:consistent`-cy assertion is made with respect to a particular world range `R`.
    More formally, write ``fᵢ`` for the evaluation of ``f`` in world-age ``i``, then this setting requires:
    ```math
    ∀ i ∈ R, j ∈ R, x, y: x ≡ y → fᵢ(x) ≡ fⱼ(y)
    ```

    For `@assume_effects`, the range `R` is `m.primary_world:m.deleted_world` of
    the annotated or containing method.

    For ordinary code instances, `R` is `ci.min_world:ci.max_world`.

    A further implication is that `:consistent` functions may not make their
    return value dependent on the state of the heap or any other global state
    that is not constant over the given world age range.

!!! note
    The `:consistent`-cy includes all legal rewrites performed by the optimizer.
    For example, floating-point fastmath operations are not considered `:consistent`,
    because the optimizer may rewrite them causing the output to not be `:consistent`,
    even for the same world age (e.g. because one ran in the interpreter, while
    the other was optimized).

!!! note
    If `:consistent` functions terminate by throwing an exception, that exception
    itself is not required to meet the egality requirement specified above."""
    elseif setting === :effect_free
        """
## `:effect_free`

The `:effect_free` setting asserts that the method is free of externally semantically
visible side effects. The following is an incomplete list of externally semantically
visible side effects:
- Changing the value of a global variable.
- Mutating the heap (e.g. an array or mutable value), except as noted below
- Changing the method table (e.g. through calls to eval)
- File/Network/etc. I/O
- Task switching

However, the following are explicitly not semantically visible, even if they
may be observable:
- Memory allocations (both mutable and immutable)
- Elapsed time
- Garbage collection
- Heap mutations of objects whose lifetime does not exceed the method (i.e.
  were allocated in the method and do not escape).
- The returned value (which is externally visible, but not a side effect)

The rule of thumb here is that an externally visible side effect is anything
that would affect the execution of the remainder of the program if the function
were not executed.

!!! note
    The `:effect_free` assertion is made both for the method itself and any code
    that is executed by the method. Keep in mind that the assertion must be
    valid for all world ages and limit use of this assertion accordingly."""
    elseif setting === :nothrow
        """
## `:nothrow`

The `:nothrow` setting asserts that this method does not throw an exception
(i.e. will either always return a value or never return).

!!! note
    It is permissible for `:nothrow` annotated methods to make use of exception
    handling internally as long as the exception is not rethrown out of the
    method itself.

!!! note
    If the execution of a method may raise `MethodError`s and similar exceptions, then
    the method is not considered as `:nothrow`.
    However, note that environment-dependent errors like `StackOverflowError` or `InterruptException`
    are not modeled by this effect and thus a method that may result in `StackOverflowError`
    does not necessarily need to be `!:nothrow` (although it should usually be `!:terminates` too)."""
    elseif setting === :terminates_globally
        """
## `:terminates_globally`

The `:terminates_globally` setting asserts that this method will eventually terminate
(either normally or abnormally), i.e. does not loop indefinitely.

!!! note
    This `:terminates_globally` assertion covers any other methods called by the annotated method.

!!! note
    The compiler will consider this a strong indication that the method will
    terminate relatively *quickly* and may (if otherwise legal) call this
    method at compile time. I.e. it is a bad idea to annotate this setting
    on a method that *technically*, but not *practically*, terminates."""
    elseif setting === :terminates_locally
        """
## `:terminates_locally`

The `:terminates_locally` setting is like `:terminates_globally`, except that it only
applies to syntactic control flow *within* the annotated method. It is thus
a much weaker (and thus safer) assertion that allows for the possibility of
non-termination if the method calls some other method that does not terminate.

!!! note
    `:terminates_globally` implies `:terminates_locally`."""
    elseif setting === :notaskstate
        """
## `:notaskstate`

The `:notaskstate` setting asserts that the method does not use or modify the
local task state (task local storage, RNG state, etc.) and may thus be safely
moved between tasks without observable results.

!!! note
    The implementation of exception handling makes use of state stored in the
    task object. However, this state is currently not considered to be within
    the scope of `:notaskstate` and is tracked separately using the `:nothrow`
    effect.

!!! note
    The `:notaskstate` assertion concerns the state of the *currently running task*.
    If a reference to a `Task` object is obtained by some other means that
    does not consider which task is *currently* running, the `:notaskstate`
    effect need not be tainted. This is true, even if said task object happens
    to be `===` to the currently running task.

!!! note
    Access to task state usually also results in the tainting of other effects,
    such as `:effect_free` (if task state is modified) or `:consistent` (if
    task state is used in the computation of the result). In particular,
    code that is not `:notaskstate`, but is `:effect_free` and `:consistent`
    may still be dead-code-eliminated and thus promoted to `:total`."""
    elseif setting === :inaccessiblememonly
        """
## `:inaccessiblememonly`

The `:inaccessiblememonly` setting asserts that the method does not access or modify
externally accessible mutable memory. This means the method can access or modify mutable
memory for newly allocated objects that is not accessible by other methods or top-level
execution before return from the method, but it can not access or modify any mutable
global state or mutable memory pointed to by its arguments.

!!! note
    Below is an incomplete list of examples that invalidate this assumption:
    - a global reference or `getglobal` call to access a mutable global variable
    - a global assignment or `setglobal!` call to perform assignment to a non-constant global variable
    - `setfield!` call that changes a field of a global mutable variable

!!! note
    This `:inaccessiblememonly` assertion covers any other methods called by the annotated method."""
    elseif setting === :noub
        """
## `:noub`

The `:noub` setting asserts that the method will not execute any undefined behavior
(for any input). Note that undefined behavior may technically cause the method to violate
any other effect assertions (such as `:consistent` or `:effect_free`) as well, but we do
not model this, and they assume the absence of undefined behavior."""
    elseif setting === :noub_if_noinbounds
        """
- `noub::UInt8`:
  * `ALWAYS_TRUE`: this method is guaranteed to not execute any undefined behavior (for any input).
  * `ALWAYS_FALSE`: this method may execute undefined behavior.
  * `NOUB_IF_NOINBOUNDS`: this method is guaranteed to not execute any undefined behavior
    under the assumption that its `@boundscheck` code is not elided (which happens when the
    caller does not set nor propagate the `@inbounds` context)
  Note that undefined behavior may technically cause the method to violate any other effect
  assertions (such as `:consistent` or `:effect_free`) as well, but we do not model this,
  and they assume the absence of undefined behavior."""
    elseif setting === :nortcall
        """
## `:nortcall`

The `:nortcall` setting asserts that the method does not call `Core.Compiler.return_type`,
and that any other methods this method might call also do not call `Core.Compiler.return_type`.

!!! note
    To be precise, this assertion can be used when a call to `Core.Compiler.return_type` is
    not made at runtime; that is, when the result of `Core.Compiler.return_type` is known
    exactly at compile time and the call is eliminated by the optimizer. However, since
    whether the result of `Core.Compiler.return_type` is folded at compile time depends
    heavily on the compiler's implementation, it is generally risky to assert this if
    the method in question uses `Core.Compiler.return_type` in any form."""
    elseif setting === :reset_safe
        """
## `:reset_safe`

The `:reset_safe` asserts that it is safe to abandon execution of the annotated
function at any point. For functions so inferred, the compiler may extend the
reset region of a cancellation point through the `:reset_safe` regions. It thus
in particular implies `:effect_free`, but is a stronger assertion. For example,
an `:effect_free` function could in principle take a read-only lock (under appropriate
assumptions on how this is implemented and annotated), but a `:reset_safe` function
may not, because it could be abandoned inside the critical section.

The same also applies to many implicitly inserted intrinsics and thus codegen for
a `:reset_safe` function requires cooperation by the code generator to uphold the
invariant throughout the entire body of the generated code.

As such, annotating a function as `:reset_safe` is currently ignored as an effect
override and will only apply to [`@ccall`](@ref) sites. See the ccall documentation
for further details on this interaction."""
    elseif setting === :foldable
        """
## `:foldable`

This setting is a convenient shortcut for the set of effects that the compiler
requires to be guaranteed to constant fold a call at compile time. It is
currently equivalent to the following `setting`s:
- `:consistent`
- `:effect_free`
- `:terminates_globally`
- `:noub`
- `:nortcall`

!!! note
    This list in particular does not include `:nothrow`. The compiler will still
    attempt constant propagation and note any thrown error at compile time. Note
    however, that by the `:consistent`-cy requirements, any such annotated call
    must consistently throw given the same argument values.

!!! note
    An explicit `@inbounds` annotation inside the function will also disable
    constant folding and not be overridden by `:foldable`."""
    elseif setting === :removable
        """
## `:removable`

This setting is a convenient shortcut for the set of effects that the compiler
requires to be guaranteed to delete a call whose result is unused at compile time.
It is currently equivalent to the following `setting`s:
- `:effect_free`
- `:nothrow`
- `:terminates_globally`"""
    elseif setting === :total
        """
## `:total`

This `setting` is the maximum possible set of effects. It currently implies
the following other `setting`s:
- `:consistent`
- `:effect_free`
- `:nothrow`
- `:terminates_globally`
- `:notaskstate`
- `:inaccessiblememonly`
- `:noub`
- `:nortcall`

!!! warning
    `:total` is a very strong assertion and will likely gain additional semantics
    in future versions of Julia (e.g. if additional effects are added and included
    in the definition of `:total`). As a result, it should be used with care.
    Whenever possible, prefer to use the minimum possible set of specific effect
    assertions required for a particular application. In cases where a large
    number of effect overrides apply to a set of functions, a custom macro is
    recommended over the use of `:total`."""
    end
    mime = MIME"text/plain"()
    if setting === :noub_if_noinbounds
        doc_from = "-- doc from julia/Compiler/src/effects.jl    `struct Effects`"
    else
        doc_from = "-- doc from julia/base/expr.jl    `macro assume_effects(args...)`"
    end
    md = Markdown.MD(Any[Markdown.parse(doc), Markdown.parse(doc_from)])
    Base.show(io, mime, md)
end # function repl_effectsetting

# doc from julia/Compiler/src/effects.jl
function repl_effectbits_suffix(io::IO, suffix::Union{Char, String})
    doc = if suffix == 'c'
        """
- `consistent::UInt8`:
  * `ALWAYS_TRUE`: this method is guaranteed to return or terminate consistently.
  * `ALWAYS_FALSE`: this method might not return or terminate consistently, and there is
    no need for further analysis with respect to this effect property as this conclusion
    will not be refined anyway.
  * `CONSISTENT_IF_NOTRETURNED`: the `:consistent`-cy of this method can later be refined to
    `ALWAYS_TRUE` in a case when the return value of this method never involves newly
    allocated mutable objects.
  * `CONSISTENT_IF_INACCESSIBLEMEMONLY`: the `:consistent`-cy of this method can later be
    refined to `ALWAYS_TRUE` in a case when `:inaccessiblememonly` is proven."""
    elseif suffix == 'e'
        """
- `effect_free::UInt8`:
  * `ALWAYS_TRUE`: this method is free from externally semantically visible side effects.
  * `ALWAYS_FALSE`: this method may not be free from externally semantically visible side effects, and there is
    no need for further analysis with respect to this effect property as this conclusion
    will not be refined anyway.
  * `EFFECT_FREE_IF_INACCESSIBLEMEMONLY`: the `:effect-free`-ness of this method can later be
    refined to `ALWAYS_TRUE` in a case when `:inaccessiblememonly` is proven."""
    elseif suffix == "re"
        """
- `reset_safe::UInt8`
  * The execution of this function may be interrupted and reset to an earlier cancellation
    point at any point in the function. The interpretation is similar to `:effect_free`,
    but has different guarantees.
    N.B.: this bit describes the function's IPO contract only. Machinery the runtime
    inserts implicitly to execute it (allocation, write barriers, runtime library calls)
    is not covered by the contract and may not be safe to abandon - but this analysis
    does not need to model that: it is deferred to codegen and the runtime (see
    `llvm-cancellation-lowering.cpp`)."""
    elseif suffix == 'n'
        """
- `nothrow::Bool`: this method is guaranteed to not throw an exception.
  If the execution of this method may raise `MethodError`s and similar exceptions, then
  the method is not considered as `:nothrow`.
  However, note that environment-dependent errors like `StackOverflowError` or `InterruptException`
  are not modeled by this effect and thus a method that may result in `StackOverflowError`
  does not necessarily need to taint `:nothrow` (although it should usually taint `:terminates` too)."""
    elseif suffix == 't'
        """
- `terminates::Bool`: this method is guaranteed to terminate."""
    elseif suffix == 's'
        """
- `notaskstate::Bool`: this method does not access any state bound to the current
  task and may thus be moved to a different task without changing observable
  behavior. Note that this currently implies `noyield` as well, since
  yielding modifies the state of the current task, though this may be split
  in the future."""
    elseif suffix == 'm'
        """
- `inaccessiblememonly::UInt8`:
  * `ALWAYS_TRUE`: this method does not access or modify externally accessible mutable memory.
    This state corresponds to LLVM's `inaccessiblememonly` function attribute.
  * `ALWAYS_FALSE`: this method may access or modify externally accessible mutable memory.
  * `INACCESSIBLEMEM_OR_ARGMEMONLY`: this method does not access or modify externally accessible mutable memory,
    except that it may access or modify mutable memory pointed to by its call arguments.
    This may later be refined to `ALWAYS_TRUE` in a case when call arguments are known to be immutable.
    This state corresponds to LLVM's `inaccessiblemem_or_argmemonly` function attribute."""
    elseif suffix == 'u'
        """
- `noub::UInt8`:
  * `ALWAYS_TRUE`: this method is guaranteed to not execute any undefined behavior (for any input).
  * `ALWAYS_FALSE`: this method may execute undefined behavior.
  * `NOUB_IF_NOINBOUNDS`: this method is guaranteed to not execute any undefined behavior
    under the assumption that its `@boundscheck` code is not elided (which happens when the
    caller does not set nor propagate the `@inbounds` context)
  Note that undefined behavior may technically cause the method to violate any other effect
  assertions (such as `:consistent` or `:effect_free`) as well, but we do not model this,
  and they assume the absence of undefined behavior."""
    elseif suffix == 'o'
        """
- `nonoverlayed::UInt8`:
  * `ALWAYS_TRUE`: this method is guaranteed to not invoke any methods that are defined in an
    [overlayed method table](@ref OverlayMethodTable).
  * `CONSISTENT_OVERLAY`: this method may invoke overlayed methods, but all such overlayed
    methods are `:consistent` with their non-overlayed original counterparts
    (see [`Base.@assume_effects`](@ref) for the exact definition of `:consistent`-cy).
  * `ALWAYS_FALSE`: this method may invoke overlayed methods."""
    elseif suffix == 'r'
        """
- `nortcall::Bool`: this method does not call `Core.Compiler.return_type`,
  and it is guaranteed that any other methods this method might call also do not call
  `Core.Compiler.return_type`."""
    end
    setting = getindex(Docs.effectbits_suffix_consts, suffix)
    repl_effectsetting(io, setting)
    println(io)
    println(io)
    mime = MIME"text/plain"()
    doc_from = "-- doc from julia/Compiler/src/effects.jl    `struct Effects`"
    md = Markdown.MD(Any[Markdown.parse(doc), Markdown.parse(doc_from)])
    Base.show(io, mime, md)
end # function repl_effectbits_suffix

function repl_effectbits_letter(io::IO, letter::Docs.EffectBitsLetter)
    mime = MIME"text/plain"()
    print(io, "### Effects: ")
    Base.show(io, mime, letter)
    println(io)
    repl_effectbits_suffix(io, letter.suffix)
end # function repl_effectbits_letter

function repl_effectbits(io::Base.TTY, line::AbstractString)::Bool
    if line ∈ Docs.effectbits_letters
        letter = Docs.EffectBitsLetter(String(line))
        repl_effectbits_letter(io, letter)
        return true
    elseif line ∈ Docs.effectbits_suffixes
        suffix = isone(length(line)) ? line[1] : line
        repl_effectbits_suffix(io, suffix)
        return true
    elseif startswith(line, ':')
        setting = Symbol(line[2:end])
        if setting ∈ Docs.effectsettings
            repl_effectsetting(io, setting)
            return true
        end
    else
        setting = Symbol(line)
        if setting ∈ Docs.effectsettings
            repl_effectsetting(io, setting)
            return true
        elseif haskey(Docs.effectbits_const_to_suffix, line)
            suffix = getindex(Docs.effectbits_const_to_suffix, line)
            repl_effectbits_suffix(io, suffix)
            return true
        end
    end
    return false
end

using REPL: REPL
using .REPL: extended_help_on, keywords, isexpr
import .REPL: _helpmode
# from julia/stdlib/REPL/src/docview.jl
# function _helpmode(io::IO, line::AbstractString, mod::Module=Main, internal_accesses::Union{Nothing, Set{Pair{Module,Symbol}}}=nothing)
function _helpmode(io::Base.TTY, line::AbstractString, mod::Module=Main, internal_accesses::Union{Nothing, Set{Pair{Module,Symbol}}}=nothing)
    line = strip(line)
    repl_effectbits(io, line) && return
    ternary_operator_help = (line == "?" || line == "?:")
    if startswith(line, '?') && !ternary_operator_help
        line = line[2:end]
        extended_help_on[] = nothing
        brief = false
    else
        extended_help_on[] = line
        brief = true
    end
    # interpret anything starting with # or #= as asking for help on comments
    if startswith(line, "#")
        if startswith(line, "#=")
            line = "#="
        else
            line = "#"
        end
    end
    x = Meta.parse(line, raise = false, depwarn = false)
    assym = Symbol(line)
    expr =
        if haskey(keywords, assym) || Base.isoperator(assym) || isexpr(x, :error) ||
            isexpr(x, :invalid) || isexpr(x, :incomplete)
            # Docs for keywords must be treated separately since trying to parse a single
            # keyword such as `function` would throw a parse error due to the missing `end`.
            assym
        elseif isexpr(x, (:using, :import))
            (x::Expr).head
        else
            # Retrieving docs for macros requires us to make a distinction between the text
            # `@macroname` and `@macroname()`. These both parse the same, but are used by
            # the docsystem to return different results. The first returns all documentation
            # for `@macroname`, while the second returns *only* the docs for the 0-arg
            # definition if it exists.
            (isexpr(x, :macrocall, 1) && !endswith(line, "()")) ? quot(x) : x
        end
    # the following must call repl(io, expr) via the @repl macro
    # so that the resulting expressions are evaluated in the Base.Docs namespace
    :($REPL.@repl $io $expr $brief $mod $internal_accesses)
end # function _helpmode

end # module REPLExt
