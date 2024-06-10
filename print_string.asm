print_string:
	call print
	ret
print:
.loop:  
	lodsb   ;read character to al and then increment
	cmp al ,0 ;check if we reached the end
	je .done  ;we reached null terminator, finish
	call print_char ;print character
	jmp .loop   ;jump back into the loop
.done:
	ret
print_char:
	mov ah, 0eh
	int 0x10
	ret
