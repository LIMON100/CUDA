#include<iostream>
#include<stdio.h>
#include<cuda.h>
#include<cuda_runtime.h>
#include<device_launch_parameters.h>


__global__ void cub(float* d_out, float* d_in) {

	int id = threadIdx.x;
	float f = d_in[id];
	d_out[id] = f * f * f;

}

int main(int argc , char ** argv)
{
	const int array_size = 64;
	const int bytes = array_size * sizeof(float);

	float h_in[array_size];
	for (int i = 0; i < array_size; i++) {
		h_in[i] = float(i);
	}

	float h_out[array_size];

	float* d_in;
	float* d_out;

	cudaMalloc((void**)&d_in, bytes);
	cudaMalloc((void**)&d_out, bytes);


	cudaMemcpy(d_in, h_in, bytes, cudaMemcpyHostToDevice);

	cub << <1, array >> > (d_out, d_in);

	cudaMemcpy(h_out, d_out, bytes, cudaMemcpyDeviceToHost);


	for (int i = 0; i < array_size; i++) {
		printf("%f", h_out[i]);
		printf(((i % 4) != 3) ? "\t" : "\n");

	}

	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}