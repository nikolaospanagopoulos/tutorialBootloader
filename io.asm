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

;This function writes a byte (provided by the caller) to a specific I/O port. 
;The port number is stored in EDX, and the data to be written is stored in AL.
outb:
    push ebp             ;Save the base pointer
    mov ebp, esp         ;Set up the stack frame
    mov eax, [ebp + 12]  ;Load the byte to be written (passed as a parameter) into EAX
    mov edx, [ebp + 8]   ;Load the I/O port number (passed as a parameter) from the stack into EDX
    out dx, al           ;Write the byte from AL to the I/O port specified in EDX
    pop ebp              ;Restore the base pointer 
    ret    



	;THE STACK WIHOUT PUSHING THE BASE POINTER
;[return address]  ; The address to return to after the function call
;[arg1]            ; First argument (in this case, the address of the IDT) +4
;[arg2]            ; Second argument (if any), and so on +8


	;THE STACK AFTER PUSHING THE BASE POINTER
;become predictable and stable across the entire function, regardless of how the stack pointer (esp) changes within the function.

;by using ebp, a function can perform operations that manipulate the stack (e.g., pushing local variables or spilling registers), and the function’s arguments can still be accessed with a consistent offset (ebp + 8, ebp + 12, etc.).

;[old ebp]         ; Saved value of ebp
;[return address]  ; The address to return to after the function call +4
;[arg1]            ; First argument +8
;[arg2]            ; Second argument +12

;pusha saves 16 bit general purpose registers (FOR REAL MODE)
;AX, CX, DX, BX, SP (original value before PUSHA), BP, SI, DI

;pushad saves 32 bit general purpose registers (FOR PROTECTED MODE)
;EAX, ECX, EDX, EBX, ESP (original value before PUSHAD), EBP, ESI, EDI
