/*
defines how the various sections of an executable are arranged in memory when creating a binary output format.
*/

ENTRY(_start)
/*
Entry symbol of our program (_start function of kernel.asm file)
*/

OUTPUT_FORMAT(binary)
SECTIONS
{
    . = 1M;
	/*
		This sets the location counter to 1 MB (0x100000). This means the subsequent sections will be placed starting at the 1 MB mark in memory. This is a common setup for kernels in operating systems, as the first 1 MB is typically reserved for real mode, interrupt vector tables, and BIOS data in x86 systems.
        Every section is alligned in a 4kb boundary
	*/
    .text : ALIGN(4096)
	/*
	this section contains the executable code
	*/
    {
        *(.text)
    }
    .rodata : ALIGN(4096)
	/*
	read only data like constants and string literal
	*/
    {
        *(.rodata)
    }
    .data : ALIGN(4096)
	/*
	This section contains initialized data
	*/
    {
        *(.data)
    }
    .bss : ALIGN(4096)
	/*
	This section contains uninitialized data. Variables that are declared but not initialized are placed here.
	  COMMON -> Includes all common symbols, which are uninitialized data that can be defined in multiple places.
	*/
    {
        *(COMMON)
        *(.bss)
    }
    .asm : ALIGN(4096)
	/*
	section only used for assembly code
	*/
    {
        *(.asm)
    }
}
