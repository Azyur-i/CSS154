#include <cstdio>
#include <iostream>
__global__ void oddEvenSortStepKernel(double *arr, int size, 
    bool *swapped, bool isOddPhase) {
    int idx = threadIdx.x + blockIdx.x * blockDim.x;
    int i = isOddPhase ? 2 * idx + 1 : 2 * idx;
    if (i < size - 1) {
        if (arr[i] > arr[i + 1]) {
            double temp = arr[i];
            arr[i] = arr[i + 1];
            arr[i + 1] = temp;
            *swapped = true;
        }
    }
}

void oddEvenSortGpu(double *arr, int size) {
    double *d_arr;
    bool *d_swapped, h_swapped;
    int threads = 256;
    int blocks = (size + threads - 1) / threads;
    cudaMalloc((void **)&d_arr, size * sizeof(double));
    cudaMalloc((void **)&d_swapped, sizeof(bool));
    cudaMemcpy(d_arr, arr, size * sizeof(double), cudaMemcpyHostToDevice);
    do {
        h_swapped = false;
        cudaMemcpy(d_swapped, &h_swapped, sizeof(bool),
            cudaMemcpyHostToDevice);
        oddEvenSortStepKernel<<<blocks, threads>>>(d_arr, size, d_swapped,
            true);
        cudaDeviceSynchronize();
        oddEvenSortStepKernel<<<blocks, threads>>>(d_arr, size, d_swapped,
            false);
        cudaDeviceSynchronize();
        cudaMemcpy(&h_swapped, d_swapped, sizeof(bool),
            cudaMemcpyDeviceToHost);
    } while (h_swapped);
    cudaMemcpy(arr, d_arr, size * sizeof(double),
        cudaMemcpyDeviceToHost);
    cudaFree(d_arr);
    cudaFree(d_swapped);
}

int main() {
  double arr [] = {2,8,6,3,4,8,1,6};
  int size = 8;
  oddEvenSortGpu(arr, size);
  	printf("Vector A: ");
		for(int i=0 ; i< size; ++i){
		std::cout<<arr[i]<<(", ");
	}
	
  return 0;
}