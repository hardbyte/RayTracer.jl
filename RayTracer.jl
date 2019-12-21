module RayTracer
using ColorTypes

to_uint = x -> UInt8(round(x * 255))
color_to_vector = c::RGB -> [red(c), green(c), blue(c)]

function output_as_ppm(data::Array{RGB{Float64}, 2}, fname="out.ppm")
    rows, columns = size(data)
    println("Writing data as ppm")
    println("Input dimensions: $(size(data))")
    open(fname, "w") do f
        write(f, "P3\n")
        write(f, "$columns $rows\n")
        write(f, "255\n")
        for row in 1:rows
            for column in 1:columns
                r, g, b = map(to_uint, color_to_vector(data[row, column]))
                write(f, "$r $g $b\n")
            end
        end
    end
end
end # module
