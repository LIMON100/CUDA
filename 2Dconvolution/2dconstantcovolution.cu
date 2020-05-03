#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <iostream>
#include <vector>
#include<cuda.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>

#define MASK_DIM 7

#define MASK_OFFSET (MASK_DIM / 2)

__constant__ int mask[7 * 7];


__global__ void con2d(int* matrix, int* result, int N) {

	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;

	int start_r = row - MASK_OFFSET;
	int start_c = col - MASK_OFFSET;

	int temp = 0;

	for (int i = 0; i < MASK_DIM; i++) {
		for (int j = 0; j < MASK_DIM; j++) {
			if ((start_r + i) >= 0 && (start_r + i) < N) {
				if ((start_c + j) >= 0 && (start_c + j) < N) {
					temp += matrix[(start_r + i) * N + (start_c + j)] * mask[i * MASK_DIM + j];
				}
			}
		}
	}

	result[row * N + col] = temp;

}


void verify_result(int* m, int* mask, int* result, int N) {

	int temp;

	int offset_r;
	int offset_c;

	for (int i = 0; i < N; i++) {
		for (int j = 0; j < N; j++) {
			temp = 0;

			for (int k = 0; k < MASK_DIM; k++) {
				offset_r = i - MASK_OFFSET + k;

				for (int l = 0; l < MASK_DIM; l++) {
					offset_c = j - MASK_OFFSET + l;

					if (offset_r >= 0 && offset_r < N) {
						if (offset_c >= 0 && offset_c < N) {
							temp += m[offset_r * N + offset_c] * mask[k * MASK_DIM + l];
						}
					}
				}
			}
			assert(result[i * N + j] == temp);
		}
	}
}



void init_matrix(int* m, int n) {
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < n; j++) {
			m[n * i + j] = rand() % 100;
		}
	}
}

int main()
{
	int N = 1 << 10;

	size_t bytes_N = N * N * sizeof(int);

	int* matrix = new int[N * N];
	int* result = new int[N * N];
	init_matrix(matrix, N);

	size_t bytes_m = MASK_DIM * MASK_DIM * sizeof(int);

	int* h_mask = new int[MASK_DIM * MASK_DIM];
	init_matrix(h_mask, MASK_DIM);

	int* d_matrix, * d_result;
	cudaMalloc(&d_matrix, bytes_N);
	cudaMalloc(&d_result, bytes_N);

	cudaMemcpy(d_matrix, matrix, bytes_N, cudaMemcpyHostToDevice);
	cudaMemcpyToSymbol(mask, h_mask, bytes_m);

	int THREADS = 16;
	int BLOCKS = (N + THREADS - 1) / THREADS;

	dim3 block_dim(THREADS, THREADS);
	dim3 grid_dim(BLOCKS, BLOCKS);


	con2d << < grid_dim, block_dim >> > (d_matrix, d_result, N);

	cudaMemcpy(result, d_result, bytes_N, cudaMemcpyDeviceToHost);

	verify_result(matrix, h_mask, result, N);

	std::cout << "COMPLETED SUCCESSFULLY!";

	delete[] matrix;
	delete[] result;
	delete[] h_mask;

	cudaFree(d_matrix);
	cudaFree(d_result);

	return 0;
}