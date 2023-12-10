using FSimPlots
using Plots
using FSimZoo
using FlightSims
using DiffEqCallbacks


function generate_gif()
    multicopter = LeeHexacopter()
    (; m, g) = multicopter
    x0 = State(multicopter)()
    anim = Animation()
    function affect!(integrator)
        state = copy(integrator.u)
        fig = plot(multicopter, state;
                   xlim=(-1, 1), ylim=(-1, 1), zlim=(-1, 20),
                   # background_color=:transparent,  # no transparent for gif
                   # camera=(45, 45),
                  )
        frame(anim)
    end
    Δt = 0.1
    tf = 10.0
    cb = PeriodicCallback(affect!, Δt)
    function Dynamics!(multicopter::Multicopter)
        FSimZoo.__Dynamics!(multicopter)
    end
    simulator = Simulator(x0,
                          apply_inputs(Dynamics!(multicopter);
                                       f=(state, p, t) -> m*g + (0.5*tf-t),
                                       M=zeros(3),
                                      );
                          tf=tf,
                         )
    df = solve(simulator; callback=cb)
    gif(anim, "figures/anim.gif", fps=60)
    nothing
end


@testset "hexacopter" begin
    generate_gif()
end
