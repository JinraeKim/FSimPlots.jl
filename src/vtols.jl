function Plots.plot!(fig::Plots.Plot, vtol::LiftCruiseVTOL2D, state;
        xlabel="E (m)", ylabel="N (m)", zlabel="U (m)",
        kwargs...)
    p_nd = state.p
    θ = state.θ

    p_ned = [p_nd[1], 0.0, p_nd[2]]
    R_ned2enu = [
        0 1 0;
        1 0 0;
        0 0 -1
    ]
    R = euler2dcm([0.0, θ, 0.0])  # roll, pitch, yaw
    body_x = R*[1, 0, 0]  # B to I
    body_y = R*[0, 1, 0]  # B to I
    body_z = R*[0, 0, 1]  # B to I

    # plotting
    dx = 0.8
    dy_short = 0.7
    dy_long = 1.6
    # wing
    p_wing = p_ned
    plot!(fig,
          ellipse_shape(ned2enu(p_wing), 0.3, 2, ned2enu(body_x), ned2enu(body_y));
          st=:line,
          c=:gray, lw=3.5, label=nothing, opacity=1.00,
         )
    # fuselage
    p_fl = p_ned + R*[-0.7*dx, 0, 0]
    for ϕ in LinRange(0, 2*pi, 8)
        plot!(fig,
              ellipse_shape(ned2enu(p_fl), 2, 0.2, ned2enu(R*euler2dcm([ϕ, 0, 0])*[1, 0, 0]), ned2enu(R*euler2dcm([ϕ, 0, 0])*[0, 1, 0]));
              st=:line,
              c=:gray, lw=3.5, label=nothing, opacity=1.00,
              )
    end
    # vertical prop
    p_vps = [
        p_ned + R*[+1.0*dx, +dy_long, 0],
        p_ned + R*[+1.0*dx, +dy_short, 0],
        p_ned + R*[+1.0*dx, -dy_short, 0],
        p_ned + R*[+1.0*dx, -dy_long, 0],
        p_ned + R*[-1.0*dx, -dy_long, 0],
        p_ned + R*[-1.0*dx, -dy_short, 0],
        p_ned + R*[-1.0*dx, +dy_short, 0],
        p_ned + R*[-1.0*dx, +dy_long, 0],
    ]
    r_vr = 0.40
    for p_vp in p_vps
        plot!(fig,
              circle_shape(ned2enu(p_vp), r_vr, ned2enu(body_z));
              st=:line,
              c=:darkorange, lw=1.5, label=nothing, opacity=0.45,
             )
    end
    # horizontal prop
    p_hp = p_ned + R*[-3.2*dx, 0, -0.5*dx]
    r_hr = 0.5
    plot!(fig,
          circle_shape(ned2enu(p_hp), r_hr, ned2enu(body_x));
          st=:line,
          c=:purple, lw=1.5, label=nothing, opacity=0.45,
         )

    # body frame
    body_x_frame_enu = ned2enu.(LinRange(p_ned, p_ned+R*[1.0, 0, 0], 100))
    plot!(fig,
          [p[1] for p in body_x_frame_enu],
          [p[2] for p in body_x_frame_enu],
          [p[3] for p in body_x_frame_enu],
          c=:red,
          lw=2.5,
          label=nothing,
          )
    body_y_frame_enu = ned2enu.(LinRange(p_ned, p_ned+R*[0, 1.0, 0], 100))
    plot!(fig,
          [p[1] for p in body_y_frame_enu],
          [p[2] for p in body_y_frame_enu],
          [p[3] for p in body_y_frame_enu],
          c=:green,
          lw=2.5,
          label=nothing,
          )
    body_z_frame_enu = ned2enu.(LinRange(p_ned, p_ned+R*[0, 0, 1.0], 100))
    plot!(fig,
          [p[1] for p in body_z_frame_enu],
          [p[2] for p in body_z_frame_enu],
          [p[3] for p in body_z_frame_enu],
          c=:blue,
          lw=2.5,
          label=nothing,
          )
    plot!(fig;
          xlabel, ylabel, zlabel,
          kwargs...,
          )
    return fig
end


function vertical_props()
    
end
