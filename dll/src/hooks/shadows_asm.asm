_TEXT SEGMENT

EXTERN create_shadow_map_sampler: PROC

PUBLIC hook_AddShadowMapSampler
hook_AddShadowMapSampler PROC
        sub     rsp, 20h
        mov     rcx, r14 ; DLResourceManager
        call    create_shadow_map_sampler
        add     rsp, 20h

        ; Overwritten instructions
        mov     [r14+388h], rsi ; store shadow depth comparison sampler
        lea     rbx, [r14+390h] ; load 

        ret
hook_AddShadowMapSampler ENDP

_TEXT ENDS

END