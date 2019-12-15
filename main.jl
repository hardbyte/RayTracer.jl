using ColorTypes
using Images
import RayTracer


img_data = rand(RGB{Float64}, 100, 200)

RayTracer.output_ppm(img_data)



