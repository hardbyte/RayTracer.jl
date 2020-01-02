module RayTracer

using ColorTypes
using StaticArrays
import LinearAlgebra: norm, dot, cross

include("util.jl")
include("ray.jl")
include("materials.jl")
include("objects.jl")
include("hit.jl")
include("scattering.jl")
include("camera.jl")



const MAX_BOUNCES = 16


"""
    Returns a function that interpolates between 2 vectors (colors or positions)
    based on the direction along the axis provided {1:x, 2:y, 3:z} of a Ray.
"""
function linear_interpolator(first::T, second::T; axis=2) where {T <: AbstractVector{<:Real}}
    function f(ray::Ray)
        # Scale from [-1,+1] to [0,1]
        t = 0.5 * (unit_vector(ray.direction)[axis] + 1.0)
        return (1.0 - t) * second + t * first
    end
    return f
end


const default_bg = linear_interpolator(Vec(0.6, 0.6, 0.6), Vec(0.3, 0.3, 0.9))


function color(ray::Ray, objects::Array{<:Object}; background=default_bg)::Vec
    output_attenuation = ones(Vec)
    scattered_ray = ray
    for depth in 0:MAX_BOUNCES

        # Get the first object intersection for the ray.
        hit_record = RayTracer.hit(objects, scattered_ray, 0.001, maxintfloat(Float64))

        if hit_record !== no_hit
            # Color using the hit object's materials
            is_scattered, attenuation = scatter!(scattered_ray, hit_record.material, hit_record)
            output_attenuation = output_attenuation .* attenuation
            if !is_scattered
                # The hit object absorbed this ray. E.g. the very edge of a sphere
                return zeros(Vec)
            end
        else
            # Missed all objects; sample the background for this Ray
            return output_attenuation .* background(scattered_ray)
        end
    end
    # After MAX_BOUNCES which all hit objects we return zeros
    return zeros(Vec)
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
function raytrace(; height::Int64, width::Int64, camera::Camera, scene, num_samples=32)

    # Preallocate output image array
    pixel_data::Array{Float64, 3} = zeros(Float64, 3, height, width)

    for row in height:-1:1
        for col in 1:width
            pixel = [0.0, 0.0, 0.0]

            for sample in 1:num_samples
                u = (rand() + col)/width
                v = (rand() + row)/height

                ray = RayTracer.get_ray(camera, u, v)
                pixel += color(ray, scene, background=default_bg)
            end
            pixel_data[:, row, col] = pixel/num_samples
        end
    end

    img_CHW::Array{Float64, 3} = pixel_data
    return reverse(sqrt.(img_CHW), dims=2)
end


end # module
