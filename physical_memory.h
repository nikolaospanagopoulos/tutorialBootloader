#pragma once
#include <stddef.h>
#include <stdint.h>

// Page size (4KB)
#define PAGE_SIZE 4096

#define REGION_COUNT 7

typedef struct {
  uint64_t base_addr;
  uint64_t length;
  uint32_t type;
} memory_region_t;

void pmm_init();
void *pmm_alloc_page();
void pmm_free_page(void *page);
