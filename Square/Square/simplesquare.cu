#include<stdio.h>

__global__ void squr(float *d_out, float *d_in) {
	int idx = threadIdx.x;
	float f = d_in[idx];
	d_out[idx] = f * f;
}


int main(int argc, char ** argv) {

	const int array_size = 65;
	const int array_bytes = array_size * sizeof(float);

	float h_in[array_size];

	for (int i = 0; i < array_size; i++) {
		h_in[i] = float(i);
	}

	float h_out[array_size];

	float *d_in;
	float *d_out;

	cudaMalloc((void **)&d_in, array_bytes);
	cudaMalloc((void **)&d_out, array_bytes);

	cudaMemcpy(d_in, h_in, array_bytes, cudaMemcpyHostToDevice);

	squr << < 1, array_size >> > (d_out, d_in);

	cudaMemcpy(h_out, d_out, array_bytes, cudaMemcpyDeviceToHost);


	for (int i = 0; i < array_size; i++) {
		printf("%f", h_out);
		printf(((i % 4) != 3) ? "\t" : "\n");
	}

	cudaFree(d_in);
	cudaFree(d_out);

	return 0;
}