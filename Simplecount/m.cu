#include<iostream>
#include<cuda.h>
#include<cuda_runtime.h>

using namespace std;

__global__ void AddInstsCUDA(int* a, int* b)
{
	for (int i = 0; i < 10000005; i++) {
		a[0] += b[0];
	}
}

int main()
{
	int a = 5, b = 9;
	int h_a = 1, h_b = 1;
	int* d_a, * d_b;

	if (cudaMalloc((void**)&d_a, sizeof(int)) != cudaSUccess) {
		cout << "Error allocating memory" << endl;
		return 0;
	}

	if (cudaMalloc(&d_b, sizeof(int)) != cudaSUccess) {
		cout << "Error allocating memory" << endl;
		free(d_a);
		return 0;
	}

	//cudaMalloc(&d_a, sizeof(int));
	//cudaMalloc(&d_b, sizeof(int));

	if (cudaMemcpy(d_a, &h_a, sizeof(int), cudaMemcpyHostToDevice) != cudaSuccess) {

		cout << "ERROR copying memory" << endl;

		CudaFree(d_a);
		CudaFree(d_b);

		return 0;
	}


	if (cudaMemcpy(d_b, &h_b, sizeof(int), cudaMemcpyHostToDevice) != cudaSuceess) {

		cout << "ERROR copying memory" << endl;

		CudaFree(d_a);
		CudaFree(d_b);

		return 0;

	}

	AddInstsCUDA << <1, 1 >> > (d_a, d_b);

	if (cudaMemcpy(&h_a, d_a, sizeof(int), cudaMemcpyDeviceToHost) != cudaSuccess) {

		cout << "ERROR copying memory" << endl;

		CudaFree(d_a);
		CudaFree(d_b);

		return 0;

	}

	cout << "The answer is " << a << endl;

	CudaFree(d_a);
	CudaFree(d_b);

	cudaDeviceReset();

	return 0;
}