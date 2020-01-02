
"""
A composite object is simply made up of object primitives.

It must be iterable.
"""
abstract type CompositeObject <: Object end


function hit(object::CompositeObject, ray::Ray, t_min::Float64, t_max::Float64)
    closest_so_far = t_max
    closest_hit = no_hit
    for primitive_obj in object
        current_hit = hit(primitive_obj, ray, t_min, t_max)
        if current_hit !== no_hit
            if current_hit.t < closest_so_far
                closest_hit = current_hit
                closest_so_far = current_hit.t
            end
        end
        # Note there are also lots of non hits...
    end
    return closest_hit
end
