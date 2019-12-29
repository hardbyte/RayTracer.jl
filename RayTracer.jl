module RayTracer

using ColorTypes
import LinearAlgebra: norm, dot

include("ray.jl")
include("materials.jl")
include("objects.jl")
include("hit.jl")
include("scattering.jl")
include("camera.jl")


to_uint = x -> UInt8(round(x * 255))
color_to_vector = c::RGB -> [red(c), green(c), blue(c)]

unit_vector = v::Vector -> v/norm(v)

const MAX_BOUNCES = 10


"""
    Returns a function that interpolates between 2 vectors (colors or positions)
    based on the direction along the axis provided {1:x, 2:y, 3:z} of a Ray.
"""
function linear_interpolator(first::Vector{Float64}, second::Vector{Float64}; axis=2)
    function f(ray::RayTracer.Ray)
        # Scale from [-1,+1] to [0,1]
        t = 0.5 * (unit_vector(ray.direction)[axis] + 1.0)
        return (1.0 - t) * second + t * first
    end
    return f
end

const default_bg = linear_interpolator([0.6, 0.6, 0.6], [0.3, 0.3, 0.9])


function color(ray::RayTracer.Ray, objects::Array{<:RayTracer.Object}; depth=0, background=default_bg)::Vector{Float64}
    # Preallocate a HitRecord
    rec = zero(HitRecord)
    is_hit, hit_material = RayTracer.hit(objects, ray, 0.001, maxintfloat(Float64), rec)

    if is_hit
        is_scattered, attenuation, scattered_ray = scatter(ray, hit_material, rec)
        if is_scattered && depth < MAX_BOUNCES
            return attenuation .* color(scattered_ray, objects, depth=depth+1, background=background)
        else
            return zeros(Float64, 3)
        end
    else
        return background(ray)
    end
end


function random_point_in_unit_sphere()
    point_in_unit_cube = () -> 2 * rand(3) - ones(3)
    pnt = point_in_unit_cube()
    while sum(pnt.^2) >= 1.0
        pnt = point_in_unit_cube()
    end
    return pnt
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



"""

"""
function raytrace(; height::Int64, width::Int64, camera_angle::Float64, scene)
    camera = Camera(camera_angle, width/height)
    num_samples = 50

    # Preallocate output image array
    #pixel_data::Array{Float64, 4} = zeros(Float64, 3, num_samples, height, width)
    pixel_data::Array{Float64, 3} = zeros(Float64, 3, height, width)

    for row in height:-1:1
        for col in 1:width
            pixel = [0.0, 0.0, 0.0]

            for sample in 1:num_samples
                u = (rand() + col)/width
                v = (rand() + row)/height

                ray = RayTracer.get_ray(camera, u, v)
                #pixel = color(ray, scene, background=default_bg)
                #pixel_data[:, sample, row, col] = pixel

                pixel += color(ray, scene, background=default_bg)
            end
            pixel_data[:, row, col] = pixel/num_samples
        end
    end

    #img_CHW::Array{Float64, 3} = dropdims(sum(pixel_data, dims=2)/num_samples, dims=2)
    img_CHW::Array{Float64, 3} = pixel_data
    return reverse(sqrt.(img_CHW), dims=2)
end


end # module
