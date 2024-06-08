org 0x7c00    ;origin address 0x7c00

mov ah, 0eh   ;BIOS function to write on screen
mov al, 'p'   ;character we want to print
int 0x10      ;BIOS interrupt


;clear the screen

mov ah, 0x06  ;BIOS function to scroll
mov al, 0x00  ;clear entire window
mov bh, 0x07  ;light grey color
mov cx, 0x0000 ;upper left corner
mov dx, 0x184F ;end of lower right corner
int 0x10       ;BIOS 10 interrupt

;set cursor position

mov ah, 0x02  ;BIOS function to set cursor position
mov bh, 0x00  ;set page number
mov dh, 0x00  ;row
mov dl, 0x00  ;column
int 0x10

;write a character on the screen

;mov ah, 0eh  ;BIOS function to print a char 
;mov al, 'P'  ;character we want to print
;int 0x10     ;BIOS interrupt

mov si, hello_test_str
call print_string

mov si, welcome_str
call print_string

jmp $

hello_test_str: db 'Hello from bootloader',0xA,0xD,0
welcome_str: db 'Welcome',0

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


times 510 - ($ - $$) db 0    ;pad everything with 0s
dw 0xAA55                    ;55AA





