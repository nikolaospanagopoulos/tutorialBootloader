;0x1000:0x0000
org 0x0000

mov ax, 0x1000
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x8000   ;0x1000:0x8000



mov si, second_stage_boot_str_success
call print_string

call get_input_from_user

jmp $


get_input_from_user:
	xor di, di               ;clear di register
	mov di, empty_command_str
read_user_key:
	mov ah, 0x0               ;BIOS function to read user key
	int 0x16                  ;BIOS interrupt
	cmp al,0xD                ;check if ENTER was pressed
	je command_handle
	mov ah, 0eh               ;BIOS function to print char
	int 0x10                  ;BIOS interrupt
	mov [di],al               ;put the char in the empty_command_str
	inc di
	jmp read_user_key
command_handle:
	mov byte [di],0           ;null terminate string
	mov al, [empty_command_str] ;put into al the command string buffer
	cmp al, 'D'                 ;if D is pressed end program
	je exit
	jmp command_not_found
command_not_found:
	mov si, command_not_found_str
	call print_string
	jmp get_input_from_user
	ret
exit:
	mov si, exit_command_str
	call print_string
	cli
	hlt






include './print_string.asm'
exit_command_str: db 0xA,0xD,'Program exiting...',0xA,0xD,0
command_not_found_str: db 0xA,0xD,"the command doesnt exist",0xA,0xD,0
second_stage_boot_str_success: db 'sec bootloader loaded',0xA,0xD,0
empty_command_str: db ''

times 2048 - ($-$$) db 0
