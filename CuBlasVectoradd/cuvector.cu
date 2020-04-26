#include <stdio.h>
#include <cassert>
#include <iostream>
#include<cuda.h>
#include<cuda_runtime.h>
#include <device_launch_parameters.h>
#include<cublas_v2.h>
#include<math.h>

using std::cout;

void vector_init(float* a, int n) {

    for (int i = 0; i < n; i++) {
        a[i] = (float)(rand() % 100);
    }

}

void verify_result(float* a, float* b, float* c, float factor, int n) {

    for (int i = 0; i < n; i++) {
        assert(c[i] == factor * a[i] + b[i]);
    }

}

int main() {
    
    int n = 1 << 2;

    size_t bytes = n * sizeof(float);

    float* h_a, * h_b, * h_c;
    float *d_a, * d_b;

    h_a = (float*)malloc(bytes);
    h_b = (float*)malloc(bytes);
    h_c = (float*)malloc(bytes);

    vector_init(h_a, n);
    vector_init(h_b , n);

    cublasHandle_t handle;
    cublasCreate_v2(&handle);

    cublasSetVector(n, sizeof(float), h_a, 1, d_a, 1);
    cublasSetVector(n, sizeof(float), h_b, 1, d_b, 1);

    const float scale = 2.0f;
    cublasSaxpy(handle, n, &scale, d_a, 1, d_b, 1);

    cublasGetVector(n, sizeof(float) , d_b , 1 , h_c , 1);

    verify_result(h_a, h_b, h_c, scale, n);

    cublasDestroy(handle);


    cudaFree(d_a);
    cudaFree(d_b);
    free(h_a);
    free(h_b);

    return 0;
}