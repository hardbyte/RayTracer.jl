
"""
    Camera - The render viewpoint.

Camera(lookfrom::Vector{Float64}, lookat::Vector{Float64}, vup::Vector{Float64},
        vfov::Float64, aspect::Float64, aperture::Float64)

Internally we keep w,u,v which form the orthonormal basis of the camera's
coordinate system, where:
    - v points along the camera's vertical axis
    - u points along the camera's horizontal axis
    - w points at the viewer (not the scene)
"""
struct Camera
    lower_left_corner::Vec
    horizontal::Vec
    vertical::Vec
    origin::Vec

    aperture::Float64

    # Orthonormal Basis of Camera
    v::Vec
    u::Vec
    w::Vec

end


function Camera(;lookfrom::Vector{Float64}, lookat::Vector{Float64}, vup::Vector{Float64},
                vfov::Float64, aspect::Float64, aperture::Float64)
    return Camera(
        lookfrom=Vec(lookfrom),
        lookat=Vec(lookat),
        vup=Vec(vup),
        vfov=vfov,
        aspect=aspect,
        aperture=aperture
    )
end

function Camera(;lookfrom::Vec, lookat::Vec, vup::Vec,
                vfov::Float64, aspect::Float64, aperture::Float64)
    theta = vfov*π/180.0
    half_height = tan(theta/2)
    half_width = aspect * half_height
    origin = lookfrom
    w = unit_vector(lookfrom - lookat)
    u = unit_vector(cross(vup, w))
    v = cross(w, u)

    # focus distance could be a parameter, but we assume the camera
    # is focused on point "lookat"
    focus_distance = norm(lookfrom - lookat)

    lower_left_corner = origin -
                        half_width * focus_distance * u -
                        half_height * focus_distance * v -
                        focus_distance * w
    horizontal = 2half_width  * focus_distance * u
    vertical = 2half_height * focus_distance * v

    return Camera(lower_left_corner, horizontal, vertical, origin, aperture, v, u, w)
end

function get_ray(camera::Camera, s::Float64, t::Float64)::Ray
    lens_radius = camera.aperture/2
    rd = lens_radius * random_point_in_unit_disk()
    @inbounds offset = camera.u * rd[1] + camera.v * rd[2]

    return Ray(camera.origin + offset,
               camera.lower_left_corner + s*camera.horizontal + t*camera.vertical
               - camera.origin - offset)
end
