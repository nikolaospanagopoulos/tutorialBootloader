format ELF
section '.asm'

public load_idt
public int21h
public no_interrupt
public enable_int
extrn int21h_handler
extrn no_interrupt_handler

enable_int:
	sti
	ret

load_idt:
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


