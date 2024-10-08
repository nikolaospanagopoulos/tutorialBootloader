#pragma once
#include <stdint.h>

struct idt_entry {
    uint16_t offset_low;    // Lower 16 bits of handler function address
    uint16_t selector;      // Kernel segment selector
    uint8_t  zero;          // Reserved, set to 0
    uint8_t  type_attr;     // Type and attributes (e.g., interrupt gate)
    uint16_t offset_high;   // Higher 16 bits of handler function address
} __attribute__((packed));  // Ensure no padding is added by the compiler

struct idt_ptr {
    uint16_t limit;         // Limit (size of the IDT - 1)
    uint32_t base;          // Base address of the IDT
} __attribute__((packed));  // Packed structure


void idt_init();
void set_idt_entry(int number,void* handler);
void enable_int();
