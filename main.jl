using ColorTypes
using Images
using Profile
import LinearAlgebra: norm, dot

# We use image data H,W,C
# https://juliaimages.org/latest/quickstart/

using RayTracer

import Base
zero(::Type{RGB{Float64}}) = RGB{Float64}(0,0,0)


function ray_trace_sphere_objects()
    # A test scene
    height, width = 1080, 1920
    #samples, max_bounces = 64, 50
    samples, max_bounces = 16, 10

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
        ),

        # A bright rectangular light out of the scene e.g. a window
        RayTracer.Quad(
            [15.0, 1.0, 10.0],
            [0.0, 10.0, 0.0],
            [0.0, 0.0, -10.0],
            RayTracer.EmitterMaterial(10.0, [0.8, 0.9, 0.9])
            ),

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


function ray_trace_mit_course(;samples=32, max_bounces=64)
    height, width = 320, 480

    # billard radius
    r = 0.35

    floor_material = RayTracer.DiffuseMaterial([0.35, 0.256, 0.23])

    scene_objects = [
        # Closest billards
        RayTracer.Sphere([-1.0, r, -1], r, RayTracer.MetalMaterial([0.7, 0.1, 0.2], 0.1)),
        RayTracer.Sphere([ 0.0, r, -1], r, RayTracer.DielectricMaterial([0.95, 0.75, 0.35], 1.5)),
        RayTracer.Sphere([ 1.0, r, -1], r, RayTracer.DiffuseMaterial([0.2745, 0.5098, 0.7059])),

        # Second layer
        RayTracer.Sphere([-0.5, r, -2], r, RayTracer.DielectricMaterial(1.5)),
        RayTracer.Sphere([ 0.5, r, -2], r, RayTracer.NormalMaterial()),

        # Back billard
        RayTracer.Sphere([ 0.0, r, -3], r, RayTracer.MetalMaterial([0.25, 0.2, 0.8], 0.2)),

        # back wall
        #RayTracer.Quad([-10.0, -5.0, -10.0], [40.0, 0, 0], [0, 20.0, 0], RayTracer.DiffuseMaterial([0.75, 0.76, 0.74])),
        
        # dark floor
        RayTracer.Quad([-10.0, -5.0, 2.0], [40.0, 0, 0], [0, 0.0, -20], floor_material),

        # Might as well lay down a table
        RayTracer.Quad([3, -0.05, -0.5], [-6.0, 0, 0], [0, 0, -5.0], RayTracer.DiffuseMaterial([0.15, 0.45, 0.1])),
        
        # A bright rectangular light off to the left of the scene e.g. a window
        RayTracer.Quad(
            [-15.0, -2.0, -1.0],
            [0.0, 10.0, 0.0],
            [0.0, 0.0, -10.0],
            RayTracer.EmitterMaterial(5.0, [1.0, 0.9, 0.9])
        ),

        # Sun light source off to the upper right
        RayTracer.Sphere([20.0, 5.0, 5.0], 10, RayTracer.EmitterMaterial(100.0, [4.0, 4.0, 3.8])),
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


function ray_trace_stl_teapot(;samples=1024, max_bounces=10)
    @info "Loading trig data from STL file"
    

    function stl_to_composite(mat::RayTracer.Material, offset::RayTracer.Vec)
        mesh = RayTracer.load_trig_mesh_from_stl("teapot.stl")
        trigs = Vector{RayTracer.Object}()
        
        for t in mesh#[1:5:end]
            push!(trigs, RayTracer.Triangle(t.p1 + offset, t.p2 + offset, t.p3 + offset, mat))
        end

        return trigs
    end
    
    mat = RayTracer.DiffuseMaterial([0.94, 0.52, 0.52])
    trigs = stl_to_composite(mat, RayTracer.Vec([-1.0, 8.0, 0.1]))

    push!(trigs, RayTracer.Box(
        [-6.0, -2, 0], 
        [2.0, 0, 0],
        [0.0, 2.0, 0.0],
        [0.0, 0.0, 2.0],
        RayTracer.DiffuseMaterial([0.5, 0.65, 0.35])))

    push!(trigs, RayTracer.Sphere([ -6.0, -5, 2], 2, RayTracer.DielectricMaterial([0.95, 0.75, 0.35], 1.5)))
    push!(trigs, RayTracer.Sphere([ 6.0, 3, 2], 2, RayTracer.DielectricMaterial([0.85, 0.85, 0.987], 1.2)))
    push!(trigs, RayTracer.Sphere([ 6.0, -2, 1], 1, RayTracer.DielectricMaterial([0.88, 0.972, 0.903], 1.5)))
    push!(trigs, RayTracer.Sphere([ 2.0, -4, 1], 1, RayTracer.DielectricMaterial(1.5)))
    push!(trigs, RayTracer.Sphere([ 7.0, -4, 1], 1, RayTracer.DielectricMaterial([0.8, 0.8, 0.73], 1.5)))

    # Bottom
    push!(trigs, RayTracer.Quad(
        [-10.0, -10.0, 0.0], 
        [20.0, 0.0, 0.0],
        [0.0, 30.0, 0],
        RayTracer.DiffuseMaterial([0.48, 0.413, 0.42])
        #RayTracer.MetalMaterial([0.3, 0.3, 0.4], 0.2)
    ))

    # Left
    push!(trigs, RayTracer.Quad(
        [-10.0, -10.0, 0.0], 
        [0.0, 30.0, 0],
        [0.0, 0.0, 20.0],
        RayTracer.DiffuseMaterial([0.41, 0.7, 0.38])
    ))
    
    # Right
    push!(trigs, RayTracer.Quad(
        [10.0, 15.0, 0.0], 
        [0.0, -30.0, 0],
        [0.0, 0.0, 20.0],
        RayTracer.DiffuseMaterial([0.7, 0.3, 0.4])
    ))

    # Back
    push!(trigs, RayTracer.Quad(
        [-10.0, 15.0, 0.0], 
        [20.0, 0.0, 0],
        [0.0, 0.0, 20.0],
        RayTracer.DiffuseMaterial([0.4, 0.41, 0.45])
    ))

    # top light
    push!(trigs, RayTracer.Quad(
        [-10.0, -10.0, 20], 
        [0.0, 30.0, 0],
        [25.0, 0.0, 0.0],
        RayTracer.EmitterMaterial(0.5, [0.985, 0.7875, 0.765])))

    # Window behind the camera
    push!(trigs, RayTracer.Quad(
        [-10.0, -20.0, 0.0], 
        [20.0, 0.0, 0],
        [0.0, 0.0, 30.0],
        RayTracer.EmitterMaterial(100, [0.985, 0.85, 0.85])))


    #height, width = 1200, 1600
    height, width = 300, 400

    render_properties = RayTracer.RenderProperties(samples, max_bounces)
    output_properties = RayTracer.OutputProperties(width, height)

    camera = RayTracer.Camera(
        lookfrom=RayTracer.Vec(0.0, -18.0, 7.0),
        lookat=RayTracer.Vec(0.0, 8.0, 2.0),
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
@time img_data = ray_trace_stl_teapot()
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
