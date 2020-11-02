import Base.iterate

"""
A Box in 3D space.

We build it out of 6 quads.

"""
struct Box{V, R} <: CompositeObject
    faces::SVector{6, Quad}
    material::Material

    # for computing the Ray intersection
    center::Vec
    radius::R
end


function Box(origin::V, width::V, height::V, depth::V, material::Material) where {V <: AbstractVector{<:Real}}
    Box(Vec(origin), Vec(width), Vec(height), Vec(depth), material)
end

function Box(origin::Vec, width::Vec, height::Vec, depth::Vec, material::Material)

    # Create the six faces of the Box
    front = Quad(origin, height, width, material)
    back = Quad(origin+depth, height, width, material)

    left = Quad(origin, depth, height, material)
    right = Quad(origin+width, depth, height, material)

    top = Quad(origin+height, width, depth, material)
    bottom = Quad(origin, width, depth, material)

    faces = SVector{6, Quad}(front, back, left, right, top, bottom)
    
    center = origin + (height + width + depth)/2
    radius = norm(origin - center)
    return Box{Vec, Float64}(faces, material, center, radius)
end

function Base.iterate(S::Box, state=1)
    if state < 7
        return (S.faces[state], state+1)
    end
end
Base.eltype(::Type{Box}) = Quad
Base.length(S::Box) = 6

function bounding_box(obj::Box)
    # Similar to bounds of a sphere
    AABB(
        obj.center - obj.radius * ones(Vec),
        obj.center + obj.radius * ones(Vec)
    )
end