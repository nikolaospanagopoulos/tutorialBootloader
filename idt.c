#include "idt.h"
#include "io.h"
#include "kernel.h"
#include "memory.h"

#define NUMBER_OF_IDT_ENTRIES 256
#define CODE_SEGMENT 0x08

struct idt_entry interrupt_descriptor_table[NUMBER_OF_IDT_ENTRIES];
struct idt_ptr idt_p;

extern void load_interrupt_descriptor_table(void *ptr);
extern void int21h();
extern void no_interrupt();
void int21h_handler() {
  terminal_writestring("Key pressed \n");
  outb(0x20, 0x20);
}

void no_interrupt_handler() { outb(0x20, 0x20); }
void idt_zero() {

  terminal_writestring("Devide by 0 error\n");
  outb(0x20, 0x20);
}

void set_idt_entry(int number, void *handler) {
  // isolate the lower 16bits of the 32 bit address
  // AND operation masks the higher 16 bits leaving only the lower 16 bits
  interrupt_descriptor_table[number].offset_low = (uint32_t)handler & 0xFFFF;
  // isolate the heigh 16bits of the 32 bit address
  // AND operation masks the higher 16 bits leaving only the lower 16 bits (same
  // thing after the >>)
  interrupt_descriptor_table[number].offset_high =
      ((uint32_t)handler >> 16) & 0xFFFF;
  interrupt_descriptor_table[number].zero = 0x0;
  // 0xE for the GATE type (0b1110 or 0xE: 32-bit Interrupt Gate)
  // 0xE (0b1110)-> P(Present bit = 1) DPL (1 , 1) 44bit(0) => 0b1110
  interrupt_descriptor_table[number].type_attr = 0xEE;
  interrupt_descriptor_table[number].selector = CODE_SEGMENT;
}

void idt_init() {
  memset(interrupt_descriptor_table, 0, sizeof(interrupt_descriptor_table));
  idt_p.limit = sizeof(interrupt_descriptor_table) - 1;
  idt_p.base = (uint32_t)interrupt_descriptor_table;

  for (int i = 0; i < NUMBER_OF_IDT_ENTRIES; i++) {
    set_idt_entry(i, no_interrupt);
  }

  set_idt_entry(0, idt_zero);
  set_idt_entry(0x21, int21h);

  load_interrupt_descriptor_table(&idt_p);
}
