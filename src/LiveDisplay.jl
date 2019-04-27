module LiveDisplay

export @livedocs

using Base.Docs: doc

using MacroTools
using Revise

calldisplay(::Nothing, x) = display(x)
calldisplay(f, x) = f(x)

function livedocs(thing; display=nothing)
    calldisplay(display, doc(thing))
    entr([], [parentmodule(thing)]) do
        calldisplay(display, doc(thing))
    end
end

iskwarglike(expr, name) = isexpr(expr, :(=)) && expr.args[1] == name

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
