using Documenter
using ButterEffects

makedocs(
    build = joinpath(@__DIR__, "local" in ARGS ? "build_local" : "build"),
    modules = [ButterEffects],
    checkdocs_ignored_modules = Module[],
    clean = false,
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        assets = ["assets/custom.css"],
        size_threshold = 1_000_000,
    ),
    sitename = "ButterEffects.jl 🧈",
    authors = "WooKyoung Noh",
    pages = Any[
        "Home" => "index.md",
        "Effects" => "effects.md",
        "Binding Partition" => "binding_partition.md",
        "Essentials" => "essentials.md",
        "Runtime Internals" => "runtime_internals.md",
        "SSA IR" => "ssair.md",
    ],
)
