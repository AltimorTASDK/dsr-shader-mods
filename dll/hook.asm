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
        movaps  xmm0, [rbp-060h]
        lea     rdx, [rbp]
        movaps  [rdi+12A0h], xmm0
        jmp     copy_dir_lights
hook_copy_shader_params1 ENDP

PUBLIC hook_copy_shader_params2
hook_copy_shader_params2 PROC
        ; Overwritten instructions
        movaps  xmm6, [rbp-010h]
        mov     rcx, rbx
        movaps  [rdi+12A0h], xmm0
        jmp     copy_dir_lights
hook_copy_shader_params2 ENDP

PUBLIC hook_copy_shader_params3
hook_copy_shader_params3 PROC
        ; Overwritten instructions
        movaps  xmm6, [rbp-010h]
        mov     r8d, r15d
        movaps  [rdi+12A0h], xmm0
        jmp     copy_dir_lights
hook_copy_shader_params3 ENDP

EXTERN apply_hooks: PROC

PUBLIC hook_SteamAPI_Init
hook_SteamAPI_Init PROC
        ; Overwritten instruction (8 less because of return address)
        sub     rsp, 40h
        call    apply_hooks
        ; Clear ZF and skip check for already being initialized
        ; I don't want to deal with the global reference
        xor     rax, rax
        ; Jump to return address
        jmp     qword ptr [rsp+40h]
hook_SteamAPI_Init ENDP

_TEXT ENDS

END