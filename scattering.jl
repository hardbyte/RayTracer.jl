export scatter

function refract(v::Vector{Float64}, n::Vector{Float64}, ni_over_nt::Float64)
    uv = unit_vector(v)
    dt = dot(uv, n)
    discriminant = 1.0 - ni_over_nt*ni_over_nt*(1-dt^2)
    if discriminant > 0.0
        refracted = ni_over_nt*(uv - n*dt) - n*sqrt(discriminant)
    else
        refracted = [0.0, 0.0, 0.0]
    end
    return discriminant > 0.0, refracted
end

function schlick(cosine, refraction_index)
    r0 = (1 - refraction_index) / (1 + refraction_index)
    r0 = r0^2
    return r0 + (1-r0)*(1-cosine)^5
end

function reflect(v::Vector{Float64}, n::Vector{Float64})
    return v - 2*dot(v,n)*n
end


function scatter(ray::Ray, material::NormalMaterial, rec::HitRecord)
    N = rec.normal
    return 0.5 * (N .+ 1)
end

function scatter(ray::Ray, material::DiffuseMaterial, rec::HitRecord)
    # Compute diffuse shader using material
    target = rec.p + rec.normal + RayTracer.random_point_in_unit_sphere()
    scattered_ray = RayTracer.Ray(rec.p, target - rec.p)
    return true, material.color_diffuse, scattered_ray
end


function scatter(ray::Ray, material::MetalMaterial, rec::HitRecord)
    # Compute reflection
    reflected = reflect(unit_vector(ray.direction), rec.normal) .+ material.fuzz * RayTracer.random_point_in_unit_sphere()
    reflected_ray = RayTracer.Ray(rec.p, reflected)
    is_scattered = dot(reflected_ray.direction, rec.normal) > 0.0
    return is_scattered, material.reflection, reflected_ray
end

function scatter(ray::Ray, material::DielectricMaterial, rec::HitRecord)
    # Compute reflection then refraction
    reflected = reflect(ray.direction, rec.normal)
    # todo material property
    attenuation = [1.0, 1.0, 1.0]

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

    if rand() > reflect_probability
        scattered = RayTracer.Ray(rec.p, refracted)
    else
        scattered = RayTracer.Ray(rec.p, reflected)
    end
    return true, attenuation, scattered
end


function scatter(ray::Ray, material::ArbitraryMaterial, rec::HitRecord)
    # Compute shader for "arbitrary" material
    target = rec.p + rec.normal + RayTracer.random_point_in_unit_sphere()
    scattered_ray = RayTracer.Ray(rec.p, target - rec.p)
    return true, 0.2 * material.color_diffuse, scattered_ray
end
