#include <windows.h>
#include <iostream>

typedef void (*AddVectorsFunc)(int*, const int*, const int*, int);

int main() {
    HMODULE hDll = LoadLibrary("mylib.dll");
    if (!hDll) {
        std::cerr << "Failed to load DLL" << std::endl;
        return 1;
    }

    AddVectorsFunc addVectors = (AddVectorsFunc)GetProcAddress(hDll, "addVectors");
    if (!addVectors) {
        std::cerr << "Function not found" << std::endl;
        return 1;
    }

    int a[5] = {1,2,3,4,5};
    int b[5] = {10,20,30,40,50};
    int c[5];

    addVectors(c, a, b, 5);

    for (int i : c) std::cout << i << " ";
    std::cout << std::endl;

    FreeLibrary(hDll);
    return 0;
}
