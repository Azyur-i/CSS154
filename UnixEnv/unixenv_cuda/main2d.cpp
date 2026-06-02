#include <dlfcn.h>
#include <iostream>

#define ROWS 3
#define COLS 4

typedef void (*AddArrays2DFunc)(int*, const int*, const int*, int, int);

int main() {
    void* handle = dlopen("./libmylib2d.so", RTLD_LAZY);
    if (!handle) {
        std::cerr << "Failed to load: " << dlerror() << std::endl;
        return 1;
    }

    AddArrays2DFunc addArrays2D = (AddArrays2DFunc)dlsym(handle, "addArrays2D");
    if (!addArrays2D) {
        std::cerr << "Function not found: " << dlerror() << std::endl;
        return 1;
    }

    int a[ROWS][COLS] = { {1,2,3,4}, {5,6,7,8}, {9,10,11,12} };
    int b[ROWS][COLS] = { {10,20,30,40}, {50,60,70,80}, {90,100,110,120} };
    int c[ROWS][COLS];

    addArrays2D(&c[0][0], &a[0][0], &b[0][0], ROWS, COLS);

    std::cout << "Sum of each row after element-wise addition:" << std::endl;
    for (int r = 0; r < ROWS; r++) {
        int rowSum = 0;
        std::cout << "  Row " << r << ": ";
        for (int col = 0; col < COLS; col++) {
            std::cout << c[r][col] << " ";
            rowSum += c[r][col];
        }
        std::cout << " -> sum = " << rowSum << std::endl;
    }

    dlclose(handle);
    return 0;
}
