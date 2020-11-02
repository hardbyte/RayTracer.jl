
"""
Bounded Volume Heirachies using axis-aligned bounding boxes.

c.f. https://raytracing.github.io/books/RayTracingTheNextWeek.html#boundingvolumehierarchies/rayintersectionwithanaabb

"""
struct BVH <: Object
    left::Object
    right::Object

    box::AABB
end

function bounding_box(obj::BVH)
    return obj.box
end

in(ray::Ray, obj::BVH, t_min::Float64 = 0.001, t_max::Float64 = maxintfloat(Float64)) = in(ray, obj.box, t_min, t_max)


"""
Split objects into BVH volumes
"""
function BVH(objects::Vector{<:Object})
    # Pick an axis at random
    axis = rand(1:3)

    #@info "Creating BVH from $(length(objects)) along axis $axis"
    
    # Get the coordinate of the objects' centers in the chosen axis
    ax_center(obj) = center(obj)[axis]
    sorted_objects = sort(objects, by=ax_center)
    
    # Create a left and right subtree and/or primitive object
    if length(objects) == 1
        return objects[1]
    elseif length(objects) > 3
        mid = length(sorted_objects) ÷ 2
        left = BVH(sorted_objects[1:mid])
        right = BVH(sorted_objects[mid:end])
    else
        left = objects[1]
        if length(objects) > 1
            right = BVH(objects[2:end])
        elseif length(objects) == 1
            # repeat left and right subtrees
            right = objects[1]
        elseif length(objects) == 0
            @info "Can't create a BVH with no objects"
        end
    end

    # Finally compute the boundary box by combining the child bounds
    box = bounding_box(left) + bounding_box(right)

    BVH(left, right, box)
end

function hit(bvh::BVH, ray::Ray, t_min::Float64, t_max::Float64)
    if !in(ray, bvh.box, t_min, t_max)
        return no_hit
    else
        # In the BVH bounds, return the closest hit from the children nodes
        return hit([bvh.left, bvh.right], ray, t_min, t_max)
    end
end


