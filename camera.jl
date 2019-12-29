
struct Camera
    lower_left_corner::Vector{Float64}
    horizontal::Vector{Float64}
    vertical::Vector{Float64}
    origin::Vector{Float64}
end

function Camera(vfov::Float64, aspect::Float64)
    theta = vfov*π/180.0
    half_height = tan(theta/2)
    half_width = aspect * half_height

    lower_left_corner = [-half_width, -half_height, -1.0]
    horizontal = [2half_width, 0.0, 0.0]
    vertical = [0.0, 2half_height, 0.0]
    origin = [0.0, 0.0, 0.0]
    return Camera(lower_left_corner, horizontal, vertical, origin)
end

function get_ray(camera::Camera, u::Float64, v::Float64)::Ray
    return Ray(camera.origin,
               camera.lower_left_corner + u*camera.horizontal + v*camera.vertical - camera.origin)
end
