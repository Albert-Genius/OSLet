%include "boot.inc"
;--------------------------------------------------
;section mbr vstart=LOADER_BASE_RAM_ADD
    mov ax,0xb800
    mov gs,ax

;--------------------------------------------------
;clear screen
    mov ah,0x06
    mov al,0x00
    mov bh,0x07
    mov bl,0x00
    mov cx,0x00
    mov dh,0x18
    mov dl,0x4f
    int 0x10

;--------------------------------------------------
;print hello world!
    mov byte [gs:0x00],'H'
    mov byte [gs:0x02],'e'
    mov byte [gs:0x04],'l'
    mov byte [gs:0x06],'l'
    mov byte [gs:0x08],'o'
    mov byte [gs:0x0a],' '
    mov byte [gs:0x0c],'W'
    mov byte [gs:0x0e],'o'
    mov byte [gs:0x10],'r'
    mov byte [gs:0x12],'l'
    mov byte [gs:0x14],'d'
    mov byte [gs:0x16],'!'

;infinite loop
    jmp $