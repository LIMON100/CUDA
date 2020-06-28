#include<stdio.h>

__global__ void global_reduce_kernel(float *d_out , float *d_in) {

  int myId = threadIdx.x + blockDim.x * blockIdx.x;
  int tid = threadIdx.x;

  for(unsigned int s = blockDim.x / 2; s > 0; s>>=1){
    if(tid < s){
      d_in[myId] += d_in[myId + s];
    }
    __syncthreads();
  }

  if(tid == 0){
    d_out[blockIdx.x] = d_in[myId]
  }
}


__global__ void shre_reduce_kernel(float *d_out , const float *d_in) {

  extern __shared__ float sdata[];

  int myId = threadIdx.x + blockDim.x * blockIdx.x;
  int tid = threadIdx.x;


  sdata[tid] = d_in[myId];
  __syncthreads();

  for(unsigned int s = blockDim.x / 2; s > 0; s>>=1){
    if(tid < s){
      sdata[tid] += sdata[tid + s];
    }
    __syncthreads();
  }

  if(tid == 0){
    d_out[blockIdx.x] = sdata[0];
  }
}


void reduce(float *d_out , float *d_intermediate , float *d_in , int size , bool usesSharedMemory){

  const int maxThreadPerBlock = 1024;
  int threads = maxThreadPerBlock;
  int blocks = size / maxThreadPerBlock;

  if(usesSharedMemory){
    shre_reduce_kernel<<< blocks , threads , threads * sizeof(float) >>>(d_intermediate , d_in);
  }
  else{
    global_reduce_kernel<<< blocks , threads >>>(d_intermediate , d_in);
  }

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
