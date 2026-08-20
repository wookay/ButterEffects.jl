# module ButterEffects.Docs

using Core: Compiler as CC
using .CC: PhiNode, PiNode, PhiCNode, UpsilonNode

# from julia/doc/src/devdocs/ssair.md
#      julia/src/jltypes.c

"""
φ

The SSA IR representation has four categories of IR nodes: Phi, Pi, PhiC, and Upsilon nodes (the latter two are only used for exception handling).

### Phi nodes and Pi nodes

Phi nodes are part of generic SSA abstraction (see the link above if you're not familiar with
the concept). In the Julia IR, these nodes are represented as:
```julia
struct PhiNode
    edges::Vector{Int32}
    values::Vector{Any}
end
```
where we ensure that both vectors always have the same length. In the canonical representation (the one
handled by codegen and the interpreter), the edge values indicate come-from statement numbers (i.e.
if edge has an entry of `15`, there must be a `goto`, `gotoifnot` or implicit fall through from
statement `15` that targets this phi node). Values are either SSA values or constants. It is also
possible for a value to be unassigned if the variable was not defined on this path. However, undefinedness
checks get explicitly inserted and represented as booleans after middle end optimizations, so code generators
may assume that any use of a Phi node will have an assigned value in the corresponding slot. It is also legal
for the mapping to be incomplete, i.e. for a Phi node to have missing incoming edges. In that case, it must
be dynamically guaranteed that the corresponding value will not be used.

Note that SSA uses semantically occur after the terminator of the corresponding predecessor ("on the edge").
Consequently, if multiple Phi nodes appear at the start of a basic block, they are run simultaneously.
This means that in the following IR snippet, if we came from block `23`, `%46` will take the value associated to
`%45` _before_ we entered this block.

```
%45 = φ (#18 => %23, #23 => %50)
%46 = φ (#18 => 1.0, #23 => %45)
```

- doc from julia/doc/src/devdocs/ssair.md
"""
PhiNode

"""
```julia
struct PiNode <: Any
  val::Any
  typ::Any
end
```

PiNodes encode statically proven information that may be implicitly assumed in basic blocks dominated by a given
pi node. They are conceptually equivalent to the technique introduced in the paper
[ABCD: Eliminating Array Bounds Checks on Demand](https://dl.acm.org/citation.cfm?id=358438.349342) or the predicate info nodes in LLVM. To see how they work, consider,
e.g.

```julia
%x::Union{Int, Float64} # %x is some Union{Int, Float64} typed ssa value
if isa(x, Int)
    # use x
else
    # use x
end
```

We can perform predicate insertion and turn this into:

```julia
%x::Union{Int, Float64} # %x is some Union{Int, Float64} typed ssa value
if isa(x, Int)
    %x_int = PiNode(x, Int)
    # use %x_int
else
    %x_float = PiNode(x, Float64)
    # use %x_float
end
```

Pi nodes are generally ignored in the interpreter, since they don't have any effect on the values,
but they may sometimes lead to code generation in the compiler (e.g. to change from an implicitly
union split representation to a plain unboxed representation). The main usefulness of PiNodes stems
from the fact that path conditions of the values can be accumulated simply by def-use chain walking
that is generally done for most optimizations that care about these conditions anyway.

- doc from julia/doc/src/devdocs/ssair.md
"""
PiNode

const _PhiC_Upsilon_doc = raw"""
### PhiC nodes and Upsilon nodes

Exception handling complicates the SSA story moderately, because exception handling
introduces additional control flow edges into the IR across which values must be tracked.
One approach to do so, which is followed by LLVM, is to make calls which may throw exceptions
into basic block terminators and add an explicit control flow edge to the catch handler:

```
invoke @function_that_may_throw() to label %regular unwind to %catch

regular:
# Control flow continues here

catch:
# Exceptions go here
```

However, this is problematic in a language like Julia, where at the start of the optimization
pipeline, we do not know which calls throw. We would have to conservatively assume that every
call (which in Julia is every statement) throws. This would have several negative effects.
On the one hand, it would essentially reduce the scope of every basic block to a single call,
defeating the purpose of having operations be performed at the basic block level. On the other
hand, every catch basic block would have `n*m` phi node arguments (`n`, the number of statements
in the critical region, `m` the number of live values through the catch block).

To work around this, we use a combination of `Upsilon` and `PhiC` nodes (the C standing for `catch`,
written `φᶜ` in the IR pretty printer, because unicode subscript c is not available). There are several ways to think of these nodes, but
perhaps the easiest is to think of each `PhiC` as a load from a unique store-many, read-once slot,
with `Upsilon` being the corresponding store operation. The `PhiC` has an operand list of all the
upsilon nodes that store to its implicit slot. The `Upsilon` nodes however, do not record which `PhiC`
node they store to. This is done for more natural integration with the rest of the SSA IR. E.g.
if there are no more uses of a `PhiC` node, it is safe to delete it, and the same is true of an
`Upsilon` node. In most IR passes, `PhiC` nodes can be treated like `Phi` nodes. One can follow
use-def chains through them, and they can be lifted to new `PhiC` nodes and new `Upsilon` nodes (in the
same places as the original `Upsilon` nodes). The result of this scheme is that the number of
`Upsilon` nodes (and `PhiC` arguments) is proportional to the number of assigned values to a particular
variable (before SSA conversion), rather than the number of statements in the critical region.

To see this scheme in action, consider the function

```julia
@noinline opaque() = invokelatest(identity, nothing) # Something opaque
function foo()
    local y
    x = 1
    try
        y = 2
        opaque()
        y = 3
        error()
    catch
    end
    (x, y)
end
```

The corresponding IR (with irrelevant types stripped) is:

```
1 ─       nothing::Nothing
2 ─ %2  = $(Expr(:enter, #4))
3 ─ %3  = ϒ (false)
│   %4  = ϒ (#undef)
│   %5  = ϒ (1)
│   %6  = ϒ (true)
│   %7  = ϒ (2)
│         invoke Main.opaque()::Any
│   %9  = ϒ (true)
│   %10 = ϒ (3)
│         invoke Main.error()::Union{}
└──       $(Expr(:unreachable))::Union{}
4 ┄ %13 = φᶜ (%3, %6, %9)::Bool
│   %14 = φᶜ (%4, %7, %10)::Core.Compiler.MaybeUndef(Int64)
│   %15 = φᶜ (%5)::Core.Const(1)
└──       $(Expr(:leave, Core.SSAValue(2)))
5 ─       $(Expr(:pop_exception, :(%2)))::Any
│         $(Expr(:throw_undef_if_not, :y, :(%13)))::Any
│   %19 = Core.tuple(%15, %14)
└──       return %19
```

Note in particular that every value live into the critical region gets
an upsilon node at the top of the critical region. This is because
catch blocks are considered to have an invisible control flow edge
from outside the function. As a result, no SSA value dominates the
catch blocks, and all incoming values have to come through a `φᶜ` node.

- doc from julia/doc/src/devdocs/ssair.md
"""

"""
φᶜ

```julia
struct PhiCNode <: Any
  values::Vector{Any}
end
```

$_PhiC_Upsilon_doc
"""
PhiCNode

"""
ϒ

```julia
struct UpsilonNode <: Any
  val::Any
end
```

$_PhiC_Upsilon_doc
"""
UpsilonNode

# module ButterEffects.Docs
