; 0x0000:0x7E00
org 0x7E00

mov ax, 0x0000
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00  ; 0x0000:0x7c00 (0x0000 * 16) + 0x7c00 
;stack grows downwords so (0x7c00)=>(31744 / 1024) = 31kb

mmap_ent equ 0x0500
mov si, second_stage_boot_str_success
call print_string

call get_input_from_user

jmp $

get_input_from_user:
	mov si, menu_str
	call print_string
    xor di, di               ; clear di register
    mov di, empty_command_str
read_user_key:
    mov ah, 0x0               ; BIOS function to read user key
    int 0x16                  ; BIOS interrupt
    cmp al, 0xD               ; check if ENTER was pressed
    je command_handle
    mov ah, 0eh               ; BIOS function to print char
    int 0x10                  ; BIOS interrupt
    mov [di], al              ; put the char in the empty_command_str
    inc di
    jmp read_user_key
command_handle:
    mov byte [di], 0          ; null terminate string
    mov al, [empty_command_str] ; put into al the command string buffer
    cmp al, 'D'               ; if D is pressed end program
    je exit
    cmp al, 'M'               ; if M is pressed, display memory map
    je display_memory_map
	cmp al, 'C'
	je do_checks
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
display_memory_map:
    call do_e820
    mov si, memory_map_str
    call print_string
    mov di, 0x0504
    mov cx, [mmap_ent]
print_entries:
	cmp cx, 0
    je end_display
    mov si, base_address_str
    call print_string
    mov eax, [es:di + 4]     ; Print Base Address (upper 32 bits)
    call print_hex
    mov eax, [es:di]         ; Print Base Address (lower 32 bits)
    call print_hex

    mov si, length_of_region_str
    call print_string
    mov eax, [es:di + 12]    ; Print Length (upper 32 bits)
    call print_hex
    mov eax, [es:di + 8]     ; Print Length (lower 32 bits)
    call print_hex


    mov si, type_str
    call print_string
    mov eax, [es:di + 16]    ; Print Type
    call print_hex

    add di, 24
    dec cx
    jmp print_entries
end_display:
    jmp get_input_from_user
do_checks:
	call check_pci_bus
	call cpuid_check
	call get_cpu_vendor
    jmp get_input_from_user
check_pci_bus:
	pusha                    ;save all general purpose registers
	mov si, pci_status_str
	call print_string
	mov ax, 0xB101           ;BIOS function to check for pci bus
	int 0x1A                 ;BIOS interrupt
	jc .pci_error
.pci_bus_exists:
	mov si, pci_exists_str
	call print_string
	popa                     ;restore general purpose registers
	ret
.pci_error:
	mov si, pci_not_exists_str
	call print_string
	;we need pci to connect devices
	jmp $

cpuid_check:
	pusha                                ;save state
	mov si, cpuid_ins_status_str
	call print_string
	pushfd                               ;Save EFLAGS
    pushfd                               ;Store EFLAGS
    xor dword [esp],0x00200000           ;Invert the ID bit in stored EFLAGS
    popfd                                ;Load stored EFLAGS (with ID bit inverted)
    pushfd                               ;Store EFLAGS again (ID bit may or may not be inverted)
    pop eax                              ;eax = modified EFLAGS (ID bit may or may not be inverted)
    xor eax,[esp]                        ;eax = whichever bits were changed
    popfd                                ;Restore original EFLAGS
    and eax,0x00200000                   ;eax = zero if ID bit can't be changed, else non-zero
	cmp eax,0x00
	je .cpuid_instruction_not_is_available
.cpuid_instruction_is_available:
	mov si, cpuid_ins_available_str
	call print_string
	jmp .cpuid_check_end
.cpuid_instruction_not_is_available:
	mov si, cpuid_ins_not_available_str
	call print_string
.cpuid_check_end:
	popa                                  ;restore state
	ret




;MEMORY MAP
	                          ;INT 0x15
;Newer BIOSes - GET SYSTEM MEMORY MAP
;AX = E820h
;EAX = 0000E820h
;EDX = 534D4150h ('SMAP')
;EBX = continuation value or 00000000h to start at beginning of map
;ECX = size of buffer for result, in bytes (should be >= 20 bytes)
;ES:DI -> buffer for result
;                             ;ON SUCCESS
;CF clear if successful
;EAX = 534D4150h ('SMAP')
;ES:DI buffer filled
;EBX = next offset from which to copy or 00000000h if all done
;ECX = actual length returned in bytes
;CF set on error
;AH = error code (86h) (see #00496 at INT 15/AH=80h)


;MEMORY MAP entry structure
;First uint64_t = Base addres
;Second uint64_t = Length of "region" 
;third uint32_t = type
;Next uint32_t = ACPI 3.0 Extended Attributes bitfield (if 24 bytes are returned, instead of 20)
;WITH SEGMENTATION
;[es:di]       Base Address (Low 32 bits)
;[es:di + 4]   Base Address (High 32 bits)
;[es:di + 8]   Length (Low 32 bits)
;[es:di + 12]  Length (High 32 bits)
;[es:di + 16]  Type (32 bits)
;[es:di + 20]  Extended Attributes (32 bits)

;Memory Map Entry (24 bytes total)
;| 0              | Base Address (Low)   | 4 bytes |
;| 4              | Base Address (High)  | 4 bytes |
;| 8              | Length (Low)         | 4 bytes |
;| 12             | Length (High)        | 4 bytes |
;| 16             | Type                 | 4 bytes |
;| 20             | Extended Attributes  | 4 bytes |  (we initialize)

do_e820:
	pusha
	;STEPS before using int 0x15
    mov di, 0x0504           ; Set di to 0x8004 Otherwise this code will get stuck in `int 0x15` after some entries are fetched 
    xor ebx, ebx             ; ebx must be 0 to start
    xor bp, bp               ; keep an entry count in bp | make it 0
    mov edx, 0x534D4150      ; Place "SMAP" into edx | The "SMAP" signature ensures that the BIOS provides the correct memory map format ()
    mov eax, 0xe820          ; Function to get memory map
    mov dword [es:di + 20], 1 ; force a valid ACPI 3.X entry | allows us to get additional information (extended attributes) | dword = 4 bytes
    mov ecx, 24              ; ask for 24 bytes | size of buffer for result | we want 24 to get ACPI 3.X entry with extra information
    int 0x15                 ; using interrupt
    jc short .failed         ; carry set on first call means "unsupported function"
    mov edx, 0x534D4150      ; Some BIOSes apparently trash this register? lets set it again
    cmp eax, edx             ; on success, eax must have been reset to "SMAP"
    jne short .failed
    test ebx, ebx            ; ebx = 0 implies list is only 1 entry long (worthless)
    je short .failed
    jmp short .jmpin
.e820lp:
    mov eax, 0xe820          ; eax, ecx get trashed on every int 0x15 call
    mov dword [es:di + 20], 1 ; force a valid ACPI 3.X entry
    mov ecx, 24              ; ask for 24 bytes again
    int 0x15
    jc short .e820f          ; carry set means "end of list already reached"
    mov edx, 0x534D4150      ; repair potentially trashed register
.jmpin:
    jcxz .skipent            ; skip any 0 length entries (If ecx is zero, skip this entry (indicates an invalid entry length))
    cmp cl, 20               ; got a 24 byte ACPI 3.X response?
    jbe short .notext
    test byte [es:di + 20], 1 ;if bit 0 is clear, the entry should be ignored
    je short .skipent         ; jump if bit 0 is clear 
.notext:
    mov eax, [es:di + 8]     ; get lower uint32_t of memory region length
    or eax, [es:di + 12]     ; "or" it with upper uint32_t to test for zero and form 64 bits      (little endian)
    jz .skipent              ; if length uint64_t is 0, skip entry
    inc bp                   ; got a good entry: ++count, move to next storage spot
    add di, 24               ; move next entry into buffer
.skipent:
    test ebx, ebx            ; if ebx resets to 0, list is complete
    jne short .e820lp
.e820f:
    mov [mmap_ent], bp       ; store the entry count
    clc                      ; there is "jc" on end of list to this point, so the carry must be cleared

	popa
    ret
.failed:
    stc                      ; "function unsupported" error exit
    ret

get_cpu_vendor:
	pusha
	mov eax, 0x0
	cpuid
	mov [buffer],ebx
	mov [buffer+4],edx
	mov [buffer+8],ecx
	mov si, cpu_vendor_str
	call print_string
	mov si, buffer
	call print_string
	popa
	ret





include './print_hex.asm'
include './print_string.asm'
cpu_vendor_str: db 0xA,0xD,'CPU vendor: ',0
buffer: db 12 dup(0), 0xA,0xD,0
menu_str:db 0xA,0xD,'M) display memory map',0xA,0xD,'C) Do checks', 0xA,0xD,'D) end program',0xA,0xD,0
pci_status_str: db 0xA,0xD,'pci status: ',0
pci_exists_str: db 'pci_exists',0xA,0xD,0
pci_not_exists_str: db 'pci bus is not installed',0xA,0xD,0
cpuid_ins_status_str: db 0xA,0xD,'CPUID instruction status: ',0
cpuid_ins_available_str: db 'Available',0xA,0xD,0
cpuid_ins_not_available_str: db 'Not available',0xA,0xD,0
base_address_str: db 'Base Address: ',0
length_of_region_str: db ' Length of region: ',0
new_line_str: db 0xA,0xD,0
type_str: db ' Type: ',0
memory_map_str: db 0xA, 0xD, "Memory Map:", 0xA, 0xD, 0
exit_command_str: db 0xA, 0xD, 'Program exiting...', 0xA, 0xD, 0
command_not_found_str: db 0xA, 0xD, "The command doesn't exist", 0xA, 0xD, 0
second_stage_boot_str_success: db 'Second bootloader loaded', 0xA, 0xD, 0
empty_command_str: db ''

times 2560 - ($-$$) db 0


