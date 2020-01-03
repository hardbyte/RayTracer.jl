import Base.iterate

"""
A Box in 3D space.

We build it out of 6 quads.

Currently no optimization for computing the Ray intersection. 
"""
struct Box{V, R} <: CompositeObject
    #origin::Vec
    faces::SVector{6, Quad}

    material::Material
end


function Box(origin::V, width::V, height::V, depth::V, material::Material) where {V <: AbstractVector{<:Real}}
    # Create the six faces of the Box
    front = Quad(origin, height, width, material)
    back = Quad(origin+depth, height, width, material)

    left = Quad(origin, depth, height, material)
    right = Quad(origin+width, depth, height, material)

    top = Quad(origin+height, width, depth, material)
    bottom = Quad(origin, width, depth, material)

    faces = SVector{6, Quad}(front, back, left, right, top, bottom)
    return Box{Vec, Float64}(faces, material)
end

function Base.iterate(S::Box, state=1)
    if state < 7
        return (S.faces[state], state+1)
    end
end
Base.eltype(::Type{Box}) = Quad
Base.length(S::Box) = 6
