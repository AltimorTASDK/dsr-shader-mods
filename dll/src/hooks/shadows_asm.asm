_TEXT SEGMENT

EXTERN create_shadow_map_sampler: PROC

PUBLIC hook_add_shadow_map_sampler
hook_add_shadow_map_sampler PROC
        sub     rsp, 28h
        mov     rcx, r14 ; DLResourceManager
        call    create_shadow_map_sampler
        add     rsp, 28h

        ; Overwritten instructions
        mov     [r14+388h], rsi ; store shadow depth comparison sampler
        lea     rbx, [r14+390h] ; load 

        ret
hook_add_shadow_map_sampler ENDP

_TEXT ENDS

END
