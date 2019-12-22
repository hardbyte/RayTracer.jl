using ColorTypes
using Images
import LinearAlgebra: norm, dot

# We use image data H,W,C
# https://juliaimages.org/latest/quickstart/

# TODO: drop the include?
include("RayTracer.jl")

import Base.zero
zero(::Type{RGB{Float64}}) = RGB{Float64}(0,0,0)

function hit_sphere(center::Vector{Float64}, radius::Float64, ray::RayTracer.Ray)::Float64
    oc = ray.origin - center
    a = dot(ray.direction, ray.direction)
    b = 2.0 * dot(oc, ray.direction)
    c = dot(oc, oc) - radius^2
    discriminant = b^2 - 4*a*c
    if discriminant < 0
        return -1.0
    else
        return (-b - sqrt(discriminant))/(2.0*a)
    end
end

unit_vector = v::Vector -> v/norm(v)

function color(ray::RayTracer.Ray, objects::Array{RayTracer.Sphere})

    rec = RayTracer.hit(objects, ray, 0.0, maxintfloat(Float64))

    if typeof(rec) == RayTracer.HitRecord
        N = rec.normal
        return 0.5 * (N .+ 1)
    end

    # Linear Interpolation of blue to white along y axis.
    unit_direction = unit_vector(ray.direction)
    t = 0.5 * (unit_direction[2] + 1.0)
    return (1.0 - t) * [1.0, 1.0, 1.0] + t * [0.5, 0.7, 1.0]
end


function generate_image_from_ray_tracer()
    # We use image data H,W,C
    # https://juliaimages.org/latest/quickstart/
    channels, height, width = 3, 100, 200
    # Preallocate output image array
    img_CHW::Array{Float64, 3} = zeros(Float64, channels, height, width)
    lower_left_corner = [-2.0, -1.0, -1.0]
    horizontal = [4.0, 0.0, 0.0]
    vertical = [0.0, 2.0, 0.0]
    origin = [0.0, 0.0, 0.0]

    for row in height:-1:1
        for col in 1:width
            u = col/width
            v = row/height
            ray = RayTracer.Ray(origin, lower_left_corner + u*horizontal + v*vertical)
            img_CHW[:, row, col] = color(ray)
        end
    end
    return img_CHW
end

function ray_trace_sphere_objects()
    # We use image data H,W,C
    # https://juliaimages.org/latest/quickstart/
    channels, height, width = 3, 100, 200
    # Preallocate output image array
    img_CHW::Array{Float64, 3} = zeros(Float64, channels, height, width)
    lower_left_corner = [-2.0, -1.0, -1.0]
    horizontal = [4.0, 0.0, 0.0]
    vertical = [0.0, 2.0, 0.0]
    origin = [0.0, 0.0, 0.0]

    camera = RayTracer.Camera(
        [-2.0, -1.0, -1.0],
        [4.0, 0.0, 0.0],
        [0.0, 2.0, 0.0],
        [0.0, 0.0, 0.0]
    )

    scene_objects = [
        RayTracer.Sphere([0.0, -100.5, -1.0], 100.0),
        RayTracer.Sphere([-0.5, 0.0, -1.0], 0.5),
        RayTracer.Sphere([0.5, 0.0, -1.0], 0.5),
    ]

    for row in height:-1:1
        for col in 1:width
            u = col/width
            v = row/height
            ray = RayTracer.Ray(origin, lower_left_corner + u*horizontal + v*vertical)
            p = RayTracer.point_along_ray(ray, 2.0)
            img_CHW[:, row, col] = color(ray, scene_objects)
        end
    end
    return img_CHW
end


img_data = ray_trace_sphere_objects()

# For rendering we use Image data as RGB array.
# Note our 3 dim matrix use channel-height-width order
# Use channelview and colorview to convert
rgb_img = colorview(RGB, img_data)

@show typeof(rgb_img)
@show size(rgb_img)

RayTracer.output_as_ppm(rgb_img)

