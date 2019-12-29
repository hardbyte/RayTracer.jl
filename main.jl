using ColorTypes
using Images
using Setfield
using ImageShow
import LinearAlgebra: norm, dot

# We use image data H,W,C
# https://juliaimages.org/latest/quickstart/

# TODO: drop the include?
include("RayTracer.jl")

import Base.zero
zero(::Type{RGB{Float64}}) = RGB{Float64}(0,0,0)

unit_vector = v::Vector -> v/norm(v)

MAX_BOUNCES = 30



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

function scatter(ray::RayTracer.Ray, material::RayTracer.DielectricMaterial, rec::RayTracer.HitRecord)
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

function scatter(ray::RayTracer.Ray, material::RayTracer.MetalMaterial, rec::RayTracer.HitRecord)
    # Compute reflection
    reflected = reflect(unit_vector(ray.direction), rec.normal) .+ material.fuzz * RayTracer.random_point_in_unit_sphere()
    reflected_ray = RayTracer.Ray(rec.p, reflected)
    is_scattered = dot(reflected_ray.direction, rec.normal) > 0.0
    return is_scattered, material.reflection, reflected_ray
end

function scatter(ray::RayTracer.Ray, material::RayTracer.DiffuseMaterial, rec::RayTracer.HitRecord)
    # Compute diffuse shader using material
    target = rec.p + rec.normal + RayTracer.random_point_in_unit_sphere()
    scattered_ray = RayTracer.Ray(rec.p, target - rec.p)
    return true, material.color_diffuse, scattered_ray
end

function scatter(ray::RayTracer.Ray, material::RayTracer.ArbitraryMaterial, rec::RayTracer.HitRecord)
    # Compute shader for "arbitrary" material
    target = rec.p + rec.normal + RayTracer.random_point_in_unit_sphere()
    scattered_ray = RayTracer.Ray(rec.p, target - rec.p)
    return true, 0.2 * material.color_diffuse, scattered_ray
end

function color(ray::RayTracer.Ray, objects::Array{<:RayTracer.Object}, depth=0)

    rec = RayTracer.hit(objects, ray, 0.0001, maxintfloat(Float64))

    if typeof(rec) == RayTracer.HitRecord
        is_scattered, attenuation, scattered_ray = scatter(ray, rec.material, rec)
        if is_scattered && depth < MAX_BOUNCES
            return attenuation .* color(scattered_ray, objects, depth+1)
        else
            return zeros(Float64, 3)
        end

        # Show normals
        #N = rec.normal
        #return 0.5 * (N .+ 1)

    else

        # Linear Interpolation of blue to white along y axis.
        unit_direction = unit_vector(ray.direction)
        t = 0.5 * (unit_direction[2] + 1.0)
        return (1.0 - t) * [1.0, 1.0, 1.0] + t * [0.5, 0.7, 1.0]
    end
end


function ray_trace_sphere_objects()
    # We use image data H,W,C
    # https://juliaimages.org/latest/quickstart/
    channels, height, width = 3, 200, 400
    num_samples = 50
    # Preallocate output image array
    img_CHW::Array{Float64, 3} = zeros(Float64, channels, height, width)
    lower_left_corner = [-2.0, -1.0, -1.0]
    horizontal = [4.0, 0.0, 0.0]
    vertical = [0.0, 2.0, 0.0]
    origin = [0.0, 0.0, 0.0]

    camera = RayTracer.Camera(
        lower_left_corner,
        horizontal,
        vertical,
        origin
    )

    default_material = RayTracer.Material(color_ambient = ones(3),
                        color_diffuse = ones(3),
                        color_specular = ones(3),
                        specular_exponent = 50.0,
                        reflection = zeros(3))

    # red_diffuse_material = RayTracer.DiffuseMaterial([0.7, 0.3, 0.3])
    # blue_diffuse_material = RayTracer.DiffuseMaterial([0.3, 0.3, 0.8])
    # dielectric_material = RayTracer.DielectricMaterial(1.5)
    # blue_metalic_material = RayTracer.MetalMaterial([0.8, 0.8, 0.95], 0.7)
    # yellow_metalic_material = RayTracer.MetalMaterial([0.8, 0.6, 0.2], 0.05)
    #
    # scene_objects = [
    #     RayTracer.Sphere([0.0, -601, -1.0], 600.0, default_material),
    #     RayTracer.Sphere([-1.4, -0.5, -3.0], 1, blue_diffuse_material),
    #     RayTracer.Sphere([0.0, 0.0, -2.0], 0.5, dielectric_material),
    #     RayTracer.Sphere([1.8, 0.0, -1.6], 0.2, dielectric_material),
    #     RayTracer.Sphere([1, 0.0, -3.0], 1, yellow_metalic_material),
    #     RayTracer.Sphere([2.5, -1.0, -2.5], 0.5, red_diffuse_material),
    #     RayTracer.Sphere([2.8, 0.0, -2.0], 0.5, blue_metalic_material),
    # ]


    scene_objects = [
        RayTracer.Sphere([0, 0, -1], 0.5, RayTracer.DiffuseMaterial([0.1,0.2,0.5])),
        RayTracer.Sphere([0, -100.5, -1], 100, RayTracer.DiffuseMaterial([0.8,0.8,0.0])),
        RayTracer.Sphere([1,0,-1], 0.5, RayTracer.MetalMaterial([0.8,0.6,0.2], 0.3)),
        RayTracer.Sphere([-1,0,-1], 0.5, RayTracer.DielectricMaterial(1.5)),
        # note that if you use a negative radius, the geometry is unaffected but
        # the surface normal points inward, so it can be used as a bubble to make
        # a hollow glass sphere
        RayTracer.Sphere([-1,0,-1], -0.45, RayTracer.DielectricMaterial(1.5)),
        #RayTracer.Sphere(),


    ]


    for row in height:-1:1
        for col in 1:width
            pixel = [0.0, 0.0, 0.0]
            noise = rand(2, num_samples)
            for sample in 1:num_samples
                u = (noise[1, sample] + col)/width
                v = (noise[2, sample] + row)/height

                ray = RayTracer.get_ray(camera, u, v)
                pixel += color(ray, scene_objects)
            end
            img_CHW[:, row, col] = sqrt.(pixel/num_samples)

        end
    end
    return img_CHW
end


@info "Rendering scene"
@time img_data = ray_trace_sphere_objects()
@info "Rendering complete"

# For rendering we use Image data as an RGB array.
# Note our 3 dim matrix use channel-height-width order
# Use channelview and colorview to convert
rgb_img = colorview(RGB, img_data)

@show typeof(rgb_img)
@show size(rgb_img)

# FLip the Y axis for showing with ImageView
image = reverse(rgb_img, dims=1)

# To bring up a GUI
# using ImageView
#imshow(image)

# To show in Juno/Repl
#@show image

# Save output/s
save("img.png", image)
#RayTracer.output_as_ppm(rgb_img)

image;
