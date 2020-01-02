import Base.zero
import Base.copy!

mutable struct HitRecord
    t::Float64
    p::Vec
    normal::Vec
    material::Material
end

zero(::Type{HitRecord}) = RayTracer.HitRecord(maxintfloat(Float64), zeros(Vec), zeros(Vec), Material())

const no_hit = zero(HitRecord)


function hit(objects::Vector{<:Object}, ray::Ray, t_min::Float64, t_max::Float64)
    closest_so_far = t_max
    closest_hit = nothing
    any_hit = false
    for obj in objects
        just_hit, current_hit = hit(obj, ray, t_min, t_max)
        if just_hit
            any_hit = true
            if current_hit.t < closest_so_far
                closest_hit = current_hit
                closest_so_far = current_hit.t
            end
        end
        # Note there are also lots of non hits...
    end
    return any_hit, closest_hit
end
