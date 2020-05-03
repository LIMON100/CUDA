#include <stdio.h>
#include<iostream>
#include<cuda.h>
#include<cuda_runtime.h>
using namespace std;

int main()
{
	int device_count;
	cudaGetDeviceCount(&device_count);

	std::cout << "There are " << device_count << " GPU system" << std::endl;

	for (int i = 0; i < device_count; i++) {
		cudaSetDevice(i);

		cudaDeviceProp deviceprop;

		cudaGetDeviceProperties(&deviceprop, i);
		std::cout << "Device " << i << " is a "<<deviceprop.name << std::endl;


		int driver;
		int runtime;

		cudaDriverGetVersion(&driver);
		cudaRuntimeGetVersion(&runtime);

		std::cout << "Driver " << driver << " Runtime " <<runtime << std::endl;

		std::cout << "Cuda Device capability " << deviceprop.minor << "." << deviceprop.major << std::endl;

		std::cout << "Total Global Memory GB : " << deviceprop.totalGlobalMem / (1 <<30)<<  std::endl;

		std::cout << "Clockrate " << deviceprop.clockRate * 1e-6 << " GHz " << std::endl;

		std::cout << "Shared Memory per block: " << deviceprop.sharedMemPerBlock / (1<<10) << std::endl;
	}

	return 0;
}
