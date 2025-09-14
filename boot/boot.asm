[ORG 0x7C00]
[BITS 16]

start:
	; Clear interrupts during setup
	cli

	; Set up segments
    ; The bootloader is loaded at 0x7C00, so we set segments accordingly
	mov ax, 0x07C0      ; Calculate segment (0x7C00 >> 4)
    mov ds, ax          ; Data segment
    mov es, ax          ; Extra segment
    mov ss, ax          ; Stack segment

	; Set up stack
    mov sp, 0x1000      ; Stack grows downward from 0x8C00
    
    ; Re-enable interrupts
    sti	

	; Print hello message
    mov si, hello_msg
    call print_string
    
    ; Infinite loop 
    jmp $

; Function: print string wa 3la 9wadaaaaa
print_string:
    mov ah, 0x0E        ; BIOS teletype function ahh instruction
.loop:
    lodsb               ; Load byte from [SI] into AL, increment SI
    cmp al, 0           ; Check for null terminator
    je .done
    int 0x10            ; Print character
    jmp .loop
.done:
    ret

hello_msg db 'Hello World from Bootloader!', 13, 10, 0

; Pad to 510 bytes and add boot signature
times 510-($-$$) db 0
dw 0xAA55
