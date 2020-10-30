using ColorTypes
using Images
using Profile
import LinearAlgebra: norm, dot

# We use image data H,W,C
# https://juliaimages.org/latest/quickstart/

using RayTracer

import Base.zero
zero(::Type{RGB{Float64}}) = RGB{Float64}(0,0,0)


function ray_trace_sphere_objects()
    # A test scene
    height, width = 1080, 1920
    samples, max_bounces = 64, 50

    red_diffuse_material = RayTracer.DiffuseMaterial([0.7, 0.3, 0.3])
    blue_diffuse_material = RayTracer.DiffuseMaterial([0.3, 0.3, 0.8])
    dielectric_material = RayTracer.DielectricMaterial(1.5)
    blue_metalic_material = RayTracer.MetalMaterial([0.8, 0.8, 0.95], 0.7)
    yellow_metalic_material = RayTracer.MetalMaterial([0.8, 0.6, 0.2], 0.2)

    scene_objects = [
        RayTracer.Sphere([0.0, -601, -1.0], 600.0, RayTracer.DiffuseMaterial([0.6,0.8,0.2])),

        RayTracer.Sphere([-1.4, -0.5, -3.0], 1, blue_diffuse_material),

        # bubble
        RayTracer.Sphere([0.6, -0.3, -2.0], 0.5, dielectric_material),
        RayTracer.Sphere([0.6, -0.3, -2.0], -0.46, dielectric_material),

        RayTracer.Sphere([1.8, 0.0, -1.6], 0.2, dielectric_material),
        RayTracer.Sphere([1.5, 0.0, -4.0], 1.5, yellow_metalic_material),
        RayTracer.Sphere([2.5, -1.0, -2.5], 0.5, red_diffuse_material),
        RayTracer.Sphere([2.8, 0.0, -2.0], 0.5, blue_metalic_material),

        RayTracer.Triangle(
            RayTracer.Vec([-0.4, 0.0, -3.0]),
            RayTracer.Vec([-0.4, 1.0, -3.0]),
            RayTracer.Vec([0.3, 0.3, -2.0]),
            blue_diffuse_material
        ),

        RayTracer.Triangle(
            RayTracer.Vec([-0.4, 1.0, -3.0]),
            RayTracer.Vec([0.6, 1.0, -3.5]),
            RayTracer.Vec([0.3, 0.3, -2.0]),
            red_diffuse_material
        ),

        RayTracer.Box(
            [2.5, 0.7, -2.5],
            [1.8, 0.0, 0.0],
            [0.0, 0.3, 0.0],
            [0.0, 0.0, -0.5],
            blue_diffuse_material
        )

    ]

    camera = RayTracer.Camera(
        lookfrom=RayTracer.Vec(-0.5, 0.0, 2.0),
        lookat=RayTracer.Vec(1.2, 0.3, -4.0),
        vup=RayTracer.Vec(0.0, 1.0, 0.0),
        vfov=45.0,
        aspect=width/height,
        aperture=1.0/16.0 # Use 0.0 for a perfect pinhole
    )
    
    render_properties = RayTracer.RenderProperties(samples, max_bounces)
    output_properties = RayTracer.OutputProperties(width, height)

    RayTracer.raytrace(output_properties=output_properties, camera=camera, scene=scene_objects, render_properties=render_properties)
end


function ray_trace_mit_course(;samples=64, max_bounces=50)
    # One of the scenes from the tutorial
    height, width = 1080, 1920

    # billard radius
    
    

    for i in 1:10
        # Random location in front of camera
        l = [0.0, 0.0, -10.0] + 8.0 .* RayTracer.random_point_in_unit_sphere()
        m = RayTracer.MetalMaterial([rand()/2, 0.3, 0.6], rand())
        
        push!(scene_objects, RayTracer.Sphere(l, 0.2, m),)
    end


    render_properties = RayTracer.RenderProperties(samples, max_bounces)
    output_properties = RayTracer.OutputProperties(width, height)

    camera = RayTracer.Camera(
        lookfrom=RayTracer.Vec(-0.5, 2.0, 2.0),
        lookat=RayTracer.Vec(0.2, 0.5, -2.0),
        vup=RayTracer.Vec(0.0, 1.0, 0.0),
        vfov=45.0,
        aspect=width/height,
        aperture=1.0/16.0 # Use 0.0 for a perfect pinhole
    )
    
    RayTracer.raytrace(output_properties=output_properties, camera=camera, scene=scene_objects, render_properties=render_properties)
end


function ray_trace_stl_teapot(;samples=8, max_bounces=4)
    mesh = RayTracer.load_trig_mesh_from_stl("teapot.stl")
    trigs = Vector{RayTracer.Object}()
    push!(trigs, RayTracer.Sphere([-1.0, 0, -1], 1, RayTracer.MetalMaterial([0.7, 0.2, 0.2], 0.1)))
    mat = RayTracer.NormalMaterial()
    for t in mesh
        push!(trigs, RayTracer.Triangle(t.p1, t.p2, t.p3, mat))
    end

    height, width = 320, 320

    render_properties = RayTracer.RenderProperties(samples, max_bounces)
    output_properties = RayTracer.OutputProperties(width, height)

    camera = RayTracer.Camera(
        lookfrom=RayTracer.Vec(-0.5, 2.0, 20.0),
        lookat=RayTracer.Vec(0.0, 0.0, 0.0),
        vup=RayTracer.Vec(0.0, 1.0, 0.0),
        vfov=45.0,
        aspect=width/height,
        aperture=1.0/16.0 # Use 0.0 for a perfect pinhole
    )
    @info "Starting raytracing."
    RayTracer.raytrace(output_properties=output_properties, camera=camera, scene=trigs, render_properties=render_properties)

end

@info "Rendering scene"
#@time img_data = ray_trace_sphere_objects()
#@time img_data = ray_trace_mit_course()
ray_trace_stl_teapot()
@info "Rendering complete"

@show typeof(img_data)
@show size(img_data)


# For rendering we use Image data as an RGB array.
# Note our 3 dim matrix use channel-height-width order
# Use colorview to convert to RGB image
rgb_img = colorview(RGB, img_data)

save("out.jpg", rgb_img)
@show typeof(rgb_img)
@show size(rgb_img)


# Flip the Y axis for showing with ImageView
#image = reverse(rgb_img, dims=1)

# To bring up a GUI
# using ImageView
#imshow(image)

# Save output/s
##RayTracer.output_as_ppm(rgb_img)

#image;
