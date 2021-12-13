;--------------------------------------------------
section mbr vstart=0x7c00
    mov ax,0x00
    mov ds,ax 
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov sp,0x7c00
    
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
;get the position of cursor
    mov ah,0x03
    mov bh,0x00
    int 0x10
    
;--------------------------------------------------
;print hello world!
    mov ax,string
    mov bp,ax
    mov cx,12   ;the length of string
    mov ah,0x13
    mov al,0x01
    mov bh,0x00
    mov bl,0x02
    int 0x10

;--------------------------------------------------
;forever loop
    jmp $

;--------------------------------------------------
;data
string db "hello world!"
times 512-2-($-$$) db 0x00
db 0x55,0xaa