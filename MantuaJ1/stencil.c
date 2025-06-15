#include <stdio.h>
#include <stdlib.h>
#include <malloc.h> 
#include <windows.h>

void stencil_c(const float* X, float* Y, int n);

extern void stencil_asm(float* X, float* Y, int n);
extern void stencil_avx2_xmm(float* X, float* Y, int n);
extern void stencil_avx2_ymm(float* X, float* Y, int n);

typedef void (*stencil_func)(float*, float*, int);

int compare_outputs(const float* ref, const float* test, int length, float epsilon) {
    for (int i = 0; i < length; i++) {
        float diff = ref[i] - test[i];
        if (diff < 0) diff = -diff;
        if (diff > epsilon) {
            return 0; // Mismatch found
        }
    }
    return 1; // Match
}

int main() {
    // Vector sizes: 2^20, 2^26, 2^28
    const int sizes[] = { 1 << 20, 1 << 26, 1 << 28 };

    // Kernel version names (for reference)
    const char* versions[] = { "C", "ASM", "AVX2-XMM", "AVX2-YMM" };
    stencil_func funcs[] = { (stencil_func)stencil_c, stencil_asm, stencil_avx2_xmm, stencil_avx2_ymm };
    const int num_versions = sizeof(funcs) / sizeof(funcs[0]);

    // Number of times to run each kernel for timing
    const int num_runs = 30;

    const float epsilon = 1e-5f;

    FILE* outfile = fopen("stencil_results.txt", "w");
    if (!outfile) {
        printf("Failed to open output file.\n");
        return 1;
    }

    for (int s = 0; s < 3; s++) {
        int n = sizes[s];

        //// Allocate aligned memory
        //float* X = (float*)_aligned_malloc(n * sizeof(float), 32);
        //float* Y = (float*)_aligned_malloc((n - 6) * sizeof(float), 32);

        // Allocate buffers
        float* X = (float*)_aligned_malloc(n * sizeof(float), 32);
        float* Y_c = (float*)_aligned_malloc((n - 6) * sizeof(float), 32);
        float* Y_asm = (float*)_aligned_malloc((n - 6) * sizeof(float), 32);
        float* Y_avx2_xmm = (float*)_aligned_malloc((n - 6) * sizeof(float), 32);
        float* Y_avx2_ymm = (float*)_aligned_malloc((n - 6) * sizeof(float), 32);

        //if (!X || !Y) {
        //    printf("Memory allocation failed for size %d\n", n);
        //    if (X) _aligned_free(X);
        //    if (Y) _aligned_free(Y);
        //    return 1;
        //}

        if (!X || !Y_c || !Y_asm || !Y_avx2_xmm || !Y_avx2_ymm) {
            fprintf(outfile, "Memory allocation failed for size %d\n", n);
            goto cleanup;
        }

        // Initialize input vector
        for (int i = 0; i < n; i++) {
            X[i] = (float)(i % 100);
        }

        fprintf(outfile, "=== Vector size: %d ===\n", n);

        // Run C reference kernel once
        stencil_c(X, Y_c, n);

        // Run each assembly kernel once and check correctness
        stencil_asm(X, Y_asm, n);
        fprintf(outfile, "stencil_asm correctness: %s\n",
            compare_outputs(Y_c, Y_asm, n - 6, epsilon) ? "PASS" : "FAIL");

        stencil_avx2_xmm(X, Y_avx2_xmm, n);
        fprintf(outfile, "stencil_avx2_xmm correctness: %s\n",
            compare_outputs(Y_c, Y_avx2_xmm, n - 6, epsilon) ? "PASS" : "FAIL");

        stencil_avx2_ymm(X, Y_avx2_ymm, n);
        fprintf(outfile, "stencil_avx2_ymm correctness: %s\n",
            compare_outputs(Y_c, Y_avx2_ymm, n - 6, epsilon) ? "PASS" : "FAIL");


        LARGE_INTEGER freq;
        QueryPerformanceFrequency(&freq);

        for (int v = 0; v < num_versions; v++) {
            float* Y = NULL;
            if (v == 0) Y = Y_c;
            else if (v == 1) Y = Y_asm;
            else if (v == 2) Y = Y_avx2_xmm;
            else if (v == 3) Y = Y_avx2_ymm;

            // Warm-up run (optional)
            funcs[v](X, Y, n);

            LARGE_INTEGER start, end;
            QueryPerformanceCounter(&start);

            for (int run = 0; run < num_runs; run++) {
                funcs[v](X, Y, n);
            }

            QueryPerformanceCounter(&end);
            double elapsed_sec = (double)(end.QuadPart - start.QuadPart) / freq.QuadPart;

            fprintf(outfile, "--- %s kernel ---\n", versions[v]);
            fprintf(outfile, "Average runtime: %.6f seconds (over %d runs)\n", elapsed_sec / num_runs, num_runs);

            //// Print all info as one cohesive block per run
            //printf("=== Run Summary ===\n");
            //printf("Vector size: %d\n", n);
            //printf("Kernel version: %s\n", versions[v]);
            //printf("Average runtime: %.6f seconds (over %d runs)\n", elapsed_sec / num_runs, num_runs);

            // Print first 10 elements of input X
            fprintf(outfile, "Input X (first 10 elements): ");
            for (int i = 0; i < 10 && i < n; i++) {
                fprintf(outfile, "%.1f ", X[i]);
            }
            fprintf(outfile, "\n");

            // Print first 10 elements of output Y
            fprintf(outfile, "Output Y (first 10 elements): ");
            for (int i = 0; i < 10 && i < (n - 6); i++) {
                fprintf(outfile, "%.1f ", Y[i]);
            }
            fprintf(outfile, "\n");

            // Print last 10 elements of output Y
            fprintf(outfile, "Output Y (last 10 elements): ");
            int start_idx = (n - 6) > 10 ? (n - 6) - 10 : 0;
            for (int i = start_idx; i < (n - 6); i++) {
                fprintf(outfile, "%.1f ", Y[i]);
            }
            fprintf(outfile, "\n\n");
        }

    cleanup:
        _aligned_free(X);
        _aligned_free(Y_c);
        _aligned_free(Y_asm);
        _aligned_free(Y_avx2_xmm);
        _aligned_free(Y_avx2_ymm);
    }

    fclose(outfile);
    printf("Results written to stencil_results.txt\n");
    return 0;
}