%include "boot.inc"
section loader vstart=LOADER_BASE_RAM_ADD
;STRAT
    jmp start

;--------------------------------------------------
;Construct GDT
GDT_BASE:
    dd 0x0
    dd 0x0
CODE_SEG:
    dd 0xffff
    dd DESC_CODE_HIGH4
DATA_STACK_SEG:
    dd 0xffff
    dd DESC_DATA_HIGH4
DISPLAY_SEG:
    dd (DISPLAY_BASE_RAM_ADD << 16) + 0x7
    dd DESC_VIDEO_HIGH4

GDT_SIZE equ ($ - GDT_BASE)
GDT_LIMIT equ (GDT_SIZE - 1)
;reserve 50 GDs
times 50 dq 0x0

;new a ptr to GDT ram address
p_gdt dw GDT_LIMIT 
        dd GDT_BASE

p_total_memory dd 0

;--------------------------------------------------
;Define selectors
SELECTOR_CODE equ ((0x1 << 3) + TI_GDT + RPL0)
SELECTOR_DATA equ ((0x2 << 3) + TI_GDT + RPL0)
SELECTOR_DISPLAY equ ((0x3 << 3) + TI_GDT + RPL0)


;Start
start:
    call clear_screen
    call printer1
    call get_total_memory
    call enter_p

    jmp dword SELECTOR_CODE:start_pmode

;--------------------------------------------------
;func:enter protection mode
enter_p:
    ;step1:open A20
    in al, 0x92
    or al, 0x02
    out 0x92, al

    ;step2: load gdt to gdtr
    lgdt [p_gdt]

    ;step3: enable protection mode
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    ;return
    ret

;--------------------------------------------------
;func:get total memory
get_total_memory:
    mov ax, 0xe801
    int 0x15
    jnc .postprocess
    hlt
.postprocess:
    ; low 15M address
    mov cx, 0x400 
    mul cx
    shl edx, 16
    and eax, 0xffff
    or edx, eax
    add edx, 0x1 << 20
    mov esi, edx

    ; > 16M address
    xor eax, eax
    mov ax, bx
    mov ecx, 0x10000
    mul ecx

    ; sum
    add esi, eax
    mov edx, esi

    ; store to memory
    mov [p_total_memory], edx

    ; return
    ret


;--------------------------------------------------
;func:clear screen
clear_screen:
    mov ah,0x06
    mov al,0x00
    mov bh,0x07
    mov bl,0x00
    mov cx,0x00
    mov dh,0x18
    mov dl,0x4f
    int 0x10
    ;return 
    ret

;--------------------------------------------------
;func:printer1 !
printer1:
    mov ax,DISPLAY_BASE_RAM_ADD >> 4
    mov gs,ax
    mov byte [gs:0x00],'E'
    mov byte [gs:0x02],'n'
    mov byte [gs:0x04],'t'
    mov byte [gs:0x06],'e'
    mov byte [gs:0x08],'r'
    mov byte [gs:0x0a],' '
    mov byte [gs:0x0c],'P'
    mov byte [gs:0x0e],'r'
    mov byte [gs:0x10],'o'
    mov byte [gs:0x12],'t'
    mov byte [gs:0x14],'e'
    mov byte [gs:0x16],'c'
    mov byte [gs:0x18],'t'
    mov byte [gs:0x1a],'.'
    mov byte [gs:0x1c],'.'
    mov byte [gs:0x1e],'.'
    ;return
    ret
     


;--------------------------------------------------
;protection mode entrence
[bits 32]
start_pmode:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_BASE_RAM_ADD

    call printer2

enable_mem_page:
    ;1.set up page
    call setup_page

    ;2.modify gdt addr
    sgdt [p_gdt] 
    mov ebx, [p_gdt + 2]
    or dword [ebx + 0x8*3 + 4], 0xc0000000
    or dword [p_gdt + 2], 0xc0000000

    ;3.modify sp addr
    or esp, 0xc0000000

    ;4.cr3 point to PDE
    mov eax, PAGE_DIR_TABLE_BASE
    mov cr3, eax

    ;5.set page enable bit
    mov eax, cr0
    or eax, 0x1<<31
    mov cr0, eax

    ;6.set new gdt
    lgdt [p_gdt]

    ;debug
    mov byte [gs:80*2], 'P'
    mov byte [gs:80*2+2], 'a'
    mov byte [gs:80*2+4], 'g'
    mov byte [gs:80*2+6], 'e'

    jmp $
;--------------------------------------------------
;func:printer2 !
printer2:
    mov ax, SELECTOR_DISPLAY
    mov gs, ax
    mov byte [gs:0x00],'D'
    mov byte [gs:0x02],'o'
    mov byte [gs:0x04],'n'
    mov byte [gs:0x06],'e'
    mov byte [gs:0x08],'.'
    ;return
    ret

;--------------------------------------------------
;create Page Directory Entry & Page Table Entry
setup_page:

;clear pde
    mov ecx, 1024
    mov esi, 0
.clear_pde:
    mov dword [PAGE_DIR_TABLE_BASE + esi], 0
    inc esi
    loop .clear_pde

;create pde
.create_pde:
    ;last PDE point to it self
    mov eax, PAGE_DIR_TABLE_BASE
    or eax, PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_TABLE_BASE + (0x1023 *4)], eax

    ;create kernel PDE
    add eax, 0x01000
    mov [PAGE_DIR_TABLE_BASE], eax ;first PDE
    mov [PAGE_DIR_TABLE_BASE + (0xc00 >> 2 * 4)], eax ;0xc00 >> 2 = 768 PDE

    ;create other kernel PDE
    add eax, 0x01000
    mov ecx, (1024-768-2) ;254 PDE
    mov esi, 0
    mov ebx, PAGE_DIR_TABLE_BASE + 0xc04
.create_other_kernel_pde:
    mov [ebx+esi*4], eax
    add eax, 0x10000
    inc esi
    loop .create_other_kernel_pde


;create pte, base_addr = PAGE_DIR_TABLE_BASE(0x100000) + 0x01000 , phyaddr 1M(0x0-0xfffff)
    mov edx, PG_US_U | PG_RW_W | PG_P
    mov ecx, 256 ;1M 
    mov ebx, (PAGE_DIR_TABLE_BASE + 0x01000)
    mov esi, 0
.create_pte:
    mov [ebx+esi*4], edx
    add edx, 0x01000
    inc esi
    loop .create_pte

;func return
    ret
