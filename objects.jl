
"""
    Object
All primitive objects must be a subtype of this. Currently there is just the
[`Sphere`](@ref) object.
To add support for other primitive types, two functions need to be
defined - [`intersect`](@ref) and [`get_normal`](@ref).
"""
abstract type Object end


"""
    Sphere
Sphere is a primitive object.
### Fields:
* `center`   - Center of the Sphere in 3D world space
* `radius`   - Radius of the Sphere
* `material` - Material of the Sphere
"""
struct Sphere <: Object
    center::Vector{Float64}
    radius::Float64
    material::Material
end

show(io::IO, s::Sphere) =
    print(io, "Sphere Object:\n    Center - ", s.center, "\n    Radius - ", s.radius[],
          "\n    ", s.material)
