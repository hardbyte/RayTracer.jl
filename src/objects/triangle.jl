

"""
    Triangle

Must be given counter-clockwise

### Fields:
* `p1`   - Triangle vertex in 3D world space
* `p2`   - Triangle vertex in 3D world space
* `p3`   - Triangle vertex in 3D world space
* `material` - Material of the object
"""
struct Triangle{V, R} <: Object
    p1::V
    p2::V
    p3::V

    normal::V


    # Not sure if precomputing these is helpful

    v1::V
    v2::V

    v1v1::R
    v1v2::R
    v2v2::R
    denom::R

    material::Material
end

function Triangle(p1::V, p2::V, p3::V, material::Material) where {V <: AbstractVector{<:Real}}
    v1 = Vec(p2-p1)
    v2 = Vec(p3-p1)
    normal = Vec(cross(v1, v2))

    v1v1 = dot(v1, v1)
    v1v2 = dot(v1, v2)
    v2v2 = dot(v2, v2)

    denom = v1v2 * v1v2 - v1v1 * v2v2

    return Triangle{Vec, Float64}(p1, p2, p3, normal, v1, v2, v1v1, v1v2, v2v2, denom, material)
end

function hit(t::Triangle, ray::Ray, t_min::Float64, t_max::Float64)
    denom = dot(t.normal, ray.direction)
    if denom == 0
        # Ray is orthogonal to triangle's plane
        return no_hit
    end
    ri = dot(t.normal, (t.p1 - ray.origin)) / denom
    if ri <= 0
        # Ray has no intersection with plane
        return no_hit
    end
    plane_intersection = ri * ray.direction + ray.origin
    w = plane_intersection - t.p1
    wv1 = dot(w, t.v1)
    wv2 = dot(w, t.v2)
    s_intersection = (t.v1v2 * wv2 - t.v2v2 * wv1) / t.denom
    if s_intersection <= 0
        return no_hit
    end
    if s_intersection >= 1
        return no_hit
    end

    t_intersection = (t.v1v2 * wv1 - t.v1v1 * wv2) / t.denom
    if t_intersection <= 0
        return no_hit
    end
    if t_intersection >= 1
        return no_hit
    end
    if s_intersection + t_intersection >= 1
        return no_hit
    end
    # intersecting point
    ip = t.p1 + s_intersection * t.v1 + t_intersection * t.v2

    return HitRecord(ri, ip, -t.normal, t.material)
end
