;Joseph Paulo L Mantuano
;1243_CSC612M_G01

; The program computes the sum of eight single-precision floating-point numbers stored in var1. 
; It loads all eight floats into the YMM register (ymm3), splits the register into 
; two 128-bit halves, adds them together, and then performs horizontal additions (vhaddps) 
; to accumulate the total sum into a single float in xmm3. 
; Finally, it prepares the argument and calls the external print_float function 
; to display the result, 


section .data
    var1    dd 5.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5, 29.5

section .text
    global main
    extern print_float

main:
    push rbp
    mov rbp, rsp

    vmovups ymm3, [rel var1]    ; Load 8 floats (256 bits) from var1 into 

    vextractf128 xmm1, ymm3, 1  ; Extract upper 128 bits (last 4 floats) of ymm3 into xmm1
    vaddps xmm3, xmm3, xmm1     ; Add lower 128 bits (xmm3) and upper 128 bits (xmm1), result in xmm3

    vhaddps xmm3, xmm3, xmm3    ; Horizontally add pairs of floats in xmm3, partial sum
    vhaddps xmm3, xmm3, xmm3    ; Horizontally add again to get total sum in lowest float of xmm3

    sub rsp, 32                 ; Allocate 32 bytes shadow space for Windows x64 calling convention
    vmovss xmm0, xmm3           ; Move scalar float sum into xmm0 as argument for print_float
    vzeroupper                  ; Clear upper 128 bits of YMM registers to avoid AVX-SSE transition penalty
    call print_float            ; Call external function to print the float
    add rsp, 32                 ; Deallocate shadow space

    mov eax, 0
    pop rbp
    ret