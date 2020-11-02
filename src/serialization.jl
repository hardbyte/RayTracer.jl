using StaticArrays
import Base

const RawSTLPoint = SVector{3, Float32}


struct RawSTLTrig
    normal::RawSTLPoint
    p1::RawSTLPoint
    p2::RawSTLPoint
    p3::RawSTLPoint
    ignored::UInt16

end


function Base.read(s::IO, ::Type{RawSTLTrig})
    normal = ltoh.(read(s, RawSTLPoint))
    p1 = ltoh.(read(s, RawSTLPoint))
    p2 = ltoh.(read(s, RawSTLPoint))
    p3 = ltoh.(read(s, RawSTLPoint))
    ignored = read(s, UInt16)

    RawSTLTrig(normal, p1,p2,p3, ignored)
end

Base.zero(::Type{RayTracer.RawSTLTrig}) = RawSTLTrig(
    zero(RawSTLPoint), 
    zero(RawSTLPoint), 
    zero(RawSTLPoint), 
    zero(RawSTLPoint), 
    zero(UInt16)
)


function output_as_ppm(data::AbstractArray{RGB{Float64}, 2}, fname="out.ppm")
    rows, columns = size(data)
    @info "Writing data as ppm"
    @info "Input dimensions: $(size(data))"
    open(fname, "w") do f
        write(f, "P3\n")
        write(f, "$columns $rows\n")
        write(f, "255\n")
        for row in rows:-1:1
            for column in 1:columns
                r, g, b = map(to_uint, sqrt.(color_to_vector(data[row, column])))
                write(f, "$r $g $b\n")
            end
        end
    end
end

function load_trig_mesh_from_stl(filename::AbstractString)
    open(filename) do f
        return load_trig_mesh_from_stl(f)
    end
end


"""
load_trig_mesh_from_stl

Note STL files don't include material information, we return 
a Vector of RawSTLTrig instances.

Usage assuming:

mesh = RayTracer.load_trig_mesh_from_stl("teapot.stl")
trigs = Vector{RayTracer.Triangle}()
mat = RayTracer.NormalMaterial()
for t in mesh
    push!(trigs, RayTracer.Triangle(t.p1, t.p2, t.p3, mat))
end
"""
function load_trig_mesh_from_stl(file::IOStream)
    HEADER_LENGTH = 80
    ignored_header = read(file, HEADER_LENGTH)
    
    number_of_trigs = ltoh(read(file, UInt32))

    @show Int64(number_of_trigs)
    mesh_data = zeros(RawSTLTrig, number_of_trigs)
    
    raw_data = Vector{UInt8}(undef, 50)
    
    for i in 1:number_of_trigs
        # Read the current triangle's data
        current_trig_data = read(file, RawSTLTrig)
        mesh_data[i] = current_trig_data
    end
    
    #mesh_data = copy(reinterpret(RawSTLTrig, raw_data))

    # current_trig_data = Ref{RawSTLTrig}()
    # for i in 1:number_of_trigs
    #     # twelve 32-bit floating-point numbers: three for the normal and then three for the X/Y/Z coordinate of each vertex
    #     # two bytes which are ignored "attribute byte count"
        
    #     @show current_trig_data[]
    #     @assert current_trig_data[].ignored == UInt16(0)

    #     mesh_data[i] = current_trig_data[]
    # end
    mesh_data
end

