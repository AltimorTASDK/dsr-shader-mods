_TEXT SEGMENT

EXTERN create_render_targets: PROC

PUBLIC hook_RenderTargetManImp
hook_RenderTargetManImp PROC
        sub     rsp, 28h
        mov     rcx, [r13+2E0h] ; Entity factory
        call    create_render_targets
        ; Overwritten instructions (add 0x30 for aligned shadow space and return address)
        mov     rbx, [rsp+180h]
        mov     rcx, [rsp+28h]
        add     rsp, 130h
        mov     rax, r13 ; Restore rax
        jmp     rcx
hook_RenderTargetManImp ENDP

EXTERN create_gbuffer_draw_plan: PROC

PUBLIC hook_PrecompileCommonDrawPlans
hook_PrecompileCommonDrawPlans PROC
        sub     rsp, 28h
        mov     edx, r8d
        mov     r8d, ebx
        call    create_gbuffer_draw_plan
        add     rsp, 28h
        ret
hook_PrecompileCommonDrawPlans ENDP

_TEXT ENDS

END
