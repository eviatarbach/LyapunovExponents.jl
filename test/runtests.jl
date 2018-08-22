module LyapunovExponentsTests

printstyled(let
    message = " Warnings below (if any) are fine. "
    margin = (displaysize(stdout)[2] - length(message)) ÷ 2
    ("=" ^ margin) * message * ("=" ^ margin)
end, color=:blue)
println()
flush(stdout)
import Plots
import ForwardDiff
import DifferentialEquations
import OnlineStats
flush(stdout)
flush(stderr)
printstyled("=" ^ displaysize(stdout)[2], color=:blue)
println()

using LyapunovExponents
using Test

@time begin
include("test_testtools.jl")
include("test_utils.jl")
include("test_online_stats.jl")
include("test_smoke.jl")
include("test_ui.jl")
include("test_examples.jl")
include("test_integrators.jl")
include("test_terminators.jl")
include("test_clv.jl")
include("test_null_clv.jl")
end

end
