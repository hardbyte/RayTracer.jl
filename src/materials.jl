export Material, ArbitraryMaterial, DiffuseMaterial, scatter
import Base: show

"""
    Material
Abstract base for all materials.
"""
abstract type Material end


"""
    ArbitraryMaterial

A simplified version of https://github.com/avik-pal/RayTracer.jl/blob/master/src/materials.jl

    Contains all the required fields for each sub material so we have constant
    memory requirements for a material.
"""
struct ArbitraryMaterial <: Material
    # Color Information
    color_ambient::Vector{Float64}
    color_diffuse::Vector{Float64}
    color_specular::Vector{Float64}

    # Surface Properties
    specular_exponent::Float64
    reflection::Vector{Float64}

end

# Default constructor gives an ArbitraryMaterial
Material(;color_ambient = ones(3), color_diffuse = ones(3),
          color_specular = ones(3), specular_exponent::Float64 = 50.0,
          reflection::Vector{Float64}=0.2*ones(3)) =
    ArbitraryMaterial(
        color_ambient,
        color_diffuse,
        color_specular,
        specular_exponent,
        reflection)

function Base.zero(m::Material)
    return Material(zero(m.color_ambient), zero(m.color_diffuse), zero(m.color_specular),
                    zero(m.specular_exponent), zero(m.reflection))
end

show(io::IO, m::ArbitraryMaterial) =
    print(io, "ArbitraryMaterial",
          "\n Color Properties:",
          "\n    Ambiant - ", m.color_ambient,
          "\n    Diffuse - ", m.color_diffuse,
          "\n    Specular - ", m.color_specular,
          "\n Surface Properties:",
          "\n    Specular - ", m.specular_exponent,
          "\n    Reflection - ", m.reflection
          )


"""
    DiffuseMaterial


"""
struct DiffuseMaterial <: Material
    # All we use is color information or albedo
    color_diffuse::Vec
end

DiffuseMaterial(;color_diffuse::AbstractVector{<:Real} = ones(Vec)) = DiffuseMaterial(Vec(color_diffuse))

show(io::IO, m::DiffuseMaterial) = print(io, "DiffuseMaterial", "\n    Color - ", m.color_diffuse )



"""
    MetalMaterial(reflection:Vec, fuzz)

A shiny colored material. Fuzz controls how dull or shiny it is.
0.0 is very shiny, 1.0 is very dull
"""
struct MetalMaterial <: Material
    # Color Information
    reflection::Vec

    # Surface Properties
    fuzz::Float64
end

function MetalMaterial(;reflection::AbstractVector{<:Real}, fuzz::R) where {R <: Real}
    return MetalMaterial(Vec(color_diffuse), Float64(fuzz))
end


show(io::IO, m::MetalMaterial) =
    print(io, "MetalMaterial",
          "\n    Reflection - ", m.reflection,
          "\n    Fuzziness - ", m.fuzz,
          )



struct DielectricMaterial <: Material
    color::Vector{Float64}

    # Surface Properties
    refraction_index::Float64
    #specular_exponent::

end
DielectricMaterial(refraction_index::Float64) = DielectricMaterial(ones(Vec), refraction_index)
show(io::IO, m::DielectricMaterial) = print(io, "DielectricMaterial", "\n    Refraction Index - ", m.refraction_index )



struct NormalMaterial <: Material
end




struct EmitterMaterial <: Material
    intensity::Float64
    color::Vec
end

EmitterMaterial(color::AbstractVector{<:Real} = ones(Vec), ) = EmitterMaterial(intensity=1.0, color=Vec(color))
EmitterMaterial(;intensity::Float64, color::AbstractVector{<:Real} = ones(Vec), ) = EmitterMaterial(intensity, Vec(color))
show(io::IO, m::EmitterMaterial) = print(io, "EmitterMaterial", "\n    Color - ", m.color, "    Intensity - ", m.intensity )
