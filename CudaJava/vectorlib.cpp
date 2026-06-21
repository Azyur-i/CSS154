#include <jni.h>
#include <vector>
#include <numeric>  // for std::accumulate

extern "C" __declspec(dllexport)
jint JNICALL Java_VectorExample_sumVector(JNIEnv* env, jobject obj, jintArray arr) {
    // Convert Java int[] to C++ std::vector<int>
    jsize length = env->GetArrayLength(arr);
    jint* elements = env->GetIntArrayElements(arr, nullptr);

    std::vector<int> vec(elements, elements + length);
    jint sum = std::accumulate(vec.begin(), vec.end(), 0);

    env->ReleaseIntArrayElements(arr, elements, 0);
    return sum;
}
