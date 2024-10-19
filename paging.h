// paging.h
#ifndef PAGING_H
#define PAGING_H

#include <stdint.h>

#define PAGE_SIZE 4096
#define PAGE_ENTRIES 1024

typedef uint32_t page_directory_entry_t;
typedef uint32_t page_table_entry_t;

void paging_init();

#endif // PAGING_H
