using FSimPlots
using FSimZoo
using FlightSims
const FS = FlightSims
using Plots  # you should use `Plots` as well

gr()
# ENV["GKSwstype"] = "nul"
using LinearAlgebra
using DiffEqCallbacks
using Transducers
using UnPack
using ReferenceFrameRotations


function gen_gif()
    multicopter = LeeHexacopter()
    @unpack m, g = multicopter
    x0 = State(multicopter)()
    anim = Animation()
    function affect!(integrator)
        state = copy(integrator.u)
        fig = plot(multicopter, state;
                   xlim=(-1, 1), ylim=(-1, 1), zlim=(-1, 20),
                   camera=(45, 45),
                  )
        frame(anim)
    end
    Δt = 0.1
    tf = 10.0
    cb = PeriodicCallback(affect!, Δt)
    function Dynamics!(multicopter::Multicopter)
        FSimZoo.__Dynamics!(multicopter)
    end
    prob, df = sim(x0,
                   apply_inputs(Dynamics!(multicopter);
                                f=(state, p, t) -> m*g + (0.5*tf-t),
                                M=zeros(3),
                               );
                   tf=tf,
                   callback=cb,
                  )
    gif(anim, "figures/anim.gif", fps=60)
    nothing
end

function topview()
    multicopter = LeeHexacopter()
    x0 = State(multicopter)()
    fig = plot(multicopter, x0;
               ticks=nothing, border=:none,
               # background_color=:transparent,
               xlabel="", ylabel="", zlabel="",
               camera=(0, 90),
               dpi=300,
              )
    savefig(fig, "figures/topview.png")
end

function model_description()
    multicopter = LeeHexacopter()
    x0 = State(multicopter)()
    length_param = 0.5
    x0.p += [length_param, length_param, -length_param]  # NED
    ϕ, θ, ψ = 0, deg2rad(30), 0
    x0.R = ReferenceFrameRotations.angle_to_dcm(ψ, θ, ϕ, :ZYX)
    @unpack p, R = x0
    p_enu = ned2enu(p)
    # plot
    fig = plot3d(;)
    opacity_axes = 0.5
    opacity_pos_vec = 0.5
    # inertial frame
    origin_length = -length_param
    axis_length = length_param
    origin_pos = origin_length*ones(3)
    Naxis_pos = origin_pos + axis_length*ned2enu([1, 0, 0])
    Eaxis_pos = origin_pos + axis_length*ned2enu([0, 1, 0])
    Daxis_pos = origin_pos + axis_length*ned2enu([0, 0, 1])
    Naxis_1 = LinRange(origin_pos[1], Naxis_pos[1], 2)
    Naxis_2 = LinRange(origin_pos[2], Naxis_pos[2], 2)
    Naxis_3 = LinRange(origin_pos[3], Naxis_pos[3], 2)
    Eaxis_1 = LinRange(origin_pos[1], Eaxis_pos[1], 2)
    Eaxis_2 = LinRange(origin_pos[2], Eaxis_pos[2], 2)
    Eaxis_3 = LinRange(origin_pos[3], Eaxis_pos[3], 2)
    Daxis_1 = LinRange(origin_pos[1], Daxis_pos[1], 2)
    Daxis_2 = LinRange(origin_pos[2], Daxis_pos[2], 2)
    Daxis_3 = LinRange(origin_pos[3], Daxis_pos[3], 2)
    plot!(fig,
          Naxis_1, Naxis_2, Naxis_3;
          color=:red,
          label=nothing,
          opacity=opacity_axes,
         )
    plot!(fig,
          Eaxis_1, Eaxis_2, Eaxis_3;
          color=:green,
          label=nothing,
          opacity=opacity_axes,
         )
    plot!(fig,
          Daxis_1, Daxis_2, Daxis_3;
          color=:blue,
          label=nothing,
          opacity=opacity_axes,
         )
    # body frame
    Xaxis_pos = p_enu + ned2enu(R'*enu2ned(Naxis_pos-origin_pos))
    Yaxis_pos = p_enu + ned2enu(R'*enu2ned(Eaxis_pos-origin_pos))
    Zaxis_pos = p_enu + ned2enu(R'*enu2ned(Daxis_pos-origin_pos))
    Xaxis_1 = LinRange(p_enu[1], Xaxis_pos[1], 2)
    Xaxis_2 = LinRange(p_enu[2], Xaxis_pos[2], 2)
    Xaxis_3 = LinRange(p_enu[3], Xaxis_pos[3], 2)
    Yaxis_1 = LinRange(p_enu[1], Yaxis_pos[1], 2)
    Yaxis_2 = LinRange(p_enu[2], Yaxis_pos[2], 2)
    Yaxis_3 = LinRange(p_enu[3], Yaxis_pos[3], 2)
    Zaxis_1 = LinRange(p_enu[1], Zaxis_pos[1], 2)
    Zaxis_2 = LinRange(p_enu[2], Zaxis_pos[2], 2)
    Zaxis_3 = LinRange(p_enu[3], Zaxis_pos[3], 2)
    plot!(fig,
          Xaxis_1, Xaxis_2, Xaxis_3;
          color=:red,
          label=nothing,
          opacity=opacity_axes,
         )
    plot!(fig,
          Yaxis_1, Yaxis_2, Yaxis_3;
          color=:green,
          label=nothing,
          opacity=opacity_axes,
         )
    plot!(fig,
          Zaxis_1, Zaxis_2, Zaxis_3;
          color=:blue,
          label=nothing,
          opacity=opacity_axes,
         )
    # position vector
    plot!(fig,
          [origin_pos[1], p_enu[1]], [origin_pos[2], p_enu[2]], [origin_pos[3], p_enu[3]];
          color=:black,
          label=nothing,
          opacity=opacity_pos_vec,
         )
    # BE CAREFUL; figures w.r.t. ENU
    plot!(fig, multicopter, x0;
          ticks=nothing, border=:none,
          # background_color=:transparent,
          xlabel="", ylabel="", zlabel="",
          xlim=(-2*length_param, 2*length_param),
          ylim=(-2*length_param, 2*length_param),
          zlim=(-2*length_param, 2*length_param),
          camera=(45, 45),
          # dpi=300,
         )
    savefig(fig, "figures/hexacopter_description.png")
    display(fig)
end

function prob_description()
    multicopter = LeeHexacopter()
    x0 = State(multicopter)()
    Δt = 0.1
    traj_des_func = (t) -> [-0.75, -0.75, 0.75]*(1-t)^3 + (-0.5)*ones(3)*(1-t)^2*t + (-1)*ones(3)*(1-t)*t^2
    η = 0.2
    x0.p = traj_des_func(η)
    x0.R = ReferenceFrameRotations.angle_to_dcm(0, deg2rad(-10), deg2rad(30), :ZYX)
    fig = plot(;
               legend=:bottomright,
               legendfont=font(14),
              )
    plot!(fig,
          multicopter, x0;
          ticks=nothing, border=:none,
          # background_color=:transparent,
          xlabel="", ylabel="", zlabel="",
          xlim=(-1.0, 0.1), ylim=(-1.0, 0.1), zlim=(-1.0, 0.1),
          dpi=300,
         )
    plot!(fig,
          [0], [0], [0];
          st=:scatter, color=:red,
          markersize=6,
          label="set point",
         )
    traj_des_enu_before = 0:Δt:η |> Map(t -> ned2enu(traj_des_func(t))) |> collect
    traj_des_e_before = traj_des_enu_before |> Map(enu -> enu[1]) |> collect
    traj_des_n_before = traj_des_enu_before |> Map(enu -> enu[2]) |> collect
    traj_des_u_before = traj_des_enu_before |> Map(enu -> enu[3]) |> collect
    traj_des_enu_after = η:Δt:1.0 |> Map(t -> ned2enu(traj_des_func(t))) |> collect
    traj_des_e_after = traj_des_enu_after |> Map(enu -> enu[1]) |> collect
    traj_des_n_after = traj_des_enu_after |> Map(enu -> enu[2]) |> collect
    traj_des_u_after = traj_des_enu_after |> Map(enu -> enu[3]) |> collect
    plot!(fig,
          traj_des_e_before, traj_des_n_before, traj_des_u_before;
          color=:black,
          label="trajectory",
         )
    plot!(fig,
          traj_des_e_after, traj_des_n_after, traj_des_u_after;
          color=:black,
          ls=:dash,
          label="",
         )
    savefig(fig, "figures/prob_description.png")
    display(fig)
end

gen_gif()
topview()
model_description()
prob_description()
