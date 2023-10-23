_TEXT SEGMENT

copy_dir_lights PROC
        ; Copy environment light directions and colors over unused water params
        movaps  xmm0, [rbp-0C0h]
        movaps  [rdi+13B0h], xmm0
        movaps  xmm0, [rbp-0B0h]
        movaps  [rdi+13C0h], xmm0
        movaps  xmm0, [rbp-0A0h]
        movaps  [rdi+13D0h], xmm0
        movaps  xmm0, [rbp-090h]
        movaps  [rdi+13E0h], xmm0
        movaps  xmm0, [rbp-080h]
        movaps  [rdi+13F0h], xmm0
        movaps  xmm0, [rbp-070h]
        movaps  [rdi+1400h], xmm0
        ret
copy_dir_lights ENDP

PUBLIC hook_copy_shader_params1
hook_copy_shader_params1 PROC
        ; Overwritten instructions
        movaps  xmm0, [rbp-60h]
        lea     rdx, [rbp]
        movaps  [rdi+12A0h], xmm0
        jmp     copy_dir_lights
hook_copy_shader_params1 ENDP

PUBLIC hook_copy_shader_params2
hook_copy_shader_params2 PROC
        ; Overwritten instructions
        movaps  xmm6, [rbp-10h]
        mov     rcx, rbx
        movaps  [rdi+12A0h], xmm0
        jmp     copy_dir_lights
hook_copy_shader_params2 ENDP

PUBLIC hook_copy_shader_params3
hook_copy_shader_params3 PROC
        ; Overwritten instructions
        movaps  xmm6, [rbp-10h]
        mov     r8d, r15d
        movaps  [rdi+12A0h], xmm0
        jmp     copy_dir_lights
hook_copy_shader_params3 ENDP

_TEXT ENDS

END