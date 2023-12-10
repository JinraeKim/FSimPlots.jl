using Test


@testset "FSimPlots.jl" begin
    mkpath("figures")
    include("hexacopter.jl")
    include("description.jl")
    include("generate_gif.jl")
end
