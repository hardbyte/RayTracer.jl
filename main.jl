using ColorTypes
include("RayTracer.jl")

import Base.zero
zero(::Type{RGB{Float64}}) = RGB{Float64}(0,0,0)

#img_data = rand(RGB{Float64}, 100, 200)
#RayTracer.output_as_ppm(img_data)

function matrix_to_rgb_image(img_data::Array{Float64,3})::Array{RGB{Float64}, 2}
    rows, cols = size(img_data)
    img::Array{RGB{Float64}, 2} = zeros(RGB{Float64}, rows, cols)

end

function generate_test_image()
    rows, cols = 100, 200
    channels = 3 # RGB
    img::Array{Float64, 3} = zeros(Float64, rows, cols, channels)

    for row in rows:-1:1
        for col in 1:cols
            img[row, col, :] = [col/cols, row/rows, 0.2]
        end
    end
    return img
end

img_data = generate_test_image()
@show typeof(img_data)
rgb_img = matrix_to_rgb_image(img_data)
RayTracer.output_as_ppm(rgb_img)