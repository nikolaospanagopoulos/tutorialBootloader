format ELF
section '.asm'

public load_interrupt_descriptor_table
public interrupt_21h
public empty_interrupt
public allow_interrupts
public interrupt_20h

extrn int21h_handler
extrn empty_interrupt_handler
extrn int20h_handler


load_interrupt_descriptor_table:
	push ebp
	mov ebp, esp
	mov ebx, [ebp + 8]  ;put pointer address in the ebx register
	;LIDT assembly instruction, whose argument is a pointer to an IDT Descriptor structure
	lidt [ebx]
	pop ebp
	ret
interrupt_20h:
    cli
    pushad
    call int20h_handler
    popad
    sti
    iret
interrupt_21h:
    cli
    pushad
    call int21h_handler
    popad
    sti
    iret

empty_interrupt:
    cli
    pushad
    call empty_interrupt_handler
    popad
    sti
    iret

allow_interrupts:
	sti
	ret
disable_interrupts:
	cli
	ret



