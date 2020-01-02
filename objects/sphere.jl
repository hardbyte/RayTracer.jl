
"""
    Sphere
Sphere is a primitive object.
### Fields:
* `center`   - Center of the Sphere in 3D world space
* `radius`   - Radius of the Sphere
* `material` - Material of the Sphere
"""
struct Sphere <: Object
    center::Vec
    radius::Float64
    material::Material
end

function Sphere(center::T, radius::Real, material::Material) where {T<:AbstractVector{<:Real}}
    return Sphere(Vec(center), Float64(radius), material)
end

show(io::IO, s::Sphere) =
    print(io, "Sphere Object:\n    Center - ", s.center, "\n    Radius - ", s.radius[],
          "\n    ", s.material)

function hit(obj::Sphere, ray::Ray, t_min::Float64, t_max::Float64)
  oc = ray.origin - obj.center
  a = dot(ray.direction, ray.direction)
  b = dot(oc, ray.direction)
  c = dot(oc, oc) - obj.radius^2

  discriminant = b^2 - a * c

  # TODO: consider branch free logic
  if discriminant > 0
      t0 = (-b - sqrt(discriminant))/a
      t1 = (-b + sqrt(discriminant))/a

      if (t0 < t_max) && (t0 > t_min)
          t = t0
      elseif (t1 < t_max) && (t1 > t_min)
          t = t1
      else
          # Intersection occured outside of t_min and t_max
          return no_hit
      end
      p = point_along_ray(ray, t)
      return HitRecord(t, p, Vec((p - obj.center) ./ obj.radius), obj.material)

  end
  return no_hit
end
