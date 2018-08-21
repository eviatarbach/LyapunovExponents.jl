report(x) = report(stdout, x)

function report(io::IO, solver::LESolver; kwargs...)
    report(io, solver.sol; kwargs...)
end

function report(io::IO, sol::LESolution;
                convergence::Bool = true)
    LEs = lyapunov_exponents(sol)

    printstyled(io, "Lyapunov Exponents Solution", color=:blue)
    if sol.converged
        printstyled(io, " (converged)", color=:green)
    else
        printstyled(io, " (NOT converged)", color=:red)
    end
    println(io)

    table = [
        ("#Orth.", sol.num_orth),
        ("#LEs", length(LEs)),
        ("LEs", LEs),
    ]
    for (name, value) in table
        printstyled(io, name, color=:yellow)
        print(io, ": ")
        if value isa String
            print(io, value)
        else
            show(IOContext(io, :limit => true), value)
        end
        println(io)
    end

    if convergence
        report(io, sol.convergence)
    end
end

function report(io::IO, convergence::ConvergenceHistory;
                dim_lyap = min(10, length(convergence.errors)))

    if isempty(convergence.orth)
        print_with_color(:red, io, "NO convergence test is done!", bold=true)
        println(io)
        return
    end

    printstyled(io, "Convergence", color=:blue)
    print(io, " #Orth.=$(convergence.orth[end])")
    print(io, " #Checks=$(length(convergence.orth))")
    if convergence.kinds[end] == UnstableConvError
        print(io, " [unstable]")
    else
        print(io, " [stable]")
    end
    println(io)

    if length(convergence.kinds) > 1
        printstyled(io, "Stability", color=:yellow)
        print(io, ": ")
        for k in convergence.kinds
            if k == UnstableConvError
                print(io, "x")
            else
                print(io, ".")
            end
        end
        println(io)
    end

    print(io, " "^(length("LE$dim_lyap")), "  ",
          "      error", "   ",
          "  threshold")
    if convergence.kinds[end] == UnstableConvError
        print(io,
              "   variance",
              "   tail cov",
              " small tail?")
    end
    println(io)

    for i in 1:dim_lyap
        err = convergence.errors[i][end]
        th = convergence.thresholds[i][end]

        print(io, "LE$i")
        print(io, ": ")
        @printf(io, " %10.5g", err)
        if err < th
            printstyled(io, " < ", color=:green)
        else
            printstyled(io, " > ", color=:red)
        end
        @printf(io, " %10.5g", th)

        detail = convergence.details[i][end]
        if convergence.kinds[end] == UnstableConvError
            @printf(io, " %10.5g", detail.var)
            @printf(io, " %10.5g", detail.tail_cov)
            print(io, "  ")
            if detail.tail_ok
                printstyled(io, "yes", color=:green)
            else
                printstyled(io, "no", color=:red)
            end
        else
            print(io, "  ")
            compact_report(io, detail)
        end

        println(io)
    end
end

compact_report(io, _) = nothing
compact_report(io, ::FixedPointConvDetail) =
    print(io, "\"period\" < 1")
compact_report(io, detail::PeriodicConvDetail) =
    print(io, "\"period\": ", detail.period)
compact_report(io, ::NonNegativeAutoCovConvDetail) =
    print(io, "too short (NN)")
compact_report(io, ::NonPeriodicConvDetail) =
    print(io, "too short (NP)")
