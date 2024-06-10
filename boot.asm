org 0x7c00    ;origin address 0x7c00
start:
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

	;memory we want to place our second bootloader to
	mov ax, 0x1000
	mov es, ax
	mov ax, 0x0000
	mov bx, ax
	;we will load to 0x1000:0x0000 -> 10000

	; read sectors from memory
	mov ah, 0x02  ;BIOS function to read disk sectors
	mov al, 0x04  ;(2048) how many sectors we want to read
	mov dh, 0x00  ;head
	mov dl ,0x00  ;drive
	mov ch, 0x00  ;cylinder
	mov cl, 0x02  ;sector we want to start reading from
	int 0x13      ;call BIOS interrupt
	jc read_from_disk_failed

	jmp 0x1000:0x0000


	jmp $


include './print_string.asm'

read_from_disk_failed:
	mov si, read_sectors_failed_str
	call print_string
	jmp $

read_sectors_failed_str: db 'failed to read disk sectors',0xA,0xD,0

times 510 - ($ - $$) db 0    ;pad everything with 0s
dw 0xAA55                    ;55AA





