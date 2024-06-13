clear_screen:
	mov ah, 0x06  ;BIOS function to scroll
	mov al, 0x00  ;clear entire window
	mov bh, 0x07  ;light grey color
	mov cx, 0x0000 ;upper left corner
	mov dx, 0x184F ;end of lower right corner
	int 0x10       ;BIOS 10 interrupt
	ret
set_cursor_position:
	mov ah, 0x02  ;BIOS function to set cursor position
	mov bh, 0x00  ;set page number
	mov dh, 0x00  ;row
	mov dl, 0x00  ;column
	int 0x10
	ret
