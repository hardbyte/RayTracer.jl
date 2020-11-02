import Base: in

"""
    Object
All primitive objects must be a subtype of this. 

To add support for other primitive types define a [`hit`](@ref) method.
"""
abstract type Object end

in(ray::Ray, obj::Object) = hit(obj, ray, 0.001, maxintfloat(Float64)) !== no_hit

include("objects/sphere.jl")
include("objects/triangle.jl")
include("objects/composite.jl")
include("objects/quad.jl")
include("objects/box.jl")
