using Test
using FSimPlots
using FlightSims
using FSimZoo
using Plots


function vtol_itself()
    vtol = LiftCruiseVTOL2D()
    p = [0.0, -0.0]  # x, z = N, -U
    θ = deg2rad(30)  # pitch
    x0 = State(vtol)(p, θ)
    fig = plot(;
               xlim=(-3, 3),
               ylim=(-3, 3),
               zlim=(-3, 3),
               # camera=(90, 0),
               )
    plot!(fig, vtol, x0)
    savefig(fig, "figures/VTOL.png")
    display(fig)
end


@testset "vtol" begin
    vtol_itself()
end
