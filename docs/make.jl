using Documenter, LiveDisplay

makedocs(;
    modules=[LiveDisplay],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/tkf/LiveDisplay.jl/blob/{commit}{path}#L{line}",
    sitename="LiveDisplay.jl",
    authors="Takafumi Arakaki",
)

deploydocs(;
    repo="github.com/tkf/LiveDisplay.jl",
)
