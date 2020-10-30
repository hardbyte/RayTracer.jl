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
include("serialization.jl")


struct OutputProperties
    width::Int64
    height::Int64
end

struct RenderProperties
    samples::Int64
    max_bounces::Int64
end

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


#const default_bg = linear_interpolator(Vec(0.3, 0.3, 0.4), Vec(0.3, 0.3, 0.9))
const default_bg = r::Ray -> Vec(0.4, 0.4, 0.45)

emission(::Material, ::HitRecord) = zeros(Vec)
function emission(material::EmitterMaterial, hit_record::HitRecord)
    return material.intensity .* material.color
end

function emission(::NormalMaterial, rec::HitRecord)
    N = rec.normal
    return 0.5 * (N .+ 1)
end

function color(ray::Ray, objects::Vector{<:Object}; background=default_bg, max_bounces=MAX_BOUNCES)::Vec
    output_attenuation = ones(Vec)
    scattered_ray = ray
    for depth in 0:max_bounces

        # Get the first object intersection for the ray.
        hit_record = RayTracer.hit(objects, scattered_ray, 0.001, maxintfloat(Float64))

        if hit_record !== no_hit
            # Color using the hit object's materials
            is_scattered, attenuation = scatter!(scattered_ray, hit_record.material, hit_record)
            emitted = emission(hit_record.material, hit_record)
            
            if !is_scattered
                # The hit object absorbed this ray. E.g. a light source, or the very edge of a sphere
                return emitted
            end
            # Otherwise update the light color ready to bounce again
            output_attenuation = emitted + output_attenuation .* attenuation
        else
            # Missed all objects; sample the background for this Ray
            return output_attenuation .* background(scattered_ray)
        end
    end
    # After MAX_BOUNCES which all hit objects we return black (no more light is gathered)
    return zeros(Vec)
end





"""

"""
function raytrace(; output_properties::OutputProperties, camera::Camera, scene::Vector, render_properties::RenderProperties)
    num_samples = render_properties.samples
    width, height = output_properties.width, output_properties.height
    # Preallocate output image array
    pixel_data::Array{Float64, 3} = zeros(Float64, 3, height, width)

    @simd for row in height:-1:1
        @simd for col in 1:width
            pixel = [0.0, 0.0, 0.0]

            @simd for sample in 1:num_samples
                u = (rand() + col)/width
                v = (rand() + row)/height

                ray = RayTracer.get_ray(camera, u, v)
                @inbounds pixel += clamp.(color(ray, scene, background=default_bg, max_bounces=render_properties.max_bounces), 0.0, 1.0)
            end
            @inbounds pixel_data[:, row, col] = pixel/num_samples
        end
    end

    img_CHW::Array{Float64, 3} = pixel_data
    return reverse(sqrt.(img_CHW), dims=2)
end


end # module
