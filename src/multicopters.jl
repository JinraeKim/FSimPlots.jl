"""
    plot!(multicopter::Multicopter, fig, state)

# Variables
fig: figure object, i.e., fig = plot()
state: see `State(env::Multicopter)`.
# Notes
Default configuration: ENU-coordinate system.
For airframe references, see https://docs.px4.io/master/en/airframes/airframe_reference.html.
"""
function Plots.plot!(fig::Plots.Plot, multicopter::Multicopter, state;
        xlabel="E (m)", ylabel="N (m)", zlabel="U (m)",
        kwargs...)
    (; l) = multicopter
    airframe_ref = FSimZoo.airframe_reference(multicopter)
    (; p, v, q, ω) = state
    R = quat2dcm(q)
    p_enu = ned2enu(p)
    body_n = R*[1, 0, 0]  # B to I
    body_e = R*[0, 1, 0]  # B to I
    body_u = R*[0, 0, -1]  # B to I
    # plotting
    plot!(fig;
          xlabel=xlabel, ylabel=ylabel, zlabel=zlabel,
          kwargs...)
    plot_fuselage!(fig, p, R, l, body_n, body_e)
    plot_rotors!(fig, p, R, l, l/2.5, body_u, airframe_ref)
    plot_propeller!(fig, p, R, l, l/15, body_u, airframe_ref)
    plot_frames!(fig, p, R, l, airframe_ref)
    fig
end

function Plots.plot(multicopter::Multicopter, state; kwargs...)
    fig = plot()
    plot!(fig, multicopter, state; kwargs...)
    fig
end


"""
c: centre
r: radius
h: direction of normal vector
"""
function circle_shape(c, r, h; phase=0.0)
    vec1 = nothing
    while true
        rand_vec = rand(3)
        vec1 = cross(h, rand_vec)
        if norm(vec1) > 0
            vec1 = vec1 / norm(vec1)
            break
        end
    end
    vec2 = cross(h, vec1)
    vec2 = vec2 / norm(vec2)
    return ellipse_shape(c, r, r, vec1, vec2; phase=0.0)
end


function ellipse_shape(c, r1, r2, vec1, vec2; phase=0.0)
    θs = LinRange(0, 2*π-1e-2, 300)
    circle = [(c + r1*cos(θ+phase)*vec1 + r2*sin(θ+phase)*vec2) for θ in θs]
    circle_1 = [p[1] for p in circle]
    circle_2 = [p[2] for p in circle]
    circle_3 = [p[3] for p in circle]
    circle_1, circle_2, circle_3
end


"""
c: centre
h1: forward direction (x)
h2: side direction (pointing another point of the triangle)
h3: side direction (pointing the other point of the triangle)
l1: length up to a point
l2: length up to another point
l3: length up to the other point (l2=l3)
"""
function triangle_shape(c, h1, h2, l1, l2)
    h1 = h1 / norm(h1)  # unit vec
    h2 = h2 / norm(h2)  # unit vec
    h3 = 2*(dot(h1, h2)*l2*h1 - l2*h2) + l2*h2
    h3 = h3 / norm(h3)
    l3 = l2
    ts = LinRange(0, 1, 200)
    triangle_A = [(c + l1*h1)*t + (c + l2*h2)*(1-t) for t in ts]
    triangle_B = [(c + l2*h2)*t + (c + l3*h3)*(1-t) for t in ts]
    triangle_C = [(c + l3*h3)*t + (c + l1*h1)*(1-t) for t in ts]
    # triangle_A = ts |> Map(t -> (c + l1*h1)*t + (c + l2*h2)*(1-t)) |> collect
    # triangle_B = ts |> Map(t -> (c + l2*h2)*t + (c + l3*h3)*(1-t)) |> collect
    # triangle_C = ts |> Map(t -> (c + l3*h3)*t + (c + l1*h1)*(1-t)) |> collect
    triangle = vcat(triangle_A, triangle_B, triangle_C)
    triangle_1 = [p[1] for p in triangle]
    triangle_2 = [p[2] for p in triangle]
    triangle_3 = [p[3] for p in triangle]
    # triangle_1 = triangle |> Map(p -> p[1]) |> collect
    # triangle_2 = triangle |> Map(p -> p[2]) |> collect
    # triangle_3 = triangle |> Map(p -> p[3]) |> collect
    triangle_1, triangle_2, triangle_3
end

function plot_fuselage!(fig::Plots.Plot, p, R, l, body_n, body_e)
    p_enu = ned2enu(p)
    body_n_enu = ned2enu(body_n)
    body_e_enu = ned2enu(body_e)
    length_ratio = 0.3
    point_1 = p + length_ratio*l*R*[1, 0, 0]  # R': B to I
    point_2 = p + length_ratio*l*R*[0, 1, 0]
    point_3 = p + length_ratio*l*R*[-1, 0, 0]
    point_4 = p + length_ratio*l*R*[0, -1, 0]
    boundary_12_enu = ned2enu.(LinRange(point_1, point_2, 100))
    boundary_23_enu = ned2enu.(LinRange(point_2, point_3, 100))
    boundary_34_enu = ned2enu.(LinRange(point_3, point_4, 100))
    boundary_41_enu = ned2enu.(LinRange(point_4, point_1, 100))
    plot!(fig,
          [_p[1] for _p in boundary_12_enu],
          [_p[2] for _p in boundary_12_enu],
          [_p[3] for _p in boundary_12_enu],
          lw=2.0,
          opacity=0.50,
          c=:black, label=nothing)  # position
    plot!(fig,
          [_p[1] for _p in boundary_23_enu],
          [_p[2] for _p in boundary_23_enu],
          [_p[3] for _p in boundary_23_enu],
          lw=2.0,
          opacity=0.50,
          c=:black, label=nothing)  # position
    plot!(fig,
          [_p[1] for _p in boundary_34_enu],
          [_p[2] for _p in boundary_34_enu],
          [_p[3] for _p in boundary_34_enu],
          lw=2.0,
          opacity=0.50,
          c=:black, label=nothing)  # position
    plot!(fig,
          [_p[1] for _p in boundary_41_enu],
          [_p[2] for _p in boundary_41_enu],
          [_p[3] for _p in boundary_41_enu],
          lw=2.0,
          opacity=0.50,
          c=:black, label=nothing)  # position
    # direction
    plot!(fig,
          triangle_shape(p_enu, body_n_enu, -1.5*body_n_enu+body_e_enu, 0.2*l, 0.15*l);
          st=:line,
          c=:red, opacity=0.75, lw=1.5, label=nothing,
         )
end

function rotor_positions(p0, R, l, airframe_ref)
    if airframe_ref == :hexa_x
        pf_1 = p0 + l*R*[0, 1, 0]  # R': B to I
        pf_2 = p0 + l*R*[0, -1, 0]
        pf_3 = p0 + l*R*[cos(deg2rad(-30)), sin(deg2rad(-30)), 0]
        pf_4 = p0 + l*R*[cos(deg2rad(150)), sin(deg2rad(150)), 0]
        pf_5 = p0 + l*R*[cos(deg2rad(30)), sin(deg2rad(30)), 0]
        pf_6 = p0 + l*R*[cos(deg2rad(210)), sin(deg2rad(210)), 0]
        return [pf_1, pf_2, pf_3, pf_4, pf_5, pf_6]
    elseif airframe_ref == :quad_plus
        pf_1 = p0 + l*R*[0, 1, 0]  # R': B to I
        pf_2 = p0 + l*R*[0, -1, 0]
        pf_3 = p0 + l*R*[1, 0, 0]  # R': B to I
        pf_4 = p0 + l*R*[-1, 0, 0]
        return [pf_1, pf_2, pf_3, pf_4]
    else
        error("Invalid airframe reference")
    end
end

function plot_rotor!(fig::Plots.Plot, p, r, body_u, color, opacity)
    body_u_enu = ned2enu(body_u)
    p_enu = ned2enu(p)
    plot!(fig,
          circle_shape(p_enu, r, body_u_enu);
          st=:line,
          c=color, lw=1.5, label=nothing, opacity=opacity,
         )
end

function plot_circles!(fig::Plots.Plot, p0, R, l, r, body_u, airframe_ref, color_cw, color_ccw, opacity)
    pfs = rotor_positions(p0, R, l, airframe_ref)
    if airframe_ref == :hexa_x
        colors = [
            color_cw,
            color_ccw,
            color_cw,
            color_ccw,
            color_ccw,
            color_cw,
        ]
    elseif airframe_ref == :quad_plus
        colors = [
            color_ccw,
            color_ccw,
            color_cw,
            color_cw,
        ]
    else
        error("Invalid airframe reference")
    end
    for (pf, color) in zip(pfs, colors)
        plot_rotor!(fig, pf, r, body_u, color, opacity)
    end
end

function plot_rotors!(fig::Plots.Plot, p0, R, l, r, body_u, airframe_ref)
    plot_circles!(fig, p0, R, l, r, body_u, airframe_ref, :green, :blue, 0.35)
end

function plot_propeller!(fig::Plots.Plot, p0, R, l, r, body_u, airframe_ref)
    plot_circles!(fig, p0, R, l, r, body_u, airframe_ref, :white, :white, 0.50)
end

function plot_frame!(fig::Plots.Plot, p0, pf)
    frame = LinRange(p0, pf, 100)
    frame_enu = ned2enu.(frame)
    plot!(fig,
          [_p[1] for _p in frame_enu],
          [_p[2] for _p in frame_enu],
          [_p[3] for _p in frame_enu],
          c=:black,
          lw=2.0,
          label=nothing,
          opacity=0.50,
         )
end

function plot_frames!(fig::Plots.Plot, p0, R, l, airframe_ref)
    if airframe_ref == :hexa_x
        pf_1, pf_2, pf_3, pf_4, pf_5, pf_6 = rotor_positions(p0, R, l, airframe_ref)
        ratio_12 = 0.3
        ratio_3456 = 0.22
        p0_1 = (1-ratio_12)*p0 + ratio_12*pf_1
        p0_2 = (1-ratio_12)*p0 + ratio_12*pf_2
        p0_3 = (1-ratio_3456)*p0 + ratio_3456*pf_3
        p0_4 = (1-ratio_3456)*p0 + ratio_3456*pf_4
        p0_5 = (1-ratio_3456)*p0 + ratio_3456*pf_5
        p0_6 = (1-ratio_3456)*p0 + ratio_3456*pf_6
        plot_frame!(fig, p0_1, pf_1)  # 1
        plot_frame!(fig, p0_2, pf_2)  # 2
        plot_frame!(fig, p0_3, pf_3)  # 3
        plot_frame!(fig, p0_4, pf_4)  # 4
        plot_frame!(fig, p0_5, pf_5)  # 5
        plot_frame!(fig, p0_6, pf_6)  # 6
    elseif airframe_ref == :quad_plus
        pf_1, pf_2, pf_3, pf_4 = rotor_positions(p0, R, l, airframe_ref)
        ratio = 0.3
        p0_1 = (1-ratio)*p0 + ratio*pf_1
        p0_2 = (1-ratio)*p0 + ratio*pf_2
        p0_3 = (1-ratio)*p0 + ratio*pf_3
        p0_4 = (1-ratio)*p0 + ratio*pf_4
        plot_frame!(fig, p0_1, pf_1)  # 1
        plot_frame!(fig, p0_2, pf_2)  # 2
        plot_frame!(fig, p0_3, pf_3)  # 3
        plot_frame!(fig, p0_4, pf_4)  # 4
    else
        error("Invalid airframe reference")
    end
end
