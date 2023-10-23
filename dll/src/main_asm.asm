_TEXT SEGMENT

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
