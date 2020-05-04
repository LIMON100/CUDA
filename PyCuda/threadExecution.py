import pycuda.driver as cuda
import pycuda.autoinit
from pycuda.compiler import SourceModule

mod = SourceModule("""
                   
    #include<stdio.h>
    
    __global__ void my_kernel()
    {
         printf("I am in block %d \\n" , blockIdx.x);
    }


""")


function = mod.get_function("my_kernel")
function(grid = (10 , 1) , block = (1 , 1, 1))