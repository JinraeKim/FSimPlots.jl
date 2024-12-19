using Test
using FSimPlots
using FlightSims
using FSimZoo
using Plots


function vtol_itself()
    vtol = LiftCruiseVTOL2D()
    p = [0.0, -0.0]  # x, z = N, -U
    θ = deg2rad(30)  # pitch
    X0 = State(vtol)(p, θ)
    fig = plot(;
               xlim=(-30, 30),
               ylim=(-30, 30),
               zlim=(-30, 30),
               # camera=(90, 0),
               )
    plot!(fig, vtol, X0; length_scale=10)
    savefig(fig, "figures/VTOL.png")
    display(fig)
end


@testset "vtol" begin
    vtol_itself()
end
