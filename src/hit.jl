import Base: zero, copy!, !, Bool

mutable struct HitRecord
    t::Float64
    p::Vec
    normal::Vec
    material::Material
end

zero(::Type{HitRecord}) = RayTracer.HitRecord(maxintfloat(Float64), zeros(Vec), zeros(Vec), Material())
const no_hit = zero(HitRecord)

!(rec::HitRecord) = rec == no_hit
Bool(rec::HitRecord) = rec !== no_hit

function hit(objects::Vector{<:Object}, ray::Ray, t_min::Float64, t_max::Float64)
    closest_so_far = t_max
    closest_hit = no_hit

    for obj in objects
        current_hit = hit(obj, ray, t_min, t_max)
        if current_hit !== no_hit
            if current_hit.t < closest_so_far
                closest_hit = current_hit
                closest_so_far = current_hit.t
            end
        end
        # Note there are also lots of non hits...
    end
    return closest_hit
end
