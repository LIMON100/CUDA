#include<stdio.h>

#define NUM_THREAD 1000000;
#define BLOCK_WIDTH 1000;

#define ARRAY_SIZE 10;


__global__ void incrmnt_nve(int *g){

  int i = blockIdx.x * blockDim.x + threadIdx.x;

  i = i % ARRAY_SIZE;
  g[i] = g[i] + 1;
}


__global__ void incrmnt_atomic(int *g){

  int i = threadIdx.x + blockIdx.x * blockDim.x;

  i = i % ARRAY_SIZE;
  atomicAdd(& g[i] , i);
}


int main(int argc , char **argv){

  int h_array[ARRAY_SIZE];
  const int ARRAY_BYTES = ARRAY_SIZE * sizeof(int);

  int *d_array;
  cudaMalloc((void **) &d_array , ARRAY_BYTES);
  cudaMemset((void *) d_array , 0 , ARRAY_BYTES);

  incrmnt_atomic<<< NUM_THREAD / BLOCK_WIDTH , BLOCK_WIDTH >>>(d_array);

  cudaMemcpy(h_array , d_array , ARRAY_BYTES , cudaMemcpyDeviceToHost);

  cudaFree(d_array);

  return 0;
}
