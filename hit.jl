import Base.zero
import Base.copy!

mutable struct HitRecord
    t::Float64
    p::Vector{Float64}
    normal::Vector{Float64}
    #material::Material
end

zero(::Type{HitRecord}) = RayTracer.HitRecord(maxintfloat(Float64), zeros(Float64, 3), zeros(Float64, 3))

function copy!(dst::HitRecord, src::HitRecord)
    setfield!(dst, :t, src.t)
    setfield!(dst, :p, src.p[:])
    setfield!(dst, :normal, src.normal[:])
    #setfield!(dst, :material, src.material)
end

function hit(obj::Sphere, ray::Ray, t_min::Float64, t_max::Float64, ret::HitRecord)
    oc = ray.origin - obj.center
    a = dot(ray.direction, ray.direction)
    b = dot(oc, ray.direction)
    c = dot(oc, oc) - obj.radius^2
    discriminant = b^2 - a * c
    if discriminant > 0
        temp = (-b - sqrt(discriminant))/a
        if (temp < t_max) && (temp > t_min)
            p = point_along_ray(ray, temp)

            setfield!(ret, :t, temp)
            setfield!(ret, :p, p)
            setfield!(ret, :normal, (p - obj.center) / obj.radius)

            return true
        end
        temp = (-b + sqrt(discriminant))/a
        if (temp < t_max) && (temp > t_min)
            p = point_along_ray(ray, temp)

            setfield!(ret, :t, temp)
            setfield!(ret, :p, p)
            setfield!(ret, :normal, (p - obj.center) / obj.radius)
            return true
        end
    end
    return false
end

function hit(objects::Array{<:Object}, ray::Ray, t_min::Float64, t_max::Float64, rec::HitRecord)
    closest_so_far = t_max
    current_hit = zero(HitRecord)

    current_material = Material()

    any_hit = false
    for obj in objects
        if hit(obj, ray, t_min, t_max, current_hit)
            any_hit = true
            if current_hit.t < closest_so_far
                closest_so_far = current_hit.t
                current_material = obj.material
                copy!(rec, current_hit)
            end
        end
        # Note there are also lots of non hits...
    end
    return any_hit, current_material
end
