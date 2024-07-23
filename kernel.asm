format ELF

use32
extrn kernel_main
public _start

;EACH GDT ENTRY IS 1 BYTE
CODE_SEGMENT equ 0x08 ;first entry in the GDT (not 0) -> 0x08
DATA_SEGMENT equ 0x10 ;second entry in the GDT -> 0x10 -> (decimal 16)

section '.text'

_start:
    ; Set up segment registers
    mov ax, DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
	;The ebp register, also known as the Base Pointer or Frame Pointer, is used in x86 architecture to manage stack frames for function calls.
	;0x200000 is a free area that we can use
    mov ebp, 0x200000
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
