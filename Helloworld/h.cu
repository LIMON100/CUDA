#include<iostream>
#include<cuda.h>
#include<cuda_runtime.h>


__global__ void mykernel(void) {

}

int main(void) {

	mykernel << <1, 1 >> > ();
	std::cout << "Hello CUDA" << std::endl;

	return 0;
}