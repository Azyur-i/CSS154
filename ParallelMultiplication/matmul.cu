#include <cstdio>
#include <iostream>
__global__ void matrixMulKernel(double *A, double *B,
 double *C, int width) {
    int row = threadIdx.y + blockIdx.y * blockDim.y;
    int col = threadIdx.x + blockIdx.x * blockDim.x;
    if (row < width && col < width) {
        double value = 0;
        for (int k = 0; k < width; k++) {
            value += A[row * width + k] * B[k * width + col];
        }
        C[row * width + col] = value;
    }
}

int main() {
  double A [] = {2,8,6,3,4,8,1,6,1};
  double B [] = {2,8,6,3,4,10,1,6,2};
  double C [] = {0,0,0,0,0,0,0,0,0};
  int width = 3;
  int size  = width * width;
  dim3 threadperblock(1,1);
  dim3 blocksize(3,3);
  float *d_A, *d_B, *d_C;
  cudaMalloc((void**)&d_A, width*width);
  cudaMalloc((void**)&d_B, width*width);
  cudaMalloc((void**)&d_C, width*width);

    // Copy data to device
  cudaMemcpy(d_A, A, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_B, B, size, cudaMemcpyHostToDevice);
  matrixMulKernel<<<blocksize, threadperblock>>>(A, B, C, width);
  cudaMemcpy(C, d_C,  size, cudaMemcpyDeviceToHost);
	printf("Vector A: ");
		for(int i=0 ; i< width*width; ++i){
		std::cout<<A[i]<<(", ");
	}

    	printf("Vector B: ");
		for(int i=0 ; i< width*width; ++i){
		std::cout<<B[i]<<(", ");
	}

    	printf("Vector C: ");
		for(int i=0 ; i< width*width; ++i){
		std::cout<<C[i]<<(", ");
	}
	
  return 0;
}