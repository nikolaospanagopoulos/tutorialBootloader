#include "idt.h"
#include "io.h"
#include "kernel.h"
#include "memory.h"

#define IDT_ENTRIES 256
#define CODE_SEGMENT 0x08

struct idt_entry idt[IDT_ENTRIES];
struct idt_ptr idt_p;

extern void load_idt(void *ptr);
extern void int21h();
extern void no_interrupt();
void int21h_handler()
{
  terminal_writestring("Key pressed \n");
    outb(0x20, 0x20);
}

void no_interrupt_handler()
{
    outb(0x20, 0x20);
}
void idt_zero() {

  {}

  terminal_writestring("Devide by 0 error\n");
}

void set_idt_entry(int number, void *handler) {
  // isolate the lower 16bits of the 32 bit address
  // AND operation masks the higher 16 bits leaving only the lower 16 bits
  idt[number].offset_low = (uint32_t)handler & 0xFFFF;
  idt[number].offset_high = (uint32_t)handler >> 16;
  idt[number].zero = 0x0;
  idt[number].type_attr = 0xEE;
  idt[number].selector = CODE_SEGMENT;
}

void idt_init() {
  memset(idt, 0, sizeof(idt));
  idt_p.limit = sizeof(idt) - 1;
  idt_p.base = (uint32_t)idt;

    for (int i = 0; i < 256; i++)
    {
        set_idt_entry(i, no_interrupt);
    }


  set_idt_entry(0, idt_zero);
  set_idt_entry(0x21, int21h);

  load_idt(&idt_p);
}
