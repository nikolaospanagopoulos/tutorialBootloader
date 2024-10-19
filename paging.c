// paging.c
#include "paging.h"
#include "physical_memory.h"
#include <string.h> // For memset

#define KERNEL_BASE                                                            \
  0x00000000 // Adjust if your kernel is loaded at a different address

page_directory_entry_t *page_directory;

void load_page_directory(page_directory_entry_t *pd);
void enable_paging();

void paging_init() {
  // Allocate and clear the page directory
  page_directory = (page_directory_entry_t *)pmm_alloc_page();
  memset(page_directory, 0, PAGE_SIZE);

  // Allocate and clear the first page table
  page_table_entry_t *first_page_table = (page_table_entry_t *)pmm_alloc_page();
  memset(first_page_table, 0, PAGE_SIZE);

  // Map the first 4MB of memory (identity mapping)
  for (uint32_t i = 0; i < PAGE_ENTRIES; i++) {
    // Set the page table entries: Present, Read/Write, and physical address
    first_page_table[i] = (i * PAGE_SIZE) | 0x3;
  }

  // Set the first entry of the page directory to point to the first page table
  page_directory[0] =
      ((uint32_t)first_page_table) | 0x3; // Present and Read/Write

  // Load the page directory into CR3
  load_page_directory(page_directory);

  // Enable paging
  enable_paging();
}
