export scatter

function refract(v::AbstractVector{<:Real}, n::AbstractVector{<:Real}, ni_over_nt::Float64)
    uv = unit_vector(v)
    dt = dot(uv, n)
    discriminant = 1.0 - ni_over_nt*ni_over_nt*(1-dt^2)
    if discriminant > 0.0
        refracted = ni_over_nt*(uv - n*dt) - n*sqrt(discriminant)
    else
        refracted = zeros(Vec)
    end
    return discriminant > 0.0, refracted
end

function schlick(cosine, refraction_index)
    r0 = (1 - refraction_index) / (1 + refraction_index)
    r0 = r0^2
    return r0 + (1-r0)*(1-cosine)^5
end

function reflect(v::AbstractVector{<:Real}, n::AbstractVector{<:Real})
    return v - 2 * dot(v, n) * n
end


"""
By default we absorb the ray (no scattering).
"""
function scatter!(ray::Ray, material::Material, rec::HitRecord)
    return false, zeros(Vec)
end

function scatter!(ray::Ray, material::EmitterMaterial, rec::HitRecord)
    return false, material.intensity .* material.color
end

function scatter!(ray::Ray, material::DiffuseMaterial, rec::HitRecord)
    # Compute diffuse shader using material
    target = rec.p + rec.normal + RayTracer.random_unit_vector()
    # Scattered ray starts from the intercept
    ray.origin[:] = rec.p
    ray.direction[:] = target - rec.p
    return true, material.color_diffuse
end


function scatter!(ray::Ray, material::MetalMaterial, rec::HitRecord)
    # Compute reflection
    reflected = reflect(unit_vector(ray.direction), rec.normal) .+ material.fuzz * RayTracer.random_point_in_unit_sphere()
    ray.origin[:] = rec.p
    ray.direction[:] = reflected
    is_scattered = dot(reflected, rec.normal) > 0.0
    if !is_scattered
        color = zeros(Vec)
    else
        color = material.reflection
    end
    return is_scattered, color
end

function scatter!(ray::Ray, material::DielectricMaterial, rec::HitRecord)
    # Compute reflection then refraction
    reflected = reflect(ray.direction, rec.normal)
    # The Dielectric material can tint the light refracted through it.
    attenuation = material.color

    if dot(ray.direction, rec.normal) > 0.0
        outward_normal = -rec.normal
        ni_over_nt = material.refraction_index
        cosine = material.refraction_index * dot(ray.direction, rec.normal) / norm(ray.direction)
    else
        outward_normal = rec.normal
        ni_over_nt = 1.0 / material.refraction_index
        cosine = -dot(ray.direction, rec.normal) / norm(ray.direction)
    end

    is_refracted, refracted = refract(ray.direction, outward_normal, ni_over_nt)
    if is_refracted
        reflect_probability = schlick(cosine, material.refraction_index)
    else
        reflect_probability = 1.0
    end

    ray.origin[:] = rec.p

    if rand() > reflect_probability
        scattered_direction = refracted
    else
        scattered_direction = reflected
    end
    ray.direction[:] = scattered_direction
    return true, attenuation
end


function scatter!(ray::Ray, material::ArbitraryMaterial, rec::HitRecord)
    # Compute shader for "arbitrary" material
    target = rec.p + rec.normal + RayTracer.random_point_in_unit_sphere()
    ray.origin[:] = rec.p
    ray.direction[:] = target - rec.p
    return true, 0.2 * material.color_diffuse
end
