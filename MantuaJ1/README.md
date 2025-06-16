## Comparative Performance Analysis of 1D Stencil Kernels

### Runtime Average Across 30 Kernel Runs

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

### Input and Output Elements

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

---
### Performance Analysis

- **ASM kernel** Consistently achieves about 4x speedup across all dataset sizes compared to the C reference implementation by leveraging hand-optimized assembly code that reduces overhead.
- **AVX2-XMM and AVX2-YMM kernels**. These vectorized kernels show roughly 7.5x to 9.5x speedup over the C baseline, demonstrating the power of SIMD instructions to process multiple data points concurrently. However, they fail correctness checks for all dataset sizes, indicating implementation bugs (research shows it could be the memory alignment, or vector load/store offsets).
- The C kernel, while slower, produces correct results and serves as the baseline for verification.
- The ASM kernel is both fast and correct, showing the benefit of careful manual optimization.
- The AVX2 kernels' failures highlight the complexity of vectorized code and the importance of correct memory alignment, pointer arithmetic, and boundary handling.

---
## Problems Encountered and Solutions

- **Correctness Failures in AVX2 Kernels:**
Initial AVX2 implementations failed correctness checks due to incorrect memory offsets and misaligned vector loads. The offsets used for loading vectors were in bytes but did not align with the 256-bit (32-byte) width of YMM registers, causing overlapping or incorrect data to be processed.
- **Solution Tried:**
Adjusted vector load offsets to multiples of 32 bytes, ensuring each `vmovups` loads a contiguous block of 8 floats correctly aligned with the stencil window. Further debugging is still needed to fully pass correctness tests.
- **Calling Convention and Stack Frame Issues:**
Assembly functions initially did not strictly follow the Microsoft x64 calling convention, leading to stack corruption and runtime errors. Proper use of registers (`rcx`, `rdx`, `r8` for first three arguments) and stack frame setup (`push rbp`/`mov rbp, rsp`/`pop rbp`) resolved these issues.
- **Memory Alignment:**
Ensuring input and output arrays are 32-byte aligned was essential for AVX2 instructions to work efficiently and avoid faults.

---
## Unique Methodology and AHA Moments

- **Manual Assembly Optimization vs Compiler:**
The ASM kernel's success demonstrated that hand-crafted assembly can outperform compiler-generated code by carefully managing registers and instructions.
- **Vectorization Complexity:**
The AVX2 kernels’ failures underscored the subtlety of SIMD programming: performance gains come with increased complexity in memory access patterns and alignment requirements, which are easy to overlook and cause silent correctness bugs.
- **Importance of Incremental Testing:**
Testing kernels on smaller vector sizes with detailed output helped isolate errors in pointer arithmetic and memory offsets before scaling to large inputs.
- **Performance vs Correctness Tradeoff:**
The project highlighted that raw speed is meaningless without correctness; a slower but correct ASM kernel is preferable to a faster but incorrect AVX2 kernel.

---
## Summary

This project illustrates the tradeoffs in optimizing a 1D stencil computation:

- **C code** is reliable but slower.
- **ASM code** offers a strong balance of speed and correctness.
- **AVX2 vectorized code** promises the highest speed but requires meticulous attention to detail to ensure correctness.

Future work includes fixing the AVX2 kernels to pass correctness checks, exploring tail processing for non-multiple-of-vector-width cases, and profiling to identify further optimization opportunities.
