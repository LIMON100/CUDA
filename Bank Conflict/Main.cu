#include <iostream>
#include <vector>
#include<conio.h>
#include<cuda.h>
#include<ctime>
#include<cuda_runtime.h>
#include <device_launch_parameters.h>

using namespace std;

__global__ void myKernel(unsigned long long* time) {

	__shared__ float shared[1024];

	unsigned long long startTime = clock();

	shared[threadIdx.x]++;

	unsigned long long finishTime = clock();

	*time = (finishTime - startTime);

}

int main()
{
	unsigned long long time;
	unsigned long long* d_time;

	cudaMalloc(&d_time, sizeof(unsigned long long));

	for (int i = 0; i < 10; i++) {

		myKernel << <1, 32 >> > (d_time);

		cudaMemcpy(&time, d_time, sizeof(unsigned long long), cudaMemcpyDeviceToHost);

		std::cout << "Time: " << (time - 14) / 32 << endl;

		std::cout << endl;
	}

	cudaFree(d_time);

	_getch();

	cudaDeviceReset();

	return 0;
}