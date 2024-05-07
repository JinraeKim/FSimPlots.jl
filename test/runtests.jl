using Test


@testset "FSimPlots.jl" begin
    mkpath("figures")
    include("multicopter.jl")
    include("description.jl")
    include("generate_gif.jl")
end
