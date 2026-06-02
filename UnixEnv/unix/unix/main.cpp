#include <dlfcn.h>
#include <iostream>

typedef void (*AddVectorsFunc)(int*, const int*, const int*, int);

int main() {
    void* handle = dlopen("./libmylib.so", RTLD_LAZY);
    if (!handle) {
        std::cerr << "Failed to load shared object: " << dlerror() << std::endl;
        return 1;
    }

    AddVectorsFunc addVectors = (AddVectorsFunc)dlsym(handle, "addVectors");
    if (!addVectors) {
        std::cerr << "Function not found: " << dlerror() << std::endl;
        return 1;
    }

    int a[5] = {1,2,3,4,5};
    int b[5] = {10,20,30,40,50};
    int c[5];

    addVectors(c, a, b, 5);

    for (int i : c) std::cout << i << " ";
    std::cout << std::endl;

    dlclose(handle);
    return 0;
}
