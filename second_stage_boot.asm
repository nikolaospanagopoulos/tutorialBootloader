;0x1000:0x0000
org 0x0000

mov ax, 0x1000
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x8000   ;0x1000:0x8000



mov si, second_stage_boot_str_success
call print_string
jmp $



include './print_string.asm'

second_stage_boot_str_success: db 'sec bootloader loaded',0xA,0xD,0


times 2048 - ($-$$) db 0
