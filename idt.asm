format ELF
section '.asm'

public load_interrupt_descriptor_table
public int21h
public no_interrupt
extrn int21h_handler
extrn no_interrupt_handler
public allow_interrupts

allow_interrupts:
	sti
	ret
disable_interrupts:
	cli
	ret

load_interrupt_descriptor_table:
	push ebp
	mov ebp, esp
	mov ebx, [ebp + 8]
	lidt [ebx]
	pop ebp
	ret

int21h:
    cli
    pushad
    call int21h_handler
    popad
    sti
    iret

no_interrupt:
    cli
    pushad
    call no_interrupt_handler
    popad
    sti
    iret


	;THE STACK WIHOUT PUSHING THE BASE POINTER
;[return address]  ; The address to return to after the function call
;[arg1]            ; First argument (in this case, the address of the IDT) +4
;[arg2]            ; Second argument (if any), and so on +4
	;THE STACK AFTER PUSHING THE BASE POINTER
;[old ebp]         ; Saved value of ebp
;[return address]  ; The address to return to after the function call +4
;[arg1]            ; First argument +4
;[arg2]            ; Second argument +4

;pusha saves 16 bit general purpose registers (FOR REAL MODE)
;AX, CX, DX, BX, SP (original value before PUSHA), BP, SI, DI

;pushad saves 32 bit general purpose registers (FOR PROTECTED MODE)
;EAX, ECX, EDX, EBX, ESP (original value before PUSHAD), EBP, ESI, EDI



