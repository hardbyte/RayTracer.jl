module RayTracer

using ColorTypes
import LinearAlgebra: norm, dot

include("materials.jl")
include("objects.jl")


to_uint = x -> UInt8(round(x * 255))
color_to_vector = c::RGB -> [red(c), green(c), blue(c)]

function random_point_in_unit_sphere()
    point_in_unit_cube = () -> 2 * rand(3) - ones(3)
    pnt = point_in_unit_cube()
    while sum(pnt.^2) >= 1.0
        pnt = point_in_unit_cube()
    end
    return pnt
end

struct Camera
    lower_left_corner::Vector{Float64}
    horizontal::Vector{Float64}
    vertical::Vector{Float64}
    origin::Vector{Float64}
end

function get_ray(camera::Camera, u,v)::Ray
    return Ray(camera.origin, camera.lower_left_corner + u*camera.horizontal + v*camera.vertical)
end


function output_as_ppm(data::AbstractArray{RGB{Float64}, 2}, fname="out.ppm")
    rows, columns = size(data)
    @info "Writing data as ppm"
    @info "Input dimensions: $(size(data))"
    open(fname, "w") do f
        write(f, "P3\n")
        write(f, "$columns $rows\n")
        write(f, "255\n")
        for row in rows:-1:1
            for column in 1:columns
                r, g, b = map(to_uint, sqrt.(color_to_vector(data[row, column])))
                write(f, "$r $g $b\n")
            end
        end
    end
end

# Ray
struct Ray
    origin::Vector{Float64}
    direction::Vector{Float64}
end

function point_along_ray(ray::Ray, time::Float64)
    return ray.origin + time*ray.direction
end


struct HitRecord
    t::Float64
    p::Vector{Float64}
    normal::Vector{Float64}
    material::Material
end


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
            return HitRecord(temp, p, (p - obj.center) / obj.radius, obj.material)
        end
        temp = (-b + sqrt(discriminant))/a
        if (temp < t_max) && (temp > t_min)
            p = point_along_ray(ray, temp)
            return HitRecord(temp, p, (p - obj.center) / obj.radius, obj.material)
        end
    end
end

function hit(objects::Array{<:Object}, ray::Ray, t_min::Float64, t_max::Float64)
    hit_anything = false
    closest_so_far = t_max
    closest_hit = Nothing
    for obj in objects
        optional_hit_record = hit(obj, ray, t_min, t_max)
        if typeof(optional_hit_record) == HitRecord
            hit_anything = true
            closest_so_far = optional_hit_record.t
            closest_hit = optional_hit_record
        end
    end
    return closest_hit
end

end # module
