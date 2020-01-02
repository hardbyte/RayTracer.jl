
# Ray
struct Ray
    origin::MVector{3, Float64}
    direction::MVector{3, Float64}
end

function point_along_ray(ray::Ray, t::Float64)
    return ray.origin + t*ray.direction
end
