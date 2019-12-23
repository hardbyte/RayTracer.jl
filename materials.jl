export Material

"""
    Material

A simplified version of https://github.com/avik-pal/RayTracer.jl/blob/master/src/materials.jl

"""
struct Material{R<:AbstractVector}
    # Color Information
    color_ambient::Vector{Float64}
    color_diffuse::Vector{Float64}
    color_specular::Vector{Float64}

    # Surface Properties
    specular_exponent::R
    reflection::R
end

Material(;color_ambient = ones(3), color_diffuse = ones(3),
          color_specular = ones(3), specular_exponent::Real = 50.0f0,
          reflection::Real = 0.5f0) =
    Material(color_ambient, color_diffuse, color_specular, [specular_exponent],
             [reflection])

function Base.zero(m::Material)
    return Material(zero(m.color_ambient), zero(m.color_diffuse), zero(m.color_specular),
                    zero(m.specular_exponent), zero(m.reflection))
end


"""
    get_color(m::Material, pt::Vector{Float64}, ::Val{T}, obj::Object)

Returns the color at the point `pt`. We use `T` and the type of the Material `m`
for efficiently dispatching to the right function. The right function is determined
by the presence/absence of the texture field. The possible values of `T` are
`:ambient`, `:diffuse`, and `:specular`.
"""
get_color(m::Material{R}, pt::Vector{Float64}, ::Val{:ambient}, obj) where {R<:AbstractVector} =
    m.color_ambient

get_color(m::Material{R}, pt::Vector{Float64}, ::Val{:diffuse}, obj) where {R<:AbstractVector} =
    m.color_diffuse

get_color(m::Material{R}, pt::Vector{Float64}, ::Val{:specular}, obj) where {R<:AbstractVector} =
    m.color_specular


