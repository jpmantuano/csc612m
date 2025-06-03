### Explaining Multiple Data Transfer Method ###
How data moves between your computer’s main memory (the CPU) and the graphics card (the GPU). Below are four data transfer methods between CPU and GPU.

1.) Unified memory
2.) Prefetching of data with memory advice
3.) Data initialization as a CUDA kernel
4.) Old method of transferring data between CPU and memory (memCUDA malloc + CUDAmemcpy)

### Summary: Test Results And Analysis ###
#### GPU Kernel Execution Time ####

- **Prefetch and Mem Advise** achieves the best performance with the lowest total run time (585.92 ms) and average kernel time (19.53 ms), ranking 1st overall. This indicates that proactive prefetching combined with memory advice significantly reduces kernel execution overhead.

- **Data Initialization with CUDA** ranks 2nd, with a total run time of 925.49 ms and average of 30.85 ms. Initializing data directly on the GPU reduces transfer overhead and improves execution efficiency compared to older methods.

- **Unified Memory Version** performs moderately well (1029.68 ms total, 34.32 ms average), ranking 3rd. While simpler to program, unified memory incurs some overhead due to page fault handling and data migration.

- **Old Method** using explicit `cudaMalloc` and `cudaMemcpy` is slower (1284.66 ms total, 42.822 ms average), ranking 4th, reflecting the cost of manual data transfers and synchronization.

- **Vanilla C** (baseline) is the slowest by far (31510.242 ms total, 1050.34 ms average), ranking 5th, showing the dramatic performance gains possible with modern CUDA memory management techniques.

Prefetch and Mem Advise is roughly 54x faster than Vanilla C, and about 1.76x faster than Unified Memory.

| Version | Type                          | Total Run time (ms) | Average (ms) | Ranking |
| ------- | ----------------------------- | ------------------- | ------------ | ------- |
| 0       | Vanilla C                     | 31510.242           | 1050.34      | 5       |
| 1       | Unified Memory Version        | 1029.68             | 34.32        | 3       |
| 2       | Prefetch and Mem Advise       | 585.92              | 19.53        | 1       |
| 3       | Data Initialization with CUDA | 925.49              | 30.85        | 2       |
| 4       | Old Method                    | 1284.66             | 42.822       | 4       |
#### Comparison of GPU Kernel Execution Time Between Data Transfer Methods ####
| Version | Type                         | vs Vanilla C (x times better) | vs Unified Memory | vs Prefetching and Mem Advise | vs Data Initialization with CUDA | vs Old Method |
|---------|------------------------------|-------------------------------|-------------------|------------------------------|----------------------------------|---------------|
| 0       | Vanilla C                    | 1.00                          | 0.03              | 0.02                         | 0.03                             | 0.04          |
| 1       | Unified Memory Version       | 30.60                         | 1.00              | 0.57                         | 0.90                             | 1.25          |
| 2       | Prefetch and Mem Advise      | 53.78                         | 1.76              | 1.00                         | 1.58                             | 2.19          |
| 3       | Data Initialization with CUDA | 34.05                       | 1.11              | 0.63                         | 1.00                             | 1.39          |
| 4       | Old Method                  | 24.53                         | 0.80              | 0.46                         | 0.72                             | 1.00          |

#### Data Transfer Time ####

- **Prefetch and Mem Advise** again leads with the shortest data transfer time (252.98 ms), ranking 1st, demonstrating the effectiveness of prefetching in minimizing transfer latency.

- **Data Initialization with CUDA** follows closely (263.22 ms, rank 2), benefiting from GPU-side initialization that reduces host-to-device transfers.

- **Unified Memory Version** ranks 3rd (306.37 ms), showing reasonable transfer times but still slower than explicit prefetching.

- **Old Method** is the slowest (951.3 ms, rank 4), due to explicit host-device copies and lack of optimization.

- **Vanilla C** data transfer time is not applicable (NA), likely because it does not separate transfer and kernel execution clearly or uses a different baseline.

The relative speedups show Prefetch and Mem Advise reduces transfer time by over 3.7x compared to Old Method and about 1.2x compared to Unified Memory.

| Version | Type                         | Total Data Transfer Time (ms) | Ranking |
|---------|------------------------------|-------------------------------|---------|
| 0       | Vanilla C                    | NA                            | NA      |
| 1       | Unified Memory Version       | 306.37                        | 3       |
| 2       | Prefetch and Mem Advise      | 252.98                        | 1       |
| 3       | Data Initialization with CUDA | 263.22                      | 2       |
| 4       | Old Method                  | 951.3                         | 4       |

#### Comparison of Data Transfer Time Between Data Transfer Methods ####
| Version | Type                         | vs Vanilla C (x times better) | vs Unified Memory | vs Prefetching and Mem Advise | vs Data Initialization with CUDA | vs Old Method |
|---------|------------------------------|-------------------------------|-------------------|------------------------------|----------------------------------|---------------|
| 0       | Vanilla C                    | NA                            | NA                | NA                           | NA                               | NA            |
| 1       | Unified Memory Version       | NA                            | 1.00              | 0.83                         | 0.86                             | 3.11          |
| 2       | Prefetch and Mem Advise      | NA                            | 1.21              | 1.00                         | 1.04                             | 3.76          |
| 3       | Data Initialization with CUDA | NA                          | 1.16              | 0.96                         | 1.00                             | 3.61          |
| 4       | Old Method                  | NA                            | 0.32              | 0.27                         | 0.28                             | 1.00          |

### Screenshots of Program Output ###
#### Version 0: Using C to implement 1D Convolution ####
![[Pasted image 20250603224928.png]]

#### Version 1: Unified Memory Version of 1D Convolution ####
![[Pasted image 20250603225021.png]]

#### Version 2: CUDA with Prefetching data and Memory Advice ####
![[Pasted image 20250603225100.png]]

#### Version 3: Data Initialization with CUDA Kernel ####
![[Pasted image 20250603225124.png]]

#### Version 4: Old method of data transfer ####
![[Pasted image 20250603225149.png]]