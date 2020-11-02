
using Test
using RayTracer

a_material = RayTracer.Material()
origin = RayTracer.Vec([0.0, 0.0, 0.0])

@testset "BVH" begin
    @testset "BVH with one object" begin
        
        bvh = RayTracer.BVH([RayTracer.Sphere([0.0, 0.0, 0.0], 1, a_material)])
    end    
    @testset "BVH with spheres" begin
        scene_objects = Vector{RayTracer.Object}()
        n = 3
        for i in 1:n
            loc = [i, i, 1.0]
            push!(scene_objects, RayTracer.Sphere(loc, 1, a_material))
        end

        bvh = RayTracer.BVH(scene_objects)
        @test bvh.box.minimum ≈ [0.0, 0.0, 0.0]
        @test bvh.box.maximum ≈ [n + 1.0, n + 1.0, 2.0]

        # Fire a ray directly at the first sphere
        r = RayTracer.Ray(origin, [1.0, 1.0, 1.0])
        
        @test r ∈ bvh
        @test r ∈ bvh.box

        hr = RayTracer.hit(bvh, r, 0.001, maxintfloat(Float64))
        @test hr != RayTracer.no_hit
        @test hr.material == a_material
        # Intercept point is along the ray
        @test hr.p == RayTracer.point_along_ray(r, hr.t)

        @test r ∈ bvh

        r2 = RayTracer.Ray(origin, [-1.0, -1.0, -1.0])
        @test r2 ∉ bvh
        
        @testset "A ray can intercept the BVH but miss all objects" begin
            r3 = RayTracer.Ray(origin, [0.0, 0.0, 1.0])
            @test r3 ∈ bvh
            @test RayTracer.hit(bvh, r3, 0.001, maxintfloat(Float64)) == RayTracer.no_hit
        end
    end    
    @testset "BVH with Spheres and Boxes" begin
        scene_objects = Vector{RayTracer.Object}()
        for i in 1:10
            loc = [i, i, 1.0]
            push!(scene_objects, RayTracer.Sphere(loc, 1, a_material))
            push!(scene_objects, RayTracer.Box(loc, [1.0, 0,0], [0.0, 1.0, 0], [0, 0, 1.0], a_material))
        end

        bvh = RayTracer.BVH(scene_objects)
    end
end

@testset "Axis Aligned Bounding Box" begin
    @testset "Already Aligned Box" begin
        box = RayTracer.Box(
            [10.0, -10, 0],
            [1.0,0,0],
            [0,1.0,0],
            [0,0,1.0],
            a_material
        )
        # The Box uses a sphere bound
        center = [10.5, -9.5, 0.5]
        bb = RayTracer.bounding_box(box)

        @test bb.minimum ≈ center .- sqrt(3)/2
        @test bb.maximum ≈ center .+ sqrt(3)/2

        intersecting_ray = RayTracer.Ray(
            [0.0, 0.0, 0.0], 
            [10.5, -9.5, 0.5]
        )
        missing_ray = RayTracer.Ray(
            [0.0, 0.0, 0.0], 
            [-10.0, 0.0, 0.0]
        )

        @test intersecting_ray ∈ bb
    end

    @testset "Bounding Spheres" begin
        sphere = RayTracer.Sphere([10, -10, 0], 1.0, a_material)
        bb = RayTracer.bounding_box(sphere)
        @test bb.minimum[1] ≈ 9
        @test bb.maximum[1] ≈ 11
        @test bb.minimum[2] ≈ -11
        @test bb.maximum[2] ≈ -9
        @test bb.minimum[3] ≈ -1
        @test bb.maximum[3] ≈ 1        
    end

    @testset "Bounding Triangles" begin
        # 90° axis aligned triangle
        trig = RayTracer.Triangle(
            [0,0,0],
            [0,1,0],
            [1,0,0],
            a_material
        )
        bb = RayTracer.bounding_box(trig)
        @test bb.minimum[1] ≈ 0
        @test bb.maximum[1] ≈ 1
        @test bb.minimum[2] ≈ 0
        @test bb.maximum[2] ≈ 1
        @test bb.minimum[3] ≈ 0
        @test bb.maximum[3] ≈ 0

        trig = RayTracer.Triangle(
            [1,0,0],
            [0,1,0],
            [0,0,1],
            a_material
        )
        bb = RayTracer.bounding_box(trig)
        @test bb.minimum[1] ≈ 0
        @test bb.maximum[1] ≈ 1
        @test bb.minimum[2] ≈ 0
        @test bb.maximum[2] ≈ 1
        @test bb.minimum[3] ≈ 0
        @test bb.maximum[3] ≈ 1
    end

    @testset "Combining Bounding Boxes" begin
        obj1 = RayTracer.Sphere([1, 1, 1], 1.0, a_material)
        obj2 = RayTracer.Sphere([5, 5, 1], 1.0, a_material)
        bb1 = RayTracer.bounding_box(obj1)
        bb2 = RayTracer.bounding_box(obj2)

        bb = bb1 + bb2
        @test bb.minimum ≈ [0.0, 0.0, 0.0]
        @test bb.maximum ≈ [6.0, 6.0, 2.0]


    end
end
