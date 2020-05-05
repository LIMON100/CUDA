import pycuda.autoinit
import pycuda.driver as drv
from pycuda.compiler import SourceModule
import numpy as np
import time
import math

N = 10000000

mod = SourceModule("""
                   
__global__ void suml(float *d_result, float *d_a, float *d_b,int N)
{
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    
    while(tid < N){
    
        d_result[tid] = d_a[tid] + d_b[tid];
        tid = tid + blockDim.x * gridDim.x;
    
    }

}


""")


start = drv.Event()
end = drv.Event()

add_num = mod.get_function('suml')

h_a = np.random.randn(N).astype('float32')
h_b = np.random.randn(N).astype('float32')

h_result = np.zeros_like(h_a)
h_result1 = np.zeros_like(h_a)

n_blocks = math.ceil((N/1024) + 1)

start.record()

add_num(drv.In(h_result) , drv.Out(h_a) , drv.Out(h_b) , np.uint32(N) , block = (1024, 1, 1) , grid = (n_blocks , 1))

end.record()
end.synchronize()

secs = start.time_till(end)*1e-3

print("Addition of %d element of GPU"%N)
print("%fs" % (secs))
start = time.time()

for i in range(0 , N):
    h_result1[i] = h_a[i] +h_b[i]
    
end = time.time()
print("Addition of %d element of CPU"%N)
print(end-start,"s")