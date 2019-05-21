module LiveDisplay

export @livedocs, liveinclude

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
function calldisplay(fs::Vector, x)
    for f in fs
        calldisplay(f, x)
    end
end

function _live(f, thing)
    f()
    entr(f, watchables(thing)...)
end

function livedocs(thing; display=nothing)
    _live(thing) do
        calldisplay(display, asdoc(thing))
    end
end

"""
    liveinclude([module,] path; display=nothing)

Include `path` to `module` (default: `Main`) everytime it is updated.

# Keyword Arguments
- `display`: A callable that accepts one argument or a `Vector` of
  such callables.  The object returned from `include(path)` is passed
 to it/them.
"""
liveinclude(path; kwargs...) = liveinclude(Main, path; kwargs...)
function liveinclude(namespace, path; display=nothing)
    _live(path) do
        calldisplay(display, Base.include(namespace, path))
    end
end

iskwarglike(expr, name) = isexpr(expr, :(=)) && expr.args[1] == name

"""
    @livedocs THING [display=FUNCTION]

Display THING using FUNCTION (default to `display`) where THING can be:

* Julia object with docstring.
* Path to markdown file.

FUNCTION must be a callable that accepts an object returned by
`Base.Docs.doc` (typically a `Markdown.MD`) or a `Vector` of such
callables.

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
