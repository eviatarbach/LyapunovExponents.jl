using OnlineStatsBase: OnlineStat, EqualWeight, value
using OnlineStats: VectorOb, smooth!, smooth, bessel
import OnlineStats
import OnlineStatsBase
import Statistics

mutable struct VecMean{W} <: OnlineStat{VectorOb}
    μs::Vector{Float64}
    weight::W
    n::Int
end
VecMean(μs::Vector{Float64}; weight = EqualWeight()) = VecMean(μs, weight, 0)
VecMean(len::Integer) = VecMean(zeros(Float64, len))
OnlineStatsBase._fit!(o::VecMean, x::VectorOb) =
    smooth!(o.μs, x, o.weight(o.n += 1))
Statistics.mean(o::VecMean) = value(o)


mutable struct VecVariance{W} <: OnlineStat{VectorOb}
    σ2s::Vector{Float64}     # biased variance
    μs::Vector{Float64}
    tmp::Vector{Float64}
    weight::W
    n::Int
end
function VecVariance(σ2s::Vector{Float64}, μs::Vector{Float64};
                     weight = EqualWeight())
    @assert size(σ2s) == size(μs)
    VecVariance(σ2s, μs, similar(μs), weight, 0)
end
VecVariance(len::Integer) = VecVariance(zeros(Float64, len),
                                        zeros(Float64, len))

function OnlineStatsBase._fit!(o::VecVariance, x::VectorOb)
    γ = o.weight(o.n += 1)
    o.tmp .= smooth.(o.μs, x, γ)
    o.σ2s .= smooth.(o.σ2s, (x .- o.μs) .* (x .- o.tmp), γ)
    o.tmp, o.μs = o.μs, o.tmp
end

OnlineStatsBase.value(o::VecVariance) =
    o.n < 2 ? fill(NaN, size(o.μs)) : o.σ2s .* bessel(o)
Statistics.var(o::VecVariance) = value(o)
Statistics.std(o::VecVariance) = sqrt.(var(o))
Statistics.mean(o::VecVariance) = o.μs
