using Test
using LyapunovExponents
using LyapunovExponents: PhaseRelaxer,
    get_integrator, get_tangent_integrator, van_der_pol

@time @testset "Integrator time continuity" begin
    prob = van_der_pol().prob
    relaxer = PhaseRelaxer(get_integrator(prob.phase_prob),
                           prob.t_tran)
    dt = 1.0
    step!(relaxer.integrator, dt, true)
    @test relaxer.integrator.t > prob.phase_prob.tspan[1]

    integrator = get_tangent_integrator(prob, relaxer)
    @test integrator.t == relaxer.integrator.t

    step!(relaxer.integrator, dt, true)
    step!(integrator, dt, true)
    @test integrator.t == relaxer.integrator.t

    @test integrator.u[:, 1] ≈ relaxer.integrator.u rtol = 0.05
end
