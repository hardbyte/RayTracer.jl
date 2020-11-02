
# Ray
struct Ray
    origin::MutableVec
    direction::MutableVec
end

function Ray(origin::V, direction::V) where {V <: AbstractVector{<:Real}}
    Ray(MutableVec(origin), MutableVec(unit_vector(direction)))
end

function point_along_ray(ray::Ray, t::Float64)
    return ray.origin + t*ray.direction
end
