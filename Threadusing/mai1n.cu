#include<cuda.h>
#include<stdlib.h>
#include<ctime>
#include<iostream>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"s

using namespace std;

__global__ void AddInts(int* a, int* b, int count) {

	int id = blockIdx.x * blockDim.x + threadIdx.x;

	if (id < count) {
		a[id] = b[id]; 
	}

}

int main()
{
	srand(time(NULL));

	int count = 100;

	int *h_a = new int[count];
	int *h_b = new int[count];

	for (int i = 0; i < count; i++) {

		h_a[i] = rand() % 1000;
		h_b[i] = rand() % 1000;

	}

	std::cout << "Prior to addition";

	for (int i = 0; i < 5; i++) {
		std::cout << h_a[i] << " " << h_b[i] << std::endl;
	}

	int* d_a, * d_b;

	if (cudaMalloc(&d_a, sizeof(int) * count) != cudaSuccess) {
		std::cout << "Nope";
		return 0;
	}

	if (cudaMalloc(&d_b, sizeof(int) * count) != cudaSuccess) {
		std::cout << "Nope";
		return 0;
	}

	if (cudaMemcpy(d_a, h_a, sizeof(int) * count, cudaMemcpyHostToDevice) != cudaSuccess) {
		std::cout << "Could not copy" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		return 0;
	}


	if (cudaMemcpy(d_b, h_b, sizeof(int) * count, cudaMemcpyHostToDevice) != cudaSuccess) {
		std::cout << "Could not copy" << endl;
		cudaFree(d_a);
		cudaFree(d_b);
		return 0;
	}

	AddInts <<< count / 256 + 1, 256 >> > (d_a, d_b, count);

	if (cudaMemcpy(h_a, d_a, sizeof(int) * count, cudaMemcpyDeviceToHost) != cudaSuccess) {

		delete[] h_a;
		delete[] h_b;
		cudaFree(d_a);
		cudaFree(d_b);
		return 0;
	}

	for (int i = 0; i < 5; i++) {
		std::cout << "It's a" << h_a[i] << endl;
	}

	cudaFree(d_a);
	cudaFree(d_b);

	delete[] h_a;
	delete[] h_b;

	return 0;
}