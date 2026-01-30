using StaticArrays

to_svec(m) = [SVector{size(m,2)}(m[i,:]) for i in 1:size(m,1)]