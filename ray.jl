
# Ray
struct Ray
    origin::Vec
    direction::Vec
end

function point_along_ray(ray::Ray, t::Float64)
    return ray.origin + t*ray.direction
end
