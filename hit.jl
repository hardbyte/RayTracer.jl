import Base.zero
import Base.copy!

mutable struct HitRecord
    t::Float64
    p::Vector{Float64}
    normal::Vector{Float64}
    material::Material
end

zero(::Type{HitRecord}) = RayTracer.HitRecord(maxintfloat(Float64), zeros(Float64, 3), zeros(Float64, 3), Material())


function hit(obj::Sphere, ray::Ray, t_min::Float64, t_max::Float64)
    oc = ray.origin - obj.center
    a = dot(ray.direction, ray.direction)
    b = dot(oc, ray.direction)
    c = dot(oc, oc) - obj.radius^2
    discriminant = b^2 - a * c
    if discriminant > 0
        temp = (-b - sqrt(discriminant))/a
        if (temp < t_max) && (temp > t_min)
            p = point_along_ray(ray, temp)
            return true, HitRecord(temp, p, (p - obj.center) / obj.radius, obj.material)
        end
        temp = (-b + sqrt(discriminant))/a
        if (temp < t_max) && (temp > t_min)
            p = point_along_ray(ray, temp)
            return true, HitRecord(temp, p, (p - obj.center) / obj.radius, obj.material)
        end
    end
    return false, nothing
end

function hit(objects::Array{<:Object}, ray::Ray, t_min::Float64, t_max::Float64)
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
