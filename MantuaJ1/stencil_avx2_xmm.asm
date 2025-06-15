section .text
global stencil_avx2_xmm

stencil_avx2_xmm:
    push rbp
    mov rbp, rsp

    mov rsi, rcx        ; rsi = X pointer
    mov rdi, rdx        ; rdi = Y pointer
    mov ecx, r8d        ; ecx = n (32-bit)

    sub ecx, 6          ; n - 6 elements to process
    and ecx, -4         ; Round down to multiple of 4 (XMM processes 4 floats)

    lea r8, [rsi + 12]  ; r8 = X + 3*4 bytes (start at X[3])

.vector_loop:
    ; Load 7 vectors of 4 floats each with proper byte offsets
    vmovups xmm0, [r8 - 12]   ; X[i-3]
    vmovups xmm1, [r8 - 8]    ; X[i-2]
    vaddps xmm0, xmm0, xmm1
    vmovups xmm2, [r8 - 4]    ; X[i-1]
    vaddps xmm0, xmm0, xmm2
    vmovups xmm3, [r8]        ; X[i]
    vaddps xmm0, xmm0, xmm3
    vmovups xmm4, [r8 + 4]    ; X[i+1]
    vaddps xmm0, xmm0, xmm4
    vmovups xmm5, [r8 + 8]    ; X[i+2]
    vaddps xmm0, xmm0, xmm5
    vmovups xmm6, [r8 + 12]   ; X[i+3]
    vaddps xmm0, xmm0, xmm6

    vmovups [rdi], xmm0       ; Store result to Y

    add r8, 16                ; Move pointer by 4 floats (16 bytes)
    add rdi, 16               ; Move pointer by 4 floats (16 bytes)

    sub ecx, 4
    jnz .vector_loop

    pop rbp
    ret