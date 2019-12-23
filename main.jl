using ColorTypes
using Images
using Setfield

import LinearAlgebra: norm, dot

# We use image data H,W,C
# https://juliaimages.org/latest/quickstart/

# TODO: drop the include?
include("RayTracer.jl")

import Base.zero
zero(::Type{RGB{Float64}}) = RGB{Float64}(0,0,0)

unit_vector = v::Vector -> v/norm(v)

MAX_BOUNCES = 50

function reflect(v::Vector{Float64}, n::Vector{Float64})
    return v - 2*dot(v,n)*n
end

function color(ray::RayTracer.Ray, objects::Array{<:RayTracer.Object}, depth=0)

    rec = RayTracer.hit(objects, ray, 0.0001, maxintfloat(Float64))

    if typeof(rec) == RayTracer.HitRecord && depth < MAX_BOUNCES
        # Show normals
        #N = rec.normal
        #return 0.5 * (N .+ 1)

        # Compute diffuse shader using material
        target = rec.p + rec.normal + RayTracer.random_point_in_unit_sphere()
        scattered_ray = RayTracer.Ray(rec.p, target - rec.p)

        # Compute reflection
        reflected = reflect(unit_vector(ray.direction), rec.normal)
        reflected_ray = RayTracer.Ray(rec.p, reflected)
        # TODO use get_color() ?
        return rec.material.color_diffuse .* color(scattered_ray, objects, depth+1)
    else

        # Linear Interpolation of blue to white along y axis.
        unit_direction = unit_vector(ray.direction)
        t = 0.5 * (unit_direction[2] + 1.0)
        return (1.0 - t) * [1.0, 1.0, 1.0] + t * [0.5, 0.7, 1.0]
    end
end

# struct Scene
#     objects::Array{Sphere}
#     camera::Camera
#end


function ray_trace_sphere_objects()
    # We use image data H,W,C
    # https://juliaimages.org/latest/quickstart/
    channels, height, width = 3, 300, 600
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
                        reflection = 1.0)

    red_diffuse_material = @set default_material.color_diffuse = [0.8, 0.5, 0.5]
    blue_diffuse_material = @set default_material.color_diffuse = [0.5, 0.5, 0.8]

    scene_objects = [
        RayTracer.Sphere([0.0, -100.5, -1.0], 100.0, default_material),
        RayTracer.Sphere([-0.5, 0.0, -1.0], 0.4, red_diffuse_material),
        RayTracer.Sphere([0.5, 0.0, -1.0], 0.4, blue_diffuse_material),
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
            img_CHW[:, row, col] = pixel/num_samples

        end
    end
    return img_CHW
end


@time img_data = ray_trace_sphere_objects()

# For rendering we use Image data as an RGB array.
# Note our 3 dim matrix use channel-height-width order
# Use channelview and colorview to convert
rgb_img = colorview(RGB, img_data)

@show typeof(rgb_img)
@show size(rgb_img)

@time RayTracer.output_as_ppm(rgb_img)
