module LiveDisplay

export @livedocs

using Base.Docs: doc
using Markdown
using MacroTools
using Revise

watchables(thing) = ([], [parentmodule(thing)])
asdoc(thing) = doc(thing)

watchables(path::AbstractString) = ([path], [])
asdoc(path::AbstractString) = Markdown.parse_file(path)

calldisplay(::Nothing, x) = display(x)
calldisplay(f, x) = f(x)

function livedocs(thing; display=nothing)
    calldisplay(display, asdoc(thing))
    entr(watchables(thing)...) do
        calldisplay(display, asdoc(thing))
    end
end

iskwarglike(expr, name) = isexpr(expr, :(=)) && expr.args[1] == name

"""
    @livedocs THING [display=FUNCTION]

Display THING using FUNCTION (default to `display`) where THING can be:

* Julia object with docstring.
* Path to markdown file.

# Examples
```julia-repl
julia> @livedocs f

julia> using ElectronDisplay

julia> @livedocs "README.md" display=electrondisplay
```
"""
macro livedocs(expr, option=nothing)
    if isexpr(expr, :macrocall)
        args = filter(x -> x isa Expr, expr.args[2:end])
        expr = expr.args[1]
        if option === nothing && !isempty(args)
            if !(length(args) == 1 && iskwarglike(args[1], :display))
                error("""
                `@livedocs` with an option must be of the following form:
                    @livedocs $expr display=...
                """)
            end
            option, = args
        end
    end
    if option === nothing
        display = nothing
    else
        if !iskwarglike(option, :display)
            error("Invalid option: $option")
        end
        display = option.args[2]
    end
    return esc(:($livedocs($expr; display=$display)))
end

end # module
