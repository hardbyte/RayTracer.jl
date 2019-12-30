
"""
    Camera

The render viewpoint.

    Camera(lookfrom::Vector{Float64}, lookat::Vector{Float64}, vup::Vector{Float64}, vfov::Float64, aspect::Float64)

"""
struct Camera
    lower_left_corner::Vector{Float64}
    horizontal::Vector{Float64}
    vertical::Vector{Float64}
    origin::Vector{Float64}
    #view_up::Vector{Float64}
end


function Camera(lookfrom::Vector{Float64}, lookat::Vector{Float64}, vup::Vector{Float64}, vfov::Float64, aspect::Float64)
    theta = vfov*π/180.0
    half_height = tan(theta/2)
    half_width = aspect * half_height

    """
    w,u,v form the orthonormal basis of the camera's coordinate system,
    Where:
        - w points at the viewer (not the scene)
        - u points along the camera's horizontal axis
        - v points along the camera's vertical axis
    """

    origin = lookfrom
    w = unit_vector(lookfrom - lookat)
    u = unit_vector(cross(vup, w))
    v = cross(w, u)

    lower_left_corner = origin - half_width*u - half_height*v - w
    horizontal = 2half_width*u
    vertical = 2half_height*v

    return Camera(lower_left_corner, horizontal, vertical, origin)
end

function get_ray(camera::Camera, u::Float64, v::Float64)::Ray
    return Ray(camera.origin,
               camera.lower_left_corner + u*camera.horizontal + v*camera.vertical - camera.origin)
end
