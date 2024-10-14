#include "idt.h"
#include "io.h"
#include "kernel.h"
#include "memory.h"

#define NUMBER_OF_IDT_ENTRIES 256
#define CODE_SEGMENT 0x08

struct idt_entry interrupt_descriptor_table[NUMBER_OF_IDT_ENTRIES];
struct idt_ptr idt_pointer;

void load_interrupt_descriptor_table(void *ptr);
void interrupt_21h();
void interrupt_20h();
void empty_interrupt();

void int20h_handler() {
  terminal_writestring("timer runs\n");
  outb(0x20, 0x20);
}

void int21h_handler() {
  terminal_writestring("Key pressed \n");
  /*
  After the interrupt handler finishes processing the interrupt, you need to
  notify the PIC that the interrupt has been handled, so it can allow further
  interrupts to be processed.
  */
  outb(0x20, 0x20);
}

void empty_interrupt_handler() { outb(0x20, 0x20); }
void idt_zero() {

  terminal_writestring("Devide by 0 error\n");
  /*
  After the interrupt handler finishes processing the interrupt, you need to
  notify the PIC that the interrupt has been handled, so it can allow further
  interrupts to be processed.
  */
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
  idt_pointer.limit = sizeof(interrupt_descriptor_table) - 1;
  idt_pointer.base = (uint32_t)interrupt_descriptor_table;

  for (int i = 0; i < NUMBER_OF_IDT_ENTRIES; i++) {
    set_idt_entry(i, empty_interrupt);
  }

  set_idt_entry(0x00, idt_zero);
  set_idt_entry(0x20, interrupt_20h);
  set_idt_entry(0x21, interrupt_21h);

  load_interrupt_descriptor_table(&idt_pointer);
}
