#include<stdio.h>
#include<stdlib.h>

__global__ void arrAdd(int *md , int *nd , int *pd , int size){

  int myid = blockIdx.x * blockDim.x + threadIdx.x;
  pd[myid] = md[myid] + nd[myid];

}


int main() {

  int size = 20 * sizeof(int);
  int m[200] , n[200] , p[200] , *md , *nd , *pd;
  int i = 0;

  for(i = 0; i < 200; i++){

    m[i] = i;
    n[i] = i;
    p[i] = 0;

  }

  cudaMalloc(&md , size);
  cudaMemcpy(md , m , size , cudaMemcpyHostToDevice);

  cudaMalloc(&nd , size);
  cudaMemcpy(nd , n , size , cudaMemcpyHostToDevice);

  cudaMalloc(&pd , size);

  dim3 DimGrid(10 , 1);
  dim3 DimBlock(200 , 1);

  arrAdd<<< DimGrid , DimBlock >>>(md , nd , pd , size);

  cudaMemcpy(p , pd , size , cudaMemcpyDeviceToHost);

  cudaFree(md);
  cudaFree(nd);
  cudaFree(pd);

  for(i = 0; i < 200; i++){
    printf("\t%s", p[i]);
  }


  return 0;
}
