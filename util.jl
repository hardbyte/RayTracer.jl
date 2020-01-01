const Vec = SVector{3,Float64}

to_uint = x -> UInt8(round(x * 255))
color_to_vector = c::RGB -> SVector{3, Float64}(red(c), green(c), blue(c))

unit_vector = v::AbstractVector{<:Real} -> v/norm(v)

function random_point_in_unit_sphere()
    point_in_unit_cube = () -> 2 * rand(3) - ones(3)
    pnt = point_in_unit_cube()
    while sum(pnt.^2) >= 1.0
        pnt = point_in_unit_cube()
    end
    return Vec(pnt)
end

function random_point_in_unit_disk()
    point_in_unit_square = () -> 2.0 * rand(SVector{2,Float64}) - ones(SVector{2,Float64})
    pnt = point_in_unit_square()
    while dot(pnt, pnt) >= 1.0
        pnt = point_in_unit_square()
    end
    return Vec(pnt[1], pnt[2], 0.0)
end
