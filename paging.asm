format ELF

public load_page_directory
public enable_paging

section '.text'

load_page_directory:
    mov eax, [esp + 4]   ; Get the first argument (page_directory address)
    mov cr3, eax         ; Load CR3 with the page directory address
    ret

enable_paging:
    mov eax, cr0         ; Get the current value of CR0
    or eax, 0x80000000   ; Set the paging bit (bit 31)
    mov cr0, eax         ; Update CR0
    ret

