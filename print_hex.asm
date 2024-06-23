;print 32 bit hexadecimal values
print_hex:
    pusha                  ; Save all registers

    mov ecx, 8             ; We will print 8 hex digits (32 bits)
    mov ebx, eax           ; Copy the value to be printed into ebx

print_hex_loop:
    rol ebx, 4             ; Rotate left to bring the next nibble to the lowest 4 bits
    mov al, bl             ; Get the lowest 4 bits
    and al, 0x0F           ; Mask out everything except the lowest 4 bits
    cmp al, 10
    jl print_digit         ; If al < 10, it's a number
    add al, 'A' - 10       ; Convert 10-15 to 'A'-'F'
    jmp print_hex_digit
print_digit:
    add al, '0'            ; Convert 0-9 to '0'-'9'

print_hex_digit:
    mov ah, 0x0E           ; BIOS teletype function
    int 0x10               ; BIOS interrupt to print character
    loop print_hex_loop    ; Loop until all digits are printed

    popa                   ; Restore all registers
    ret



;EXAMPLE
	;0x1234ABCD  <===== eax
	;0x234ABCD1  <===== rol by 4 bits
	;al [bl]     <===== al will contain the lowest 8 bits (0xD1)         
	;and al, 0x0F <==== al will only contain the lowest 4 bits (0x01)
	;check if less than 10
	;if it is we add '0' (48)
	;else we add 'A' - 10


