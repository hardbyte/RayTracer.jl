import Base.iterate

"""
A Quad is a rectangle in 3D space.

Note it is directional - the normal follows the right hand rule.
"""
struct Quad{V, R} <: CompositeObject
    # Bottom left
    t1::Triangle{V, R}
    t2::Triangle{V, R}

    material::Material
end


function Quad(origin::V, width::V, height::V, material::Material) where {V <: AbstractVector{<:Real}}
    # Top left
    t1 = Triangle(
        origin,
        origin + height + width,
        origin + height,
        material
    )

    # Bottom right
    t2 = Triangle(
        origin,
        origin + width,
        origin + height + width,
        material
    )
    return Quad(t1, t2, material)
end

function Base.iterate(S::Quad, state=1)
    if state == 1
        return (S.t1, 2)
    elseif state == 2
        return (S.t2, 3)
    else
        return nothing
    end
end
Base.eltype(::Type{Quad}) = Triangle
Base.length(S::Quad) = 2
