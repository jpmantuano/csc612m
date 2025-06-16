#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <immintrin.h>

void stencil_c(const float* X, float* Y, int n) {
    for (int i = 3; i < n - 3; i++) {
        Y[i - 3] = X[i - 3] + X[i - 2] + X[i - 1] + X[i] +
            X[i + 1] + X[i + 2] + X[i + 3];
    }
}