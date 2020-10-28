using Setfield  # provides the @set macro
using StaticArrays

const Vec = SVector{3, Float64}

# struct Vec <: FieldVector{3, Float64}
#     x::Float64
#     y::Float64
#     z::Float64
# end

to_uint = x -> UInt8(round(x * 255))
color_to_vector = c::RGB -> Vec(red(c), green(c), blue(c))

unit_vector = v::AbstractVector{<:Real} -> Vec(v/norm(v))

function random_point_in_unit_sphere()
    point_in_unit_cube = () -> 2 * rand(Vec) - ones(Vec)
    pnt = point_in_unit_cube()
    while sum(pnt .^ 2) >= 1.0
        pnt = point_in_unit_cube()
    end
    return pnt
end

function random_point_in_unit_disk()
    point_in_unit_square = () -> 2.0 * rand(Vec) - ones(Vec)
    pnt = point_in_unit_square()
    while dot(pnt, pnt) >= 1.0
        pnt = point_in_unit_square()
    end
    return @set pnt[3] = 0.0
end
