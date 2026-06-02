#include <cuda_runtime.h>
#include <iostream>

__global__
void addKernel2D(int* c, const int* a, const int* b, int rows, int cols) {
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    if (row < rows && col < cols) {
        int idx = row * cols + col;
        c[idx] = a[idx] + b[idx];
    }
}

extern "C"
void addArrays2D(int* c, const int* a, const int* b, int rows, int cols) {
    int total = rows * cols;
    size_t bytes = total * sizeof(int);

    int *d_a = nullptr, *d_b = nullptr, *d_c = nullptr;

    cudaError_t err;

    err = cudaMalloc(&d_a, bytes);
    err |= cudaMalloc(&d_b, bytes);
    err |= cudaMalloc(&d_c, bytes);

    if (err != cudaSuccess) {
        std::cerr << "cudaMalloc failed: " << cudaGetErrorString(err) << std::endl;
        return;
    }

    cudaMemcpy(d_a, a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, b, bytes, cudaMemcpyHostToDevice);

    dim3 threads(16, 16);
    dim3 blocks(
        (cols + threads.x - 1) / threads.x,
        (rows + threads.y - 1) / threads.y
    );

    addKernel2D<<<blocks, threads>>>(d_c, d_a, d_b, rows, cols);

    // IMPORTANT: check kernel launch error
    err = cudaGetLastError();
    if (err != cudaSuccess) {
        std::cerr << "Kernel launch error: " << cudaGetErrorString(err) << std::endl;
        return;
    }

    // IMPORTANT: wait for kernel
    err = cudaDeviceSynchronize();
    if (err != cudaSuccess) {
        std::cerr << "Kernel execution error: " << cudaGetErrorString(err) << std::endl;
        return;
    }

    cudaMemcpy(c, d_c, bytes, cudaMemcpyDeviceToHost);

    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);
}