section .text
global stencil_avx2_ymm

stencil_avx2_ymm:
    push rbp
    mov rbp, rsp

    mov rsi, rcx        ; rsi = X pointer
    mov rdi, rdx        ; rdi = Y pointer
    mov ecx, r8d        ; ecx = n (32-bit)

    sub ecx, 6          ; n - 6 elements to process
    and ecx, -8         ; round down to multiple of 8 floats

    lea r8, [rsi + 12]  ; r8 = X + 3*4 bytes (start at X[3])

.vector_loop:
    ; Load 7 vectors (8 floats each) with proper byte offsets
    vmovups ymm0, [r8 - 12]    ; X[i-3]
    vmovups ymm1, [r8 - 8]     ; X[i-2]
    vaddps ymm0, ymm0, ymm1
    vmovups ymm2, [r8 - 4]     ; X[i-1]
    vaddps ymm0, ymm0, ymm2
    vmovups ymm3, [r8]         ; X[i]
    vaddps ymm0, ymm0, ymm3
    vmovups ymm4, [r8 + 4]     ; X[i+1]
    vaddps ymm0, ymm0, ymm4
    vmovups ymm5, [r8 + 8]     ; X[i+2]
    vaddps ymm0, ymm0, ymm5
    vmovups ymm6, [r8 + 12]    ; X[i+3]
    vaddps ymm0, ymm0, ymm6

    vmovups [rdi], ymm0        ; Store result to Y

    add r8, 32                 ; Move pointer by 8 floats (8*4=32 bytes)
    add rdi, 32                ; Move pointer by 8 floats

    sub ecx, 8
    jnz .vector_loop

    pop rbp
    ret