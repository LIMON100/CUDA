#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include <math.h>


#define SIZE 256
#define SHMEM_SIZE 256 * 4


__global__ void sum_reduction(int* v, int* v_r) {

	__shared__ int partial_sum[SHMEM_SIZE];

	int tid = blockIdx.x * blockDim.x + threadIdx.x;

	int i = blockIdx.x * (blockDim.x * 2) + threadIdx.x;

	partial_sum[threadIdx.x] = v[i] + v[i + blockDim.x];

	__syncthreads();

	for (int s = blockDim.x / 2; s > 0; s >>= 1) {
		if (threadIdx.x < s) {
			partial_sum[threadIdx.x] += partial_sum[threadIdx.x + s];
		}
		__syncthreads();
	}

	if (threadIdx.x == 0) {
		v_r[blockIdx.x] = partial_sum[0];
	}
}

void initialize_vector(int* v, int n) {
	for (int i = 0; i < n; i++) {
		v[i] = 1;
	}
}


int main() {

	int n = 1 << 16;
	size_t bytes = n * sizeof(int);

	int* h_v, * h_v_r;
	int* d_v, * d_v_r;

	h_v = (int*)malloc(bytes);
	h_v_r = (int*)malloc(bytes);

	cudaMalloc(&d_v, bytes);
	cudaMalloc(&d_v_r, bytes);

	initialize_vector(h_v, n);

	cudaMemcpy(d_v, h_v, bytes, cudaMemcpyHostToDevice);

	int TB_SIZE = SIZE;

	int GRID_SIZE = n / TB_SIZE / 2;

	sum_reduction << <GRID_SIZE, TB_SIZE >> > (d_v, d_v_r);

	sum_reduction << <1, TB_SIZE >> > (d_v_r, d_v_r);

	cudaMemcpy(h_v_r, d_v_r, bytes, cudaMemcpyDeviceToHost);

	assert(h_v_r[0] == 65536);

	printf("COMPLETED SUCCESSFULLY\n");
	printf("Reduced thread works.");

	return 0;
}