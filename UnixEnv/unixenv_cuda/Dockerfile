FROM nvidia/cuda:12.4.0-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y g++ && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY mylib.cu main.cpp mylib2d.cu main2d.cpp ./

# 1D version
RUN nvcc -Xcompiler -fPIC -shared -o libmylib.so mylib.cu
RUN g++ -o main main.cpp -ldl -Wl,-rpath,.

# 2D version
RUN nvcc -Xcompiler -fPIC -shared -o libmylib2d.so mylib2d.cu
RUN g++ -o main2d main2d.cpp -ldl -Wl,-rpath,.

CMD echo "=== 1D ===" && ./main && echo "" && echo "=== 2D ===" && ./main2d
