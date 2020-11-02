import Base: +, in

"""
    AABB(min::Vec, max::Vec)

Axis Aligned Bounding Box


"""
struct AABB <: Object
    minimum::Vec
    maximum::Vec
end

function compare_bounding_boxes(a::AABB, b::AABB, axis::Int)
    return a.minimum[axis] < b.minimum[axis]
end

center(bb::AABB) = (bb.minimum + bb.maximum)/2

function in(ray::Ray, aabb::AABB, t_min::Float64 = 0.001, t_max::Float64 = maxintfloat(Float64))
    for a in 1:3
        inverse_direction = 1.0 / ray.direction[a]
        t0 = (aabb.minimum[a] - ray.origin[a]) * inverse_direction
        t1 = (aabb.maximum[a] - ray.origin[a]) * inverse_direction

        if inverse_direction < 0.0
            t1, t0 = t0, t1
        end
        t_min = t0 > t_min ? t0 : t_min
        t_max = t1 < t_max ? t1 : t_max
        if t_max <= t_min
            return false
        end
    end
    return true
end


"""
Create an axis aligned bounding box from a list of points.
"""
function bounding_box(points::Vector{Vec})
    xs = sort([pt[1] for pt in points])
    ys = sort([pt[2] for pt in points])
    zs = sort([pt[3] for pt in points])

    small = MutableVec(
        xs[1],
        ys[1],
        zs[1]
    )
    big = MutableVec(
        xs[end],
        ys[end],
        zs[end]
    )
    AABB(small, big)
end

"""
Surround two bounding boxes

"""
function +(box0::AABB, box1::AABB)
    small = Vec(
        min(box0.minimum[1], box1.minimum[1]),
        min(box0.minimum[2], box1.minimum[2]),
        min(box0.minimum[3], box1.minimum[3])
    )

    big = Vec(
        max(box0.maximum[1], box1.maximum[1]),
        max(box0.maximum[2], box1.maximum[2]),
        max(box0.maximum[3], box1.maximum[3])
    )

    AABB(small, big)
end
