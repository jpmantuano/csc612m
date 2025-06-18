section .text

global stencil_avx2_ymm

stencil_avx2_ymm:
    ; push rbp
    ; mov rbp, rsp

    push rsi
    push rdi

    mov rsi, rcx        ; rsi = X pointer
    mov rdi, rdx        ; rdi = Y pointer
    mov ecx, r8d        ; ecx = n (number of elements, 32-bit)

    cmp ecx, 6
    jbe .done           ; If n <= 6, nothing to do

    mov eax, ecx
    sub eax, 6          ; eax = n-6
    mov edx, eax
    and eax, -8         ; eax = number of outputs handled by YMM loop (multiple of 8)
    jz .tail            ; If less than 8, skip to tail

    lea r8, [rsi + 12]  ; r8 = X + 3*4 bytes (start at X[3])
    mov r9, rdi         ; r9 = Y pointer

.ymm_loop:
    vmovups ymm0, [r8 - 12]
    vmovups ymm1, [r8 - 8]
    vaddps ymm0, ymm0, ymm1
    vmovups ymm2, [r8 - 4]
    vaddps ymm0, ymm0, ymm2
    vmovups ymm3, [r8]
    vaddps ymm0, ymm0, ymm3
    vmovups ymm4, [r8 + 4]
    vaddps ymm0, ymm0, ymm4
    vmovups ymm5, [r8 + 8]
    vaddps ymm0, ymm0, ymm5
    vmovups ymm6, [r8 + 12]
    vaddps ymm0, ymm0, ymm6

    vmovups [r9], ymm0

    add r8, 32
    add r9, 32
    sub eax, 8
    jnz .ymm_loop

    ; r8 and r9 now point just after the last vectorized output

.tail:
    mov ecx, edx
    and ecx, 7           ; number of tail outputs
    jz .done

.tail_loop:
    cmp ecx, 0
    jle .done

    movss xmm0, dword [r8 - 12]
    movss xmm1, dword [r8 - 8]
    addss xmm0, xmm1
    movss xmm1, dword [r8 - 4]
    addss xmm0, xmm1
    movss xmm1, dword [r8]
    addss xmm0, xmm1
    movss xmm1, dword [r8 + 4]
    addss xmm0, xmm1
    movss xmm1, dword [r8 + 8]
    addss xmm0, xmm1
    movss xmm1, dword [r8 + 12]
    addss xmm0, xmm1
    movss dword [r9], xmm0

    add r8, 4
    add r9, 4
    dec ecx
    jmp .tail_loop

.done:
    ; pop rbp
    pop rdi
    pop rsi
    ret