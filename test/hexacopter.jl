using Test
using FSimPlots
using FSimZoo
using FlightSims
using Plots


function hexacopter_alone()
    multicopter = LeeHexacopter()
    x0 = State(multicopter)()
    traj_des_func = (t) -> [-0.75, -0.75, 0.75]*(1-t)^3 + (-0.5)*ones(3)*(1-t)^2*t + (-1)*ones(3)*(1-t)*t^2
    η = 0.2
    x0.p = traj_des_func(η)
    # x0.q = dcm2quat(ReferenceFrameRotations.angle_to_dcm(0, deg2rad(-0), deg2rad(15), :ZYX)')
    x0.q = euler2quat([deg2rad(15), deg2rad(-0), 0])
    fig = plot()
    plot!(fig,
          multicopter, x0;
          ticks=nothing, border=:none,
          background_color=:transparent,
          xlabel="", ylabel="", zlabel="",
          xlim=(-1.0, 0.1), ylim=(-1.0, 0.1), zlim=(-1.0, 0.1),
          # camera=(45, 45),
          dpi=300,
         )
    savefig(fig, "figures/hexacopter_alone.png")
    display(fig)
end


function topview()
    multicopter = LeeHexacopter()
    x0 = State(multicopter)()
    fig = plot(multicopter, x0;
               ticks=nothing, border=:none,
               background_color=:transparent,
               xlabel="", ylabel="", zlabel="",
               camera=(0, 90),
               dpi=300,
              )
    savefig(fig, "figures/topview.png")
end


@testset "hexacopter" begin
    hexacopter_alone()
    topview()
end
