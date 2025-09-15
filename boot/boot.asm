[ORG 0x7C00]
[BITS 16]

start:
    ; Clear interrupts during setup
    cli
    
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    
    ; Set stack pointer to a safe location (below bootloader)
    mov sp, 0x8000
    
    ; Re-enable interrupts
    sti
    
    ; Print hello message
    mov si, hello_msg
    call print_string
    
    ; Infinite loop
    jmp $

; Function: print string
print_string:
    mov ah, 0x0E        ; BIOS teletype function
.loop:
    lodsb               ; Load byte from [SI] into AL, increment SI
    cmp al, 0           ; Check for null terminator
    je .done
    int 0x10            ; Print character
    jmp .loop
.done:
    ret

hello_msg db 'Welcome to TrpLoader!', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
