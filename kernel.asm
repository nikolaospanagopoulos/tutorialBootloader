format ELF

use32
extrn kernel_main
public _start

;EACH GDT ENTRY IS 1 BYTE
CODE_SEGMENT equ 0x08 ;first entry in the GDT (not 0) -> 0x08
DATA_SEGMENT equ 0x10 ;second entry in the GDT -> 0x10 -> (decimal 16)
;PORTS AND OFFSETS FOR MASTER PIC
PIC1_COMMAND equ 0x20 ;Command port for master pic
PIC1_DATA    equ 0x21 ;Data port for master pic
ICW1_INIT    equ 0x11 ;Initialization control word
PIC1_OFFSET  equ 0x20 ;New offset for master pic
ICW4_8086    equ 0x01 ;8086/88 mode
section '.text'

_start:
    ; Set up segment registers
	;By setting the ds, es, fs, gs, and ss registers to point to the data segment, we ensure that any data access (global variables, stack operations, etc.) references the correct memory locations defined by the GDT entry.
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


	; REMAP MASTER PIC
	; We remap the Programmable Interrupt Controller (PIC), specifically the master PIC, 
	; to avoid conflicts with existing interrupts, particularly the interrupts reserved by the CPU for exceptions.

	; In protected mode, the IRQs 0 to 7 conflict with the CPU exceptions, which are reserved by Intel up until 0x1F (interrupts 0–31). 

	; By default, the master PIC uses interrupt vectors 0x08 to 0x0F (interrupts 8–15).

	; Conflicts with CPU-Reserved Interrupts:
	; The problem arises because the CPU reserves interrupt vectors 0x00 to 0x1F for its own internal exceptions, such as:

	; 0x00: Division by zero
	; 0x0D: General protection fault
	; 0x0E: Page fault

	; To resolve this, we remap the master PIC to start using interrupt vectors from 0x20 (32) and higher.

	; Disable interrupts while remapping to prevent unwanted interrupts during this process
	cli

	mov al, ICW1_INIT
	; Start initialization for master PIC by sending the initialization command.
	; This sends the value in the AL register (ICW1_INIT, 0x11) to the command port of the master PIC (0x20).
	; ICW1 tells the master PIC to start the initialization process and wait for further configuration.
	out PIC1_COMMAND, al 

	; Set the new interrupt vector offset for the master PIC.
	; The value 0x20 (32 in decimal) is the new interrupt vector offset, meaning that IRQ0 will map to interrupt 32 (0x20), 
	; IRQ1 to interrupt 33, and so on.
	mov al, PIC1_OFFSET 
	; Send the new offset (0x20) to the master PIC's data port (0x21).
	; This is ICW2, which tells the master PIC where to start mapping its IRQs in the interrupt vector table.
	out PIC1_DATA, al

	; Configure the master PIC to operate in 8086/88 mode.
	; This sets the PIC to use a mode compatible with x86 CPUs.
	mov al, ICW4_8086
	; Send the value (0x01, for 8086/88 mode) to the master PIC's data port (0x21).
	out PIC1_DATA, al

	; Re-enable interrupts after remapping
	sti



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
