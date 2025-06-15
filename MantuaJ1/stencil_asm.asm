section .text
global stencil_asm

stencil_asm:
    push rbp
    mov rbp, rsp

    mov rsi, rcx        ; rsi = X pointer
    mov rdi, rdx        ; rdi = Y pointer
    mov ecx, r8d        ; ecx = n (32-bit)

    xor eax, eax
    sub ecx, 6          ; n - 6 iterations
    lea r8, [rsi + 12]  ; r8 = X + 3*4 bytes

.loop:
    movss xmm0, dword [r8 - 12]  ; X[i-3]
    addss xmm0, dword [r8 - 8]   ; X[i-2]
    addss xmm0, dword [r8 - 4]   ; X[i-1]
    addss xmm0, dword [r8]       ; X[i]
    addss xmm0, dword [r8 + 4]   ; X[i+1]
    addss xmm0, dword [r8 + 8]   ; X[i+2]
    addss xmm0, dword [r8 + 12]  ; X[i+3]

    movss dword [rdi], xmm0      ; Store result in Y

    add r8, 4                    ; Move to next float in X
    add rdi, 4                   ; Move to next float in Y

    dec ecx
    jnz .loop

    pop rbp
    ret