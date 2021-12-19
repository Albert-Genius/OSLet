%include "boot.inc"
;--------------------------------------------------
section mbr vstart=0x7c00
    mov ax,cs
    mov ds,ax 
    mov es,ax
    mov ss,ax
    mov fs,ax
    mov ax,0xb800
    mov gs,ax
    mov sp,0x7c00
    
;--------------------------------------------------
;load loader & jump to loader
    mov eax,LOADER_START_LBA
    mov bx,LOADER_BASE_RAM_ADD
    mov cx,LOADER_SECTOR_NUM
    call rd_m_disk 

    jmp LOADER_BASE_RAM_ADD

;--------------------------------------------------
;func: read master disk
rd_m_disk:
    mov di,cx

    ;set lba address
    mov dx,0x1f3
    out dx,al

    mov cl,8
    shr eax,cl
    mov dx,0x1f4
    out dx,al

    shr eax,cl
    mov dx,0x1f5
    out dx,al

    shr eax,cl
    and al,0x0f
    or al,0xe0 ;lba mode
    mov dx,0x1f6
    out dx,al

    ;set sector number
    mov dx,0x1f2
    mov al,cl
    out dx,al

    ;send read command
    mov dx,0x1f7
    mov al,0x20
    out dx,al

    ;wait till data is ready
_not_ready:
    in al,dx
    and al,0x08
    cmp al,0x08
    nop
    jnz _not_ready

    ;read data from disk
    mov ax,di
    mov dx,256
    mul dx
    mov cx,ax ;cx for total bytes need read
    mov dx,0x1f0
_continue_read:
    in ax,dx
    mov [bx],ax
    add bx,2
    loop _continue_read
    
    ;return
    ret

;--------------------------------------------------
;data
times 512-2-($-$$) db 0x00
db 0x55,0xaa