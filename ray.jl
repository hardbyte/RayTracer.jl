
# Ray
struct Ray
    origin::Vector{Float64}
    direction::Vector{Float64}
end

function point_along_ray(ray::Ray, time::Float64)
    return ray.origin + time*ray.direction
end
