to_uint = x -> UInt8(round(x * 255))
color_to_vector = c::RGB -> [red(c), green(c), blue(c)]

unit_vector = v::Vector -> v/norm(v)
