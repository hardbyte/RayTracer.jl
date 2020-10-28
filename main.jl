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
    # My own test scene
    height, width = 1080, 1920

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

    RayTracer.raytrace(height=height, width=width, camera=camera, scene=scene_objects, num_samples=64)
end

function ray_trace_tutorial()
    # One of the scenes from the tutorial
    height, width = 1080, 1920

    scene_objects = [
        RayTracer.Sphere([0, 0, -1], 0.5, RayTracer.DiffuseMaterial([0.1,0.2,0.5])),
        RayTracer.Sphere([0, -100.5, -1], 100, RayTracer.DiffuseMaterial([0.8,0.8,0.0])),
        RayTracer.Sphere([1,0,-1], 0.5, RayTracer.MetalMaterial([0.8,0.6,0.2], 0.3)),
        RayTracer.Sphere([-1,0,-1], 0.5, RayTracer.DielectricMaterial(1.5)),
        # note that if you use a negative radius, the geometry is unaffected but
        # the surface normal points inward, so it can be used as a bubble to make
        # a hollow glass sphere
        RayTracer.Sphere([-1,0,-1], -0.45, RayTracer.DielectricMaterial(1.5)),
    ]

    RayTracer.raytrace(height=height, width=width, camera_angle=90.0, scene=scene_objects, num_samples=32)
end


function ray_trace_mit_course(;samples=64, max_bounces=50)
    # One of the scenes from the tutorial
    height, width = 1080, 1920

    # billard radius
    r = 0.3
    scene_objects = [
        # Closest billards
        RayTracer.Sphere([-1.0, r, -1], r, RayTracer.MetalMaterial([0.7, 0.2, 0.2], 0.1)),
        RayTracer.Sphere([ 0.0, r, -1], r, RayTracer.DielectricMaterial([0.95, 0.75, 0.35], 1.5)),
        RayTracer.Sphere([ 1.0, r, -1], r, RayTracer.DiffuseMaterial([0.25, 0.2, 0.8])),
        
        # Second layer
        RayTracer.Sphere([-0.5, r, -2], r, RayTracer.DielectricMaterial(1.5)),
        RayTracer.Sphere([ 0.5, r, -2], r, RayTracer.NormalMaterial()),
        
        # Back billard
        RayTracer.Sphere([ 0.0, r, -3], r, RayTracer.MetalMaterial([0.25, 0.2, 0.8], 0.2)),

        # back wall
        #RayTracer.Quad([-10.0, -5.0, -10.0], [40.0, 0, 0], [0, 20.0, 0], RayTracer.DiffuseMaterial([0.75, 0.76, 0.74])),
        # dark floor
        RayTracer.Quad([-10.0, -5.0, 2.0], [40.0, 0, 0], [0, 0.0, -20], RayTracer.DiffuseMaterial([0.35, 0.256, 0.23])),
       
        # Might as well lay down a table
        #RayTracer.Quad([3, -0.05, -0.5], [-5.0, 0, 0], [0, 0, -5.0], RayTracer.DiffuseMaterial([0.15, 0.45, 0.1])),
        RayTracer.Quad([-2, -0.05, -5], [5.0, 0, 0], [0, 0, 5.0], RayTracer.DiffuseMaterial(0.5 .* [0.15, 0.45, 0.1])),
        
        # Surrounding sphere for background
        # note that if you use a negative radius, the geometry is unaffected, but the surface normal points inward
        #RayTracer.Sphere([ 0.0, 0.0, 0.0], -10000, RayTracer.NormalMaterial()),
        
        # A bright rectangular light off to the left of the scene e.g. a window
        RayTracer.Quad(
            [-15.0, -2.0, -1.0],
            [0.0, 10.0, 0.0],
            [0.0, 0.0, -10.0],
            RayTracer.EmitterMaterial(5.0, [1.0, 0.9, 0.9])
            ),

        # Sun light source
        RayTracer.Sphere([ 1000.0, 500.0, -10.0], 100, RayTracer.EmitterMaterial(100.0, [4.0, 4.0, 3.8])),
    ]

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


@info "Rendering scene"
#@time img_data = ray_trace_sphere_objects()
@time img_data = ray_trace_mit_course()
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
