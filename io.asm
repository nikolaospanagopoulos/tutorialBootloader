format ELF

public inb
public outb

;
;inb (Input Byte): This function reads a byte from a specific I/O port
;This function reads a byte from the I/O port whose address is passed as an argument in the EDX register. The result is placed in the AL register (the lower byte of EAX), which is returned to the caller
;
inb:
    push ebp             ;Save the base pointer 
    mov ebp, esp         ;Set up the stack frame
    xor eax, eax         ;Clear the EAX register 
    mov edx, [ebp + 8]   ;Load the I/O port number (passed as a parameter) from the stack into EDX
    in al, dx            ;Read a byte from the I/O port specified in EDX into the AL register
    pop ebp              ;Restore the base pointer
    ret                  

;This function writes a byte (provided by the caller) to a specific I/O port. The port number is stored in EDX, and the data to be written is stored in AL.
outb:
    push ebp             ;Save the base pointer
    mov ebp, esp         ;Set up the stack frame
    mov eax, [ebp + 12]  ;Load the byte to be written (passed as a parameter) into EAX
    mov edx, [ebp + 8]   ;Load the I/O port number (passed as a parameter) from the stack into EDX
    out dx, al           ;Write the byte from AL to the I/O port specified in EDX
    pop ebp              ;Restore the base pointer 
    ret    
