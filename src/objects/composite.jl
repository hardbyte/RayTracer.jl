
"""
A composite object is simply made up of object primitives.

The default implementations below assume the Composite is iterable.
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


"""
Ideally a composite object defines a more efficient
bounding box, but if not we iterate over all the inner
components expanding our bounding box primitive by primitive.
"""
function bounding_box(obj::CompositeObject)
    bb = bounding_box(first(obj))
    for primitive_obj in obj
        bb = bb + bounding_box(primitive_obj)
    end
    return bb
end

function center(obj::CompositeObject)
    bb = bounding_box(obj)
    center(bb)
end