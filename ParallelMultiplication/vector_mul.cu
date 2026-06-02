#include <iostream>
#include <cuda_runtime.h>

__global__ void computeDailySales(
    float* sales,
    float* prices,
    float* dailySales,
    int rows,
    int cols
) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < rows * cols) {
        dailySales[idx] = sales[idx] * prices[idx];
    }
}

__global__ void computeTotalSales(float* dailySales, float* total, int size) {

    __shared__ float partialSum[256];

    int tid = threadIdx.x;
    int idx = blockIdx.x * blockDim.x + threadIdx.x;

    if (idx < size)
        partialSum[tid] = dailySales[idx];
    else
        partialSum[tid] = 0.0f;

    __syncthreads();

    // Reduction
    for (int stride = blockDim.x / 2; stride > 0; stride /= 2) {
        if (tid < stride) {
            partialSum[tid] += partialSum[tid + stride];
        }
        __syncthreads();
    }

    if (tid == 0) {
        atomicAdd(total, partialSum[0]);
    }
}

int main() {

    const int rows = 3;   // Diesel, Gasoline, Kerosene
    const int cols = 4;   // Monday to Thursday
    const int size = rows * cols;

    float h_sales[size] = {
        // Diesel
        12, 11, 4, 3,

        // Gasoline
        12, 8, 5, 6,

        // Kerosene
        3, 7, 8, 2
    };

    float h_fixedPrices[size] = {

        // Diesel = 2
        2, 2, 2, 2,

        // Gasoline = 1
        1, 1, 1, 1,

        // Kerosene = 2
        2, 2, 2, 2
    };

    float h_variablePrices[size] = {

        // Diesel
        2, 3, 6, 7,

        // Gasoline
        1, 8, 3, 7,

        // Kerosene
        2, 3, 5, 1
    };


    float *d_sales;
    float *d_prices;
    float *d_dailySales;
    float *d_total;

    cudaMalloc(&d_sales, size * sizeof(float));
    cudaMalloc(&d_prices, size * sizeof(float));
    cudaMalloc(&d_dailySales, size * sizeof(float));
    cudaMalloc(&d_total, sizeof(float));

    cudaMemcpy(d_sales, h_sales, size * sizeof(float), cudaMemcpyHostToDevice);


    cudaMemcpy(d_prices, h_fixedPrices, size * sizeof(float), cudaMemcpyHostToDevice);

    int blockSize = 256;
    int gridSize = (size + blockSize - 1) / blockSize;

    computeDailySales<<<gridSize, blockSize>>>(
        d_sales,
        d_prices,
        d_dailySales,
        rows,
        cols
    );

    float h_dailySalesA[size];

    cudaMemcpy(
        h_dailySalesA,
        d_dailySales,
        size * sizeof(float),
        cudaMemcpyDeviceToHost
    );

    std::cout << "===== PART A: Fixed Prices =====\n";

    for (int i = 0; i < rows; i++) {

        for (int j = 0; j < cols; j++) {
            std::cout << h_dailySalesA[i * cols + j] << "\t";
        }

        std::cout << "\n";
    }

    cudaMemcpy(
        d_prices,
        h_variablePrices,
        size * sizeof(float),
        cudaMemcpyHostToDevice
    );

    computeDailySales<<<gridSize, blockSize>>>(
        d_sales,
        d_prices,
        d_dailySales,
        rows,
        cols
    );

    float h_dailySalesB[size];

    cudaMemcpy(
        h_dailySalesB,
        d_dailySales,
        size * sizeof(float),
        cudaMemcpyDeviceToHost
    );

    std::cout << "\n===== PART B: Varying Prices =====\n";

    for (int i = 0; i < rows; i++) {

        for (int j = 0; j < cols; j++) {
            std::cout << h_dailySalesB[i * cols + j] << "\t";
        }

        std::cout << "\n";
    }

    float zero = 0.0f;

    cudaMemcpy(d_total, &zero, sizeof(float), cudaMemcpyHostToDevice);

    computeTotalSales<<<gridSize, blockSize>>>(
        d_dailySales,
        d_total,
        size
    );

    float h_total;

    cudaMemcpy(
        &h_total,
        d_total,
        sizeof(float),
        cudaMemcpyDeviceToHost
    );

    std::cout << "\n===== PART C: Total Sales =====\n";
    std::cout << "Total Sales = " << h_total << "\n";

    cudaFree(d_sales);
    cudaFree(d_prices);
    cudaFree(d_dailySales);
    cudaFree(d_total);

    return 0;
}
