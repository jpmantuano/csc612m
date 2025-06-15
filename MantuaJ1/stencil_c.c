#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <immintrin.h>

//#define ITERATIONS 30

void stencil_c(const float* X, float* Y, int n) {
    for (int i = 3; i < n - 3; i++) {
        Y[i - 3] = X[i - 3] + X[i - 2] + X[i - 1] + X[i] +
            X[i + 1] + X[i + 2] + X[i + 3];
    }
}

// Timing wrapper for C version
//double time_stencil_c(float* X, float* Y, int n) {
//    clock_t start = clock();
//   for (int i = 0; i < ITERATIONS; i++) {
//        stencil_c(X, Y, n);
//    }
//    return (double)(clock() - start) / CLOCKS_PER_SEC / ITERATIONS;
//}