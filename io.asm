format ELF

public inb
public outb
inb:
	push ebp
	mov ebp, esp
	xor eax, eax
	mov edx, [ebp + 8]
	in al, dx
	pop ebp
	ret
outb:
	push ebp
	mov ebp, esp
	mov eax, [ebp + 12]
	mov edx, [ebp + 8]
	out dx, al
	pop ebp
	ret

