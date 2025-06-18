section .text

global stencil_avx2_xmm

stencil_avx2_xmm:
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
    sub eax, 6          ; eax = n-6 (number of output elements)
    mov edx, eax        ; edx = n-6 (save for tail)
    and eax, -4         ; eax = (n-6) rounded down to multiple of 4

    lea r8, [rsi + 12]  ; r8 = X + 3*4 bytes (start at X[3])
    mov r9, rdi         ; r9 = Y pointer

    cmp eax, 0
    jle .tail

.vector_loop:
    vmovups xmm0, [r8 - 12]
    vmovups xmm1, [r8 - 8]
    vaddps xmm0, xmm0, xmm1
    vmovups xmm2, [r8 - 4]
    vaddps xmm0, xmm0, xmm2
    vmovups xmm3, [r8]
    vaddps xmm0, xmm0, xmm3
    vmovups xmm4, [r8 + 4]
    vaddps xmm0, xmm0, xmm4
    vmovups xmm5, [r8 + 8]
    vaddps xmm0, xmm0, xmm5
    vmovups xmm6, [r8 + 12]
    vaddps xmm0, xmm0, xmm6

    vmovups [r9], xmm0

    add r8, 16          ; Move X pointer by 4 floats (16 bytes)
    add r9, 16          ; Move Y pointer by 4 floats (16 bytes)
    sub eax, 4
    jnz .vector_loop

.tail:
    mov ecx, edx
    and ecx, 3          ; ecx = tail count (remaining outputs)
    jz .done

.tail_loop:
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
    jnz .tail_loop

.done:
    ; pop rbp
    pop rdi
    pop rsi
    ret