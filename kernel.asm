format ELF

use32
extrn kernel_main
public _start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

section '.text'

_start:
    ; Set up segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp


    ; Enable the A20 line
	;For an operating system developer (or Bootloader developer) this means the A20 line has to be enabled so that all memory can be accessed.
	;https://wiki.osdev.org/A20_Line
    in al, 0x92                          ; read current value from port 0x92
    or al, 2                             ; set the second bit to enable A20 line
    out 0x92, al                         ; write the new value back to 0x92 port

	call kernel_main
    jmp $

;Routine to print string in protected mode asm
pm_print_string:
    pusha
    mov ah, 0x0F            ; Attribute byte: white text on black background
.print_loop:
    lodsb                   ; Load next byte from string into AL
    cmp al, 0
    je .done                ; If null terminator, end of string
    mov [es:edi], ax        ; Write character and attribute to video memory
    add edi, 2              ; Move to next character position
    jmp .print_loop
.done:
    popa
    ret

section '.data'
test_str: db 'Protected test', 0
times 512-($ - $$) db 0
