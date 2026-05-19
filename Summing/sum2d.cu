#include <cstdio>
#include <cuda_runtime.h>

__global__ void sum(float *d_A, int width, int height) {

    int t = width / 2;
    int s = (width % 2) ? t + 1 : t;

    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x < t && y < height) {
        int index1 = y * width + x;
        int index2 = y * width + x + s;

        if ((x + s) < width) {
            d_A[index1] = d_A[index1] + d_A[index2];
        }
    }
}

void print(float *A, int width, int height) {

    printf("A:\n");

    for (int y = 0; y < height; y++) {

        for (int x = 0; x < width; x++) {
            printf("%6.1f ", A[y * width + x]);
        }

        printf("\n");
    }

    printf("\n");
}

void total(int width, int height, float *A) {

    int n = width;

    printf("Starting\n");

    int size = width * height * sizeof(float);

    float *d_A;

    cudaMalloc((void**)&d_A, size);

    cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);

    while (n > 1) {

        printf("n = %d\n", n);

        print(A, n, height);

        dim3 threadsPerBlock(16, 16);
        dim3 numBlocks((n + 15) / 16, (height + 15) / 16);

        sum<<<numBlocks, threadsPerBlock>>>(d_A, n, height);

        cudaDeviceSynchronize();

        n = (n % 2 == 0) ? n / 2 : n / 2 + 1;

        cudaMemcpy(A, d_A, size, cudaMemcpyDeviceToHost);
    }

    printf("Column sums:\n");

    for (int y = 0; y < height; y++) {
        printf("Row %d Sum = %6.1f\n", y, A[y * width]);
    }

    cudaFree(d_A);
}

int main() {

    const int height = 3;
    const int width = 10;

    float A[height][width] = {
        {2,3,3,4,4,1,6,7,4,4},
        {1,2,3,4,5,6,7,8,9,10},
        {5,5,5,5,5,5,5,5,5,5}
    };

    total(width, height, (float*)A);

    return 0;
}