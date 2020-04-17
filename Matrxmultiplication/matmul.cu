#include <algorithm>
#include <cassert>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <vector>
#include<cuda.h>
#include<cuda_runtime.h>
#include <device_launch_parameters.h>

using std::cout;
using std::generate;
using std::vector;

__global__ void MatrixMul(const int* a, const int* b, int* c, int N) {

    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    c[row * N + col] = 0;

    for (int k = 0; k < N; k++) {

        c[row * N + col] += a[row * N + k] * b[k * N + col];

    }
}

void verify_result(vector<int>& a, vector<int>& b, vector<int>& c, int N) {

    for (int i = 0; i < N; i++) {

        for (int j = 0; j < N; j++) {

            int tmp = 0;
            for (int k = 0; k < N; k++) {

                tmp += a[i * N + k] * b[k * N + j];
            }

            assert(tmp == c[i * N + j]);
        }
    }
}


int main()
{
	return 0;
}