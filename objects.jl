
"""
    Object
All primitive objects must be a subtype of this. Currently there is just the
[`Sphere`](@ref) object.
To add support for other primitive types define a [`hit`](@ref) method.
"""
abstract type Object end

include("objects/sphere.jl")
include("objects/triangle.jl")
include("objects/composite.jl")
include("objects/quad.jl")
include("objects/box.jl")
