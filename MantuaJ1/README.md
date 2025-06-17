## Overview

This project implements and benchmarks four versions of a 1D 7-point stencil operation:

- **C Kernel**: Plain C implementation
- **ASM Kernel**: Hand-tuned scalar x86-64 assembly
- **AVX2-XMM Kernel**: Vectorized with 128-bit AVX2 (XMM, 4 floats at a time)
- **AVX2-YMM Kernel**: Vectorized with 256-bit AVX2 (YMM, 8 floats at a time)

Each kernel computes the sum `Y[i] = X[i-3] + X[i-2] + X[i-1] + X[i] + X[i+1] + X[i+2] + X[i+3]` for all valid `i`.

Primary vector size inputs: 2^20, 2^26, 2^28

---
## Performance Analysis

- **ASM kernel** Consistently achieves about 4x speedup across all dataset sizes compared to the C reference implementation by leveraging hand-optimized assembly code that reduces overhead.
- **AVX2-XMM and AVX2-YMM kernels**. These vectorized kernels show roughly 7.5x to 8.5x speedup over the C baseline, demonstrating the power of SIMD instructions to process multiple data points concurrently. However, initial tries fail the correctness checks for all dataset sizes, indicating implementation bugs (research shows it could be the memory alignment, or vector load/store offsets).
- The AVX2 kernels' failures highlight the complexity of vectorized code and the importance of correct memory alignment, pointer arithmetic, and boundary handling.
- The C kernel, while slower, produces correct results and serves as the baseline for verification.
- The ASM kernel is both fast and correct on the first try, showing the benefit of careful manual optimization and easier implmentation.

---
## Problems Encountered and Solutions

- **Correctness Failures in AVX2 Kernels:**
##### **1. Boundary Handling**

- **Problem**: Vectorized loops cannot process the first/last 3 elements due to stencil access; these must be handled separately.
- **Solution**: Used scalar code for the boundary elements, and vector code for the main body. For the YMM/XMM kernels, a scalar tail loop ensures all outputs are written, even if the total is not a multiple of the vector width.


##### **2. NASM Operand Restrictions**

- **Problem**: NASM does not allow `addss xmm0, dword [mem]`; only register operands are valid.
- **Solution**: Always load memory operands into a register before arithmetic:

```nasm
movss xmm1, dword [mem]
addss xmm0, xmm1
```


##### **3. Register Size Mismatches**

- **Problem**: Mixing 32-bit and 64-bit registers in address calculations or moves (e.g., `mov rbx, eax`) caused build errors.
- **Solution**: Used consistent register sizes for pointers and counters.


---
## Unique Methodology and AHA Moments

- **Manual Assembly Optimization vs Compiler:**
The ASM kernel's success demonstrated that assembly can outperform compiler-generated code by carefully managing registers and instructions.

- **Vectorization Complexity:**
The AVX2 kernels’ failures highligthed the subtlety of SIMD programming: performance gains come with increased complexity in memory access patterns and alignment requirements, which are easy to overlook and cause silent correctness bugs.

- **Importance of Incremental Testing:**
Testing kernels on smaller vector sizes with detailed output helped isolate errors in pointer arithmetic and memory offsets before scaling to large inputs.

- **Performance vs Correctness Tradeoff:**
The project highlighted that raw speed is achievable but comes with more complicated implementation to ensure correctness.

---
## Summary

This project illustrates the tradeoffs in optimizing a 1D stencil computation:

- **C code** is reliable but slower.
- **ASM code** offers a balance of speed, correctness and easier more straight forward implementation.
- **AVX2 vectorized code** promises the highest speed but requires more attention to detail to ensure correctness. Careful handling of boundary elements is needed to ensure correctness of the output.



## Data Collected

### Runtime Average Across 30 Kernel Runs Before Handling Boundary Elements

| Vector Size            | Kernel   | Avg Runtime (s) | Speedup vs C | Correctness |
| :--------------------- | :------- | :-------------- | :----------- | :---------- |
| **1,048,576** (1M)     | C        | 0.004020        | 1x           | PASS        |
|                        | ASM      | 0.000985        | ~4.08x       | PASS        |
|                        | AVX2-XMM | 0.000480        | ~8.38x       | FAIL        |
|                        | AVX2-YMM | 0.000428        | ~9.39x       | FAIL        |
| **67,108,864** (67M)   | C        | 0.259665        | 1x           | PASS        |
|                        | ASM      | 0.065033        | ~3.99x       | PASS        |
|                        | AVX2-XMM | 0.034677        | ~7.49x       | FAIL        |
|                        | AVX2-YMM | 0.033348        | ~7.79x       | FAIL        |
| **268,435,456** (268M) | C        | 1.026571        | 1x           | PASS        |
|                        | ASM      | 0.261513        | ~3.93x       | PASS        |
|                        | AVX2-XMM | 0.133794        | ~7.67x       | FAIL        |
|                        | AVX2-YMM | 0.130529        | ~7.87x       | FAIL        |
|                        |          |                 |              |             |

### Input and Output Elements Before Handling Boundary Elements

| Vector Size | Kernel | Input X (first 10 elements) | Output Y (first 10 elements) | Output Y (last 10 elements) |
| :-- | :-- | :-- | :-- | :-- |
| 1,048,576 | C | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 |
|  | ASM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 |
|  | AVX2-XMM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 **-431602080.0 -431602080.0** |
|  | AVX2-YMM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 **-431602080.0 -431602080.0** |
| 67,108,864 | C | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 |
|  | ASM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 |
|  | AVX2-XMM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 **-431602080.0 -431602080.0** |
|  | AVX2-YMM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 **-431602080.0 -431602080.0** |
| 268,435,456 | C | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 |
|  | ASM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 |
|  | AVX2-XMM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 **-431602080.0 -431602080.0** |
|  | AVX2-YMM | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 **-431602080.0 -431602080.0** |


*This table is taken from the [stencil_results.txt] output file of the C program.*


### Runtime Average Across 30 Kernel Runs After Handling Boundary Elements


| Vector Size | C Kernel (s) | ASM Kernel (s) | AVX2-XMM (s) | AVX2-YMM (s) | XMM Speedup vs C | YMM Speedup vs C | YMM Speedup vs XMM |
| :-- | :-- | :-- | :-- | :-- | :-- | :-- | :-- |
| 1,048,576 | 0.0040 | 0.0010 | 0.0005 | 0.0005 | 8.1× | 8.6× | 1.06× |
| 67,108,864 | 0.2564 | 0.0644 | 0.0336 | 0.0307 | 7.6× | 8.4× | 1.09× |
| 268,435,456 | 1.0282 | 0.2570 | 0.1318 | 0.1254 | 7.8× | 8.2× | 1.05× |


### Input and Output Elements After Handling Boundary Elements


| Vector Size | Kernel | Average Runtime (s) | Output Y (First 10) | Output Y (Last 10) | Correctness |
| :-- | :-- | :-- | :-- | :-- | :-- |
| 1,048,576 | C | 0.004027 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 | PASS |
|  | ASM | 0.001000 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 | PASS |
|  | AVX2-XMM | 0.000495 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 | PASS |
|  | AVX2-YMM | 0.000467 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 | PASS |
| 67,108,864 | C | 0.256434 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 | PASS |
|  | ASM | 0.064403 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 | PASS |
|  | AVX2-XMM | 0.033587 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 | PASS |
|  | AVX2-YMM | 0.030662 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 | PASS |
| 268,435,456 | C | 1.028180 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 | PASS |
|  | ASM | 0.257009 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 | PASS |
|  | AVX2-XMM | 0.131805 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 | PASS |
|  | AVX2-YMM | 0.125429 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 | PASS |



*This table is taken from the [stencil_results_2.txt] output file of the C program.*



### Debug Run Data

| Vector Size | Kernel       | Correctness | Average Runtime (seconds) | Input X (first 10)              | Output Y (first 10)             | Output Y (last 10)               |
|-------------|--------------|-------------|---------------------------|--------------------------------|--------------------------------|---------------------------------|
| 1,048,576   | stencil_asm  | PASS        |                           |                                |                                |                                 |
|             | stencil_avx2_xmm | PASS    |                           |                                |                                |                                 |
|             | stencil_avx2_ymm | PASS    |                           |                                |                                |                                 |
|             | C kernel     |             | 0.004036                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 |
|             | ASM kernel   |             | 0.001003                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 |
|             | AVX2-XMM kernel |           | 0.000512                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 |
|             | AVX2-YMM kernel |           | 0.000495                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 441.0 448.0 455.0 462.0 469.0 476.0 483.0 490.0 497.0 504.0 |

| 67,108,864  | stencil_asm  | PASS        |                           |                                |                                |                                 |
|             | stencil_avx2_xmm | PASS    |                           |                                |                                |                                 |
|             | stencil_avx2_ymm | PASS    |                           |                                |                                |                                 |
|             | C kernel     |             | 0.257649                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 |
|             | ASM kernel   |             | 0.064584                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 |
|             | AVX2-XMM kernel |           | 0.033518                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 |
|             | AVX2-YMM kernel |           | 0.031358                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 357.0 364.0 371.0 378.0 385.0 392.0 399.0 406.0 413.0 420.0 |

| 268,435,456 | stencil_asm  | PASS        |                           |                                |                                |                                 |
|             | stencil_avx2_xmm | PASS    |                           |                                |                                |                                 |
|             | stencil_avx2_ymm | PASS    |                           |                                |                                |                                 |
|             | C kernel     |             | 1.031096                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 |
|             | ASM kernel   |             | 0.257607                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 |
|             | AVX2-XMM kernel |           | 0.139365                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 |
|             | AVX2-YMM kernel |           | 0.128493                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 301.0 308.0 315.0 322.0 329.0 336.0 343.0 350.0 357.0 364.0 |

| 536,870,912 | stencil_asm  | PASS        |                           |                                |                                |                                 |
|             | stencil_avx2_xmm | PASS    |                           |                                |                                |                                 |
|             | stencil_avx2_ymm | PASS    |                           |                                |                                |                                 |
|             | C kernel     |             | 2.076522                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 393.0 300.0 207.0 114.0 21.0 28.0 35.0 42.0 49.0 56.0 |
|             | ASM kernel   |             | 0.529830                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 393.0 300.0 207.0 114.0 21.0 28.0 35.0 42.0 49.0 56.0 |
|             | AVX2-XMM kernel |           | 0.268416                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 393.0 300.0 207.0 114.0 21.0 28.0 35.0 42.0 49.0 56.0 |
|             | AVX2-YMM kernel |           | 0.255352                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 393.0 300.0 207.0 114.0 21.0 28.0 35.0 42.0 49.0 56.0 |

| 1,073,741,824 | stencil_asm | PASS       |                           |                                |                                |                                 |
|               | stencil_avx2_xmm | PASS   |                           |                                |                                |                                 |
|               | stencil_avx2_ymm | PASS   |                           |                                |                                |                                 |
|               | C kernel     |             | 4.979233                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 77.0 84.0 91.0 98.0 105.0 112.0 119.0 126.0 133.0 140.0 |
|               | ASM kernel   |             | 1.043016                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 77.0 84.0 91.0 98.0 105.0 112.0 119.0 126.0 133.0 140.0 |
|               | AVX2-XMM kernel |           | 0.464241                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 77.0 84.0 91.0 98.0 105.0 112.0 119.0 126.0 133.0 140.0 |
|               | AVX2-YMM kernel |           | 0.397962                  | 0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 | 21.0 28.0 35.0 42.0 49.0 56.0 63.0 70.0 77.0 84.0 | 77.0 84.0 91.0 98.0 105.0 112.0 119.0 126.0 133.0 140.0 |

