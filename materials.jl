export Material, ArbitraryMaterial, DiffuseMaterial

"""
    Material
Abstract base for all materials.
"""
abstract type Material end


"""
    DiffuseMaterial

A simplified version of https://github.com/avik-pal/RayTracer.jl/blob/master/src/materials.jl

"""
struct DiffuseMaterial <: Material
    # Color Information
    color_diffuse::Vector{Float64}

    # Surface Properties
    #specular_exponent::Float64
    #reflection::Float64
end

DiffuseMaterial(;color_diffuse = ones(3)) = DiffuseMaterial(color_diffuse)

show(io::IO, m::DiffuseMaterial) =
    print(io, "DiffuseMaterial",
          "\n    Color - ", m.color_diffuse,
          #"\n    Specular - ", m.specular_exponent,
          #"\n    Reflection - ", m.reflection
          )


struct MetalMaterial <: Material
    # Color Information
    reflection::Vector{Float64}

    #color_diffuse::Vector{Float64}

    # Surface Properties
    fuzz::Float64
    #specular_exponent::

end

show(io::IO, m::MetalMaterial) =
    print(io, "MetalMaterial",
          "\n    Reflection - ", m.reflection,
          "\n    Fuzziness - ", m.fuzz,
          )

struct DielectricMaterial <: Material
    # Color Information
    #reflection::Vector{Float64}

    # Surface Properties
    refraction_index::Float64
    #specular_exponent::

end

show(io::IO, m::DielectricMaterial) = print(io, "DielectricMaterial", "\n    Refraction Index - ", m.refraction_index )


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
