import pycuda.driver as drv
import pycuda.autoinit
import pycuda.gpuarray as gpuarray
import numpy
import time

n = 10
h_a = numpy.float32(numpy.random.randint(1,5,(n,n)))
h_b = numpy.float32(numpy.random.randint(1,5,(n,n)))

tic = time.time()
axb = h_a * h_b

toc = time.time() - tic
print("Dot Product on CPU")
print(toc , "s")

start = drv.Event()
end = drv.Event()

start.record()

a_gpu = gpuarray.to_gpu(h_a)
b_gpu = gpuarray.to_gpu(h_b)

multiplygpu = gpuarray.dot(a_gpu , b_gpu)

end.record()
end.synchronize()

secs = start.time_till(end) * 1e-3

print("%fs" % (secs))

if(numpy.sum(axb) == multiplygpu.get()):
    print("The computed dor product is correct")