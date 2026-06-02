#include <cuda_runtime.h>
#include <iostream>

// CUDA kernel
extern "C" __global__ 
void addKernel(int* c, const int* a, const int* b, int size) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < size) c[i] = a[i] + b[i];
}

// Exported host function
extern "C" void addVectors(int* c, const int* a, const int* b, int size) {
    int *d_a, *d_b, *d_c;
    size_t bytes = size * sizeof(int);

    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    cudaMemcpy(d_a, a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, bytes, cudaMemcpyHostToDevice);

    int threadsPerBlock = 256;
    int blocks = (size + threadsPerBlock - 1) / threadsPerBlock;
    addKernel<<<blocks, threadsPerBlock>>>(d_c, d_a, d_b, size);
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess) {
        std::cerr << "CUDA error: " << cudaGetErrorString(err) << std::endl;
    }
    cudaDeviceSynchronize();
    cudaMemcpy(c, d_c, bytes, cudaMemcpyDeviceToHost);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
}
