
"""
A composite object is simply made up of object primitives.

It must be iterable.
"""
abstract type CompositeObject <: Object end


function hit(object::CompositeObject, ray::Ray, t_min::Float64, t_max::Float64)
    closest_so_far = t_max
    closest_hit = nothing
    any_hit = false
    for primitive_obj in object
        just_hit, current_hit = hit(primitive_obj, ray, t_min, t_max)
        if just_hit
            any_hit = true
            if current_hit.t < closest_so_far
                closest_hit = current_hit
                closest_so_far = current_hit.t
            end
        end
        # Note there are also lots of non hits...
    end
    return any_hit, closest_hit
end
